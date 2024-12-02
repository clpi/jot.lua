local M = Mod.create('lsp.completion.inline.value')

---@class lsp.completion.inline.value
M.data = {
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
