local C = {}

---@type word.core.parse.Parse
C.parse = require("word.core.parse")

---@type word.core.graph.Graph
C.graph = require("word.core.graph")

---@type word.core.graph.node.Node
C.node = require("word.core.graph.node")

---@type word.core.graph.edge.Edge
C.edge = require("word.core.graph.edge")

---@type word.core.data.Data
C.data = require("word.core.data")

---@type word.core.data.cache.Cache
C.cache = require("word.core.data.cache")

return C
