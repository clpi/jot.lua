---@generic E
---@class down.core.graph.edge.EdgeInit<E>
---@field public data table<string, any>|nil
---@field public id string
---@field public kind string: the datatype kind
---@field public a string: node id from
---@field public b string: node id from
---
---@generic E
---@class down.core.graph.edge.Edge<E>
---@field public data table<string, any>|nil
---@field public id string
---@field public a string: node id from
---@field public b string: node id from
---@field public kind string: the datatype kind
local Edge = {
}

---@alias down.core.graph.Edge down.core.graph.edge.Edge

---@generic E any
---@param a string: node id from
---@param b string: node id from
---@param id string: the id
---@param kind string: the datatype kind
---@param data table<string, E>|nil: The data to be stored in the edge.
---@return down.core.graph.edge.Edge<E>
function Edge.new(a, b, id, kind, data)
  ---@type down.core.graph.edge.EdgeInit
  local edge = {
    a = a, b = b,
    data = data or nil, kind = kind, id = id
  }
  ---@type down.core.graph.edge.Edge
  return setmetatable(edge, {
    __index    = edge,
    __pairs = function(self)
      local d = self.data or self
      return pairs(d)
    end,
    __ipairs = function(self)
      local d = self.data or self
      return ipairs(d)
    end,
    __name     = edge.id,
    __len      = function(self)
      local d = self.data or self
      return #d
    end,
    __eq       = function(self, other)
      return self.kind == other.kind and self.id == other.id
    end,
    __tostring = function(self)
      return self.id
    end,
    __newindex = function(self, key, value)
      local d = self.data or self
      d[key] = value
    end,
  })
end

-- function edge:__tostring() end

return Edge
