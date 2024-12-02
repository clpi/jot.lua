local T = {}

local ts = vim.treesitter
local th = ts.highlighter
local tq = ts.query
local buf = require("word.util.buf")
local tsu = require("nvim-treesitter.ts_utils")
local va = vim.api

---@param node vim.treesitter.dev.Node: The node
function T.node_text(node)
  local t = node.text
  local n = vim.treesitter
end

return T
