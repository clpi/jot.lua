local G = {}

local g = vim.g
local p = vim.lpeg

G.node = require("word.core.graph.node")
G.edge = require("word.core.graph.edge")

return G
