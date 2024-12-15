local config = require("down.config").config
local M = Mod.create("lsp.document", {
  "lens",
  "semantic",
  'action',
  "highlight",
  "fold",
  "format",
  "diagnostic",
  "symbol",
  "hint",
  "color",
  "hover",
  "link",
})

---@return down.mod.setup
M.setup = function()
  return {
    loaded = true,
    requires = {
      "workspace",
      "lsp.workspace",
    },
  }
end

---@class (exact) lsp.document.Config
M.config = {}

---@class lsp.document.Data
---@field doc lsp.document.Doc
---@field register lsp.TextDocumentRegistrationOptions
---@field opts lsp.LSPAny
---@field document lsp.document.Document
M.data = {
  ---@type lsp.TextDocumentRegistrationOptions
  register = {
    documentSelector = nil,
  },
  ---@type lsp.LSPAny
  opts = {},
  ---@class (exact) lsp.document.Document
  ---@field capabilities lsp.TextDocumentClientCapabilities
  ---@field register lsp.TextDocumentChangeRegistrationOptions
  ---@field save lsp.document.DocumentSave
  ---@field sync lsp.document.DocumentSync
  document = {
    ---@type lsp.TextDocumentClientCapabilities
    capabilities = {},
    ---@class (exact) lsp.TextDocumentChangeRegistrationOptions
    register = {
      syncKind = 2,
    },
    ---@class (exact) lsp.document.DocumentSave
    ---@field register lsp.TextDocumentSaveRegistrationOptions: register
    save = {
      ---@type lsp.TextDocumentSaveRegistrationOptions
      register = {},
    },
    ---@class (exact) lsp.document.DocumentSync
    ---@field opts lsp.TextDocumentSyncOptions
    ---@field capabilities lsp.TextDocumentSyncClientCapabilities
    sync = {
      ---@type lsp.TextDocumentSyncClientCapabilities
      capabilities = {},
      ---@type lsp.TextDocumentSyncOptions
      opts = {},
    },
  },
}
---@class (exact) lsp.document.Doc
---@field id string
---@field path lsp.document.Path
---@field title string
---@field uri lsp.DocumentUri
---@field workspace lsp.workspace.Workspace
M.data.doc = {
  id = "index.md",
  title = "index",
  ---@type lsp.workspace.Workspace
  workspace = {
    path = "~" .. config.pathsep,
    name = "default",
    default = true,
    notesDir = "note",
    logDir = "log",
    index = "index",
    ext = "md",
  },
  uri = "file://~" .. config.pathsep .. "index.md",
  ---@class (exact) lsp.document.Path
  ---@field rel string: Relative path from workspace
  ---@field abs string: Absolute path
  path = {
    abs = "~" .. config.pathsep .. "index.md",
    rel = "index.md",
  },
}

return M
