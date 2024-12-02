J = {}

local co = coroutine


local thr = co.create(function()
  local x = co.yield(job)
  return 12
end)

local cont, ret = co.resume(thr, x, y, z)

return J
