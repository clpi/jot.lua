local M = require('down.mod').create('lsp.workspace', {
  'lens',
  'tag',
  'config',
  'folders',
  'edit',
  'diagnostic',
  'file',
  'symbol',
})

function M.setup()
  return {
    requires = {
      'workspace',
    },
    loaded = true,
  }
end

---@class lsp.workspace.Config
M.config = {}
---@class lsp.workspace.Data
---@field workspace lsp.workspace.Workspace
---@field capabilities lsp.WorkspaceClientCapabilities
M.data = {
  ---@type lsp.WorkspaceClientCapabilities
  capabilities = {},
}

---@class (exact) lsp.workspace.Workspace
---@field name string
---@field path string
---@field index string: Index file
---@field notesDir string: Notes dir
---@field logDir string: Notes dir
---@field default boolean: Is default workspace
---@field ext string: extension
M.data.workspace = {
  notesDir = 'notes',
  logDir = 'log',
  path = '~/',
  default = true,
  ext = 'md',
  name = 'default',
  index = 'index',
}

return M
