---@generic N
---@type word.core.graph.Node<N>
local node = require("word.core.graph.node")
---@generic E
---@type word.core.graph.Edge<E>
local edge = require("word.core.graph.edge")

---@generic N
---@generic E
---@class word.core.graph.Graph<N, E>
---@field public nodes word.core.graph.edge.Node<any>[]
---@field public edges word.core.graph.edge.Edge<any>[]
---@field public directed? boolean: directed
local G = {
  edges = {},
  nodes = {},
  directed = false,
}

---@generic N
---@generic E
---@class word.core.graph.GraphInit<N, E> : word.core.graph.Graph<N, E>

---@generic N
---@generic E
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
