--!strict
-- by dev chrysalis

-- downloads recent files of canvas so we don't have to :p 

local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local datetime = require("@lune/datetime")
local fromIsoDate = datetime.fromIsoDate

local List = require("libraries/Lists")

assert(fs.isFile(".config.jsonc"), "no .config.jsonc found! please copy the template jsonc and add the relevant info and save it as '.config.jsonc' within this directory.")

local raw_config = fs.readFile(".config.jsonc"):gsub("%s//[%w%p ]*\n", "") -- need to remove comments from jsonc at runtime :/
local config = net.jsonDecode(raw_config)

type ClassInfo = {classid: string, output_dir: string}

local API_KEY = config.CANVAS_API_KEY
local BASE_URL = config.BASE_URL .. "/api/v1/courses/"
local Classes : {[string]: ClassInfo} = config.Classes

local invalid_dirs = List.frompairs(Classes):map_values(function(key, info: ClassInfo)
      if not fs.isDir(info.output_dir) then
            return info.output_dir
      end
      return nil
end)

if invalid_dirs.length > 0 then
      print(invalid_dirs.length)
      print("Error: invalid output_dirs:")
      print(invalid_dirs)
      process.exit(1)
end
      
local function callAPI(url)
      local response = process.spawn("curl", {`{url}access_token={API_KEY}`})
      if response.ok then
            return response.stdout
      end
      return response.stderr
end


-- get all recent files in every class
local sort_query = "/files?sort=created_at&order=desc&"
local select_fields = List.new("display_name", "filename", "id", "updated_at", "url")

local files_by_class = List.mappairs(Classes, function(class: string, info : ClassInfo)

      local files = net.jsonDecode(callAPI(BASE_URL .. info.classid .. sort_query))

      return class, List.from(files):map(function(file)
            return select_fields:map(function(key)
                  local value = file[key]
                  return {key, if key == "updated_at" then fromIsoDate(value).unixTimestamp else value}
            end):table()
      end):array()
      
end)

-- filter only recent files
local seconds_in_day = 24 * 60^2
local today_unix = datetime.now().unixTimestamp

local files_updated_last_2_days = List.frompairs(files_by_class):remap_values_in_value(function(file)
      if today_unix - file.updated_at < 2 * seconds_in_day then
            return {
                  filename = file.filename,
                  download_link = file.url
            }
      end
      return nil
end):table()
      
-- now we actually get to downloading files!!
local function downloadFileToPath(file: {filename: string, download_link: string}, path: string)
      local full_path = `{path}/{file.filename}`
      local result = process.spawn("curl", {`-o{file.filename}`, file.download_link}, {
            cwd = path
      })
      if result.ok then
            print(`Successfully downloaded {file.filename}!!! to \n  {full_path}`)
      else
            print("DOWNLOAD ERROR")
            print(result.stderr)
      end
end

for class, files in files_updated_last_2_days do 
      local target_directory = Classes[class].output_dir
      local existing_files = List.from(fs.readDir(target_directory))

      List.from(files):each(function(file)
            if existing_files:has(file.filename) then
                  print(file.filename .. " already exists; not downloading.")
                  return
            else
                  downloadFileToPath(file, target_directory)
            end
      end)
end

