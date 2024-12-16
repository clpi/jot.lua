local M = require("down.mod").modules(
---@type string: name of config created
  "config",
  ---@brief rest of modules are loaded
  "ui",
  "edit",
  "note",
  "cmd",
  "workspace",
  "tool.telescope",
  "tool.treesitter",
  "data",
  "lsp",
  "edit"
)

return M
