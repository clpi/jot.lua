local M = Mod.create("lsp.workspace", {
  "lens",
  "config",
  "folders",
  "edit",
  "diagnostic",
  "fileops",
  "symbol",
})

---@class lsp.workspace
M.public = {
  ---@type lsp.WorkspaceClientCapabilities
  capabilities = {



  }
}

return M
