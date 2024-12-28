local Print = {}
local ffi = require("ffi")
local prof = require("jit.profile")
local jit = require("jit.util")
local co = require("coroutine")
local dbg = require("debug")
local buf = require("string.buffer")
local tbl = require("table.new")
local io = require("io")
local buf = require("string.buffer")

ffi.cdef [[
/* dt definitions */
typedef int dt_t;
]]

function Print.dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. Print.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function Print.table(table, level)
  local key = ""
  local func = function(table, level) end
  local func = function(table, level)
    level = level or 1
    local indent = ""
    for i = 1, level do
      indent = indent .. "  "
    end
    if key ~= "" then
      print(indent .. key .. " " .. "=" .. " " .. "{")
    else
      print(indent .. "{")
    end

    key = ""
    for k, v in pairs(table) do
      if type(v) == "table" then
        key = k
        func(v, level + 1)
      else
        local content = string.format("%s%s = %s", indent .. "  ", tostring(k), tostring(v))
        print(content)
      end
    end
    print(indent .. "}")
  end
  func(table, level)
end

return Print
