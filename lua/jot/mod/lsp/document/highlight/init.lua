local M = Mod.create("lsp.document.highlight")

---@class lsp.document.highlight
M.public = {
  ---@type lsp.DocumentHighlightRegistrationOptions
  registration = {
    workDoneProgress = true,
    documentSelector = nil,
  },
  ---@type lsp.DocumentHighlightOptions
  opts = {
    workDoneProgress = true,
  },
  ---@type lsp.DocumentHighlightClientCapabilities
  capabilities = {
    dynamicRegistration = true,
  },
}
return M
