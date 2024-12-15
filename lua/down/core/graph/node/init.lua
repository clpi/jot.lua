---@generic N
---@class down.core.graph.node.NodeInit<N>
---@field public data table<string, any>|nil
---@field public id string
---@field public kind string: the datatype kind
---
---@generic N
---@class down.core.graph.node.Node<N>
---@field public data? table<string, any>
---@field public id string
---@field public kind string: the datatype kind
local Node = {
}

---@alias down.core.graph.Node down.core.graph.node.Node

---@generic N any
---@param id string: the id
---@param kind string: the datatype kind
---@param data? table<string, N>: The data to be stored in the node.
---@return down.core.graph.node.Node<N>
function Node.new(id, kind, data)
  ---@type down.core.graph.node.NodeInit
  local node = { data = data or nil, kind = kind, id = id }
  ---@type down.core.graph.node.Node
  return setmetatable(node, {
    __index    = node,
    __pairs = function(self)
      local d = self.data or self
      return pairs(d)
    end,
    __ipairs = function(self)
      local d = self.data or self
      return ipairs(d)
    end,
    __name     = node.id,
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

-- function node:__tostring() end

return Node
