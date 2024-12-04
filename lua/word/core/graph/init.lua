---@generic N : any
---@type word.core.graph.Node<N>
local _node = require("word.core.graph.node")
---@generic E : any
---@type word.core.graph.Edge<E>
local _edge = require("word.core.graph.edge")

---@class word.core.graph.Graph<any, any>
---@field public nodes word.core.graph.node.Node<any>[]
---@field public edges word.core.graph.edge.Edge<any>[]
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
---@class word.core.graph.GraphInit<N, E> : word.core.graph.Graph<N, E>

---@generic N : table | nil
---@generic E : table | nil
---@return word.core.graph.Graph<N, E>
function G.new()
  ---@generic N
  ---@generic E
  ---@type word.core.graph.GraphInit<N, E>
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
