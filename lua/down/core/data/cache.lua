---@class down.core.data.cache.Cache
---@field public head any
---@field public tail any
---@field public len integer
---@field public cache table<any, any>
---@field public cap integer
local Cache = {}

Cache.__index = Cache

function Cache.newcache() end

function Cache.new(cap)
  local c = {
    head = nil,
    tail = nil,
    len = 0,
    cap = cap,
    cache = { }
  }
  return setmetatable({
    __index = c,
  }, c)
end

Cache.__len = function()
  return Cache.len
end

function Cache:set(k, v)
  self.cache[k] = v
end

function Cache.__newindex(self, k, v)
  self.set(k, v)
end

Cache.__tostring = function(self)
  local s = ""
  for ii, i in ipairs(self.cache) do
    s = s .. tostring(ii) .. tostring(i)
  end
  return s
end

function Cache:del() end

function Cache:clear() end

function Cache:get() end

return Cache
