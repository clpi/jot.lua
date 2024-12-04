local C = {}

C.parse = require("word.core.parse")

---@type word.core.Graph
C.graph = require("word.core.graph")

---@type word.core.Node
C.node = require("word.core.graph").node

---@type word.core.graph.edge.Edge
C.edge = require("word.core.graph").edge

C.data = require("word.core.data")

return C
