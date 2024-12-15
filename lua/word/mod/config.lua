local M = require("word.mod").modules(
---@type string: name of config created
  "config",
  ---@brief rest of modules are loaded
  "ui",
  "edit",
  "note",
  "cmd",
  "workspace",
  "integration.telescope",
  "integration.treesitter",
  "data",
  "lsp",
  "edit"
)

return M
