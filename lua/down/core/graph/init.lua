---@generic N : any
---@type down.core.graph.Node<N>
local _node = require("down.core.graph.node")
---@generic E : any
---@type down.core.graph.Edge<E>
local _edge = require("down.core.graph.edge")

---@class down.core.graph.Graph<any, any>
---@field public nodes down.core.graph.node.Node<any>[]
---@field public edges down.core.graph.edge.Edge<any>[]
---@field public directed? boolean: directed
---@field public weighted? boolean: directed
---@field public N any
---@field public E any
local G = {
  N = nil,
  E = nil,
  edges = {},
  nodes = {},
  directed = false,
  weighted = false,
}

---@generic N : table | nil
---@generic E : table | nil
---@class down.core.graph.GraphInit<N, E> : down.core.graph.Graph<N, E>

---@generic N : table | nil
---@generic E : table | nil
---@return down.core.graph.Graph<N, E>
function G.new()
  ---@generic N
  ---@generic E
  ---@type down.core.graph.GraphInit<N, E>
  local g = {
  }
  return setmetatable(g, {
    __index = function(self, index)
      return self.nodes[index]
    end,
    __len = function(self)
      return #self.nodes
    end,
  })
end

return G
