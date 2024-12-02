local S = Mod.create("lsp.workspace.config")

function S.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.workspace.config
S.data = {

  ---@type lsp.DidChangeConfigurationClientCapabilities
  capabilities = {
    dynamicRegistration = true,
  },
  ---@type lsp.DidChangeConfigurationRegistrationOptions
  opts = {
    section = "lsp.workspace.config",
    workDoneProgress = true,
  },
}

return S
