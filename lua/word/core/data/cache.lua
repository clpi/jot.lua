local Cache = {}

Cache.__index = Cache

function Cache.newcache() end

function Cache:new(cap)
  return setmetatable({
    cap = cap,
    cache = setmetatable({
      __index = self,
      __newindex = function(k, v)
        self[k] = v
      end,
    }, self.cache),
    head = nil,
    tail = nil,
    len = 0,
  }, Cache)
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
