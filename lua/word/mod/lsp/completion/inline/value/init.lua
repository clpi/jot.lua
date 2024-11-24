local M = Mod.create('lsp.completion.inline.value')

---@class lsp.completion.inline.value
M.public = {
  workspace = {
    ---@type lsp.InlineValueWorkspaceClientCapabilities
    capabilities = {
      refreshSupport = true
    }

  },
  ---@type lsp.InlineValueClientCapabilities
  capabilities = {
    dynamicRegistration = true
  },
  ---@type lsp.InlineValueOptions
  opts = {
    workDoneProgress = true
  }

}
return M
