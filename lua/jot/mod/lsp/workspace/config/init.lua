local S = Mod.create("lsp.workspace.config")


---@class lsp.workspace.config
S.public = {

  ---@type lsp.DidChangeConfigurationClientCapabilities
  capabilities = {
    dynamicRegistration = true,

  },
  ---@type lsp.DidChangeConfigurationRegistrationOptions
  opts = {
    section = "lsp.workspace.config",
    workDoneProgress = true,

  }
}

return S
