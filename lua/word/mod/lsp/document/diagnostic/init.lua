local M = Mod.create("lsp.document.diagnostic")

M.setup = function()
  return {
    loaded = true,
  }
end

M.load = function() end

---@class lsp.document.diagnostic
M.data = {
  ---@type lsp.DiagnosticRegistrationOptions
  registration = {

    workDoneProgress = true,
    interFileDependencies = true,
    workspaceDiagnostics = true,
    documentSelector = {
      scheme = "file",
      language = "markdown"
    },
    id = "markdown-diagnostic",
    identifier = "document/diagnostic",
  },
  ---@type lsp.DiagnosticOptions
  opts = {
    workDoneProgress = true,
    identifier = "document/diagnostic",
    interFileDependencies = true,
    workspaceDiagnostics = true,

  },
  ---@type lsp.DiagnosticClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    markupMessageSupport = true,
    relatedDocumentSupport = true,
  },
}

return M
