local C = {}


---@type down.core.parse.Parse
C.parse = require("down.core.parse")

---@type down.core.graph.Graph
C.graph = require("down.core.graph")

---@type down.core.graph.node.Node
C.node = require("down.core.graph.node")

---@type down.core.graph.edge.Edge
C.edge = require("down.core.graph.edge")

---@type down.core.data.Data
C.data = require("down.core.data")

---@type down.core.data.cache.Cache
C.cache = require("down.core.data.cache")

return C
