J = {}

local p = require("lpeg")
local a = require("async")
local co = coroutine

local job = a.sync(function()

end)

local thr = co.create(function()
  local x = co.yield(job)
  return 12
end)

local cont, ret = co.resume(thr, x, y, z)

return J
