--!strict
local net = require ("@lune/net")
local process = require "@lune/process"

local List = require("../LuauLists/Lists")
type str = string
local courses = {
      COMP3081 = "https://memphis.instructure.com/api/v1/courses/114134/files",
      COMP4030 = "https://memphis.instructure.com/api/v1/courses/114411/files"
}

-- local fetch_parms : net.FetchParams = {

-- }

local responses = List.frompairs(courses):map(function(value)
      -- return net.request(value[2])
end):each(function(resp)
      print(resp)
end)

res = process.spawn("curl", {"https://www.google.com"})
print(res.stdout)