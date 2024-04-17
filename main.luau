--!strict
--!nolint LocalShadow
-- by dev chrysalis

-- downloads recent files of canvas so we don't have to :p 

local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local datetime = require("@lune/datetime")
local fromIsoDate = datetime.fromIsoDate
local jsonDecode = net.jsonDecode

local exit = process.exit 

local List = require("libraries/Lists")

type List = List.List
type ClassInfo = {classid: string, output_dir: string}
type FileProperties = {
      display_name: string,
      filename: string,
      id: number,
      updated_at: string,
      url: string,
      [string]: any
}

local function readConfig()
      assert(fs.isFile(".config.jsonc"), "no .config.jsonc found! please copy the template jsonc and add the relevant info and save it as '.config.jsonc' within this directory.")

      local raw_config = fs.readFile(".config.jsonc"):gsub("%s//[%w%p ]*\n", "") -- need to remove comments from jsonc at runtime :/
      local config = net.jsonDecode(raw_config)

      -- validate api key exists
      assert(config.CANVAS_API_KEY ~= "", "Missing Canvas API Key/Token; please generate one in settings.")

      local classes = List.frompairs(config.Classes)
      -- validate target dirs
      local invalid_dirs = classes:mappairs(function(class_name, info: ClassInfo)
            local dir_exists = fs.isDir(info.output_dir)
            return class_name, if dir_exists then nil else info.output_dir
      end)
      
      if not invalid_dirs.is_empty then
            print("Error: invalid output_dirs:")
            print(invalid_dirs:table())
            process.exit(1)
      end

      return config
end

local function getFilesFromCanvas(API_KEY: string, BASE_URL: string, Classes: List)

      local sort_query = "/files?sort=created_at&order=desc&"
      local select_fields = List.new("display_name", "filename", "id", "updated_at", "url")

      local callApi = function(url)
            local response = process.spawn("curl", {`{url}access_token={API_KEY}`})
            return jsonDecode(if response.ok then response.stdout else response.stderr)
      end

      return Classes:map_values(function(class, info: ClassInfo)
            local url = BASE_URL .. info.classid .. sort_query
            local files = List.from(callApi(url))

            return files:map(function(file: FileProperties)
                  return List.mapped(file, function(property, value)
                        if not select_fields:has(property) then
                              return nil
                        end
                        if property == "updated_at" then
                              value = fromIsoDate(value).unixTimestamp
                        end
                        return property, value
                  end):table()
            end)
      end)
end

local function filterRecentFiles(files_by_class: List, days: number)
      local days = days or 7

      local today_unix = datetime.now().unixTimestamp
      local seconds_in_day = 24 * 60^2

      return files_by_class:remap_array_values(function(file: FileProperties, _, class: string)
            if today_unix - file.updated_at < days * seconds_in_day then
                  return {
                        filename = file.filename,
                        download_link = file.url
                  }
            end
            return
      end)
end

local function downloadFiles(recent_files: List, class_directories)
      type File = {
            filename: string,
            download_link: string,
      }

      local downloadFile = function(file: File, path: string)
            local result = process.spawn("curl", {`-o{file.filename}`, file.download_link}, {
                  cwd = path
            })
            if result.ok then
                  print(`- Successfully downloaded {file.filename} to:\n    {path}/{file.filename}`)
            else
                  print(`!! Download error: {file.filename};\n    {result.stderr}`)
            end
      end

      recent_files:mappairs(function(class, files: List)
            print(`\n{class}:`)
            local target_directory = class_directories[class]
            local existing_files = List.from(fs.readDir(target_directory))

            files:each(function(file: File)
                  if not existing_files:has(file.filename) then
                        downloadFile(file, target_directory)
                  else
                        print(`- {file.filename} already exists; not downloading.`)
                  end
            end)
            return
      end)

end


--- Procedural
local config = readConfig()

local API_KEY = config.CANVAS_API_KEY
local BASE_URL = config.BASE_URL .. "/api/v1/courses/"
local Classes = List.frompairs(config.Classes)

local arg = table.concat(process.args, " "):match("(%d)")
local filter_days = tonumber(arg) or 7

print(`\nFiltering: last {filter_days} days...`)

local class_directories = Classes:map_values(function(name, info: ClassInfo)
      return info.output_dir
end):table() :: any

local files_by_class = getFilesFromCanvas(API_KEY, BASE_URL, Classes)

local recent_files_by_class = filterRecentFiles(files_by_class, filter_days)

downloadFiles(recent_files_by_class, class_directories)
