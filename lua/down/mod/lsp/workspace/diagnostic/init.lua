local S = Mod.create("lsp.workspace.diagnostic")

function S.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.workspace.diagnostic
S.data = {
  ---@type lsp.PublishDiagnosticsClientCapabilities
  capabilities = {
    dataSupport = true,
    tagSupport = {
      valueSet = {
        1,
        2,
        3,
        4,
      },
    },
    versionSupport = true,
    codeDescriptionSupport = true,
    relatedInformation = true,
  },
  ---@type lsp.DiagnosticOptions
  opts = {
    interFileDependencies = true,
    workDoneProgress = true,
    identifier = "workspace/diagnostic",
    ---@type lsp.WorkspaceDiagnosticReport
    workspaceDiagnostics = {
      items = {},
    },
  },
}

return S
