---@brief rest of modules are loaded
---@type string: name of config created
local M = require('down.mod').modules(
  'config',
  'ui',
  'edit',
  'data',
  'note',
  'cmd',
  'workspace',
  'tool.telescope',
  'tool.treesitter',
  'data',
  'lsp',
  'tool',
  'edit'
)

return M
