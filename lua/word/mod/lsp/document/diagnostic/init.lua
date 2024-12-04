local M = Mod.create("lsp.document.diagnostic")

M.setup = function()
  return {
    loaded = true,
  }
end

---@class lsp.document.diagnostic.Config
M.config.public = {

}

---@enum lsp.diagnostic.mode
M.data.mode = {
  "enabled",
  "disable-line",
  "disable-document",
}

M.load = function() end

---@class lsp.document.diagnostic.Data
M.data = {
  ---@type lsp.DiagnosticRegistrationOptions
  registration = {

    workDoneProgress = true,
    interFileDependencies = true,
    workspaceDiagnostics = true,
    documentSelector = {
      scheme = "file",
      language = "markdown",
    },
    id = "markdown-diagnostic",
    identifier = "textDocument/diagnostic",
  },
  ---@type lsp.DiagnosticOptions
  opts = {
    workDoneProgress = true,
    identifier = "textDocument/diagnostic",
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
