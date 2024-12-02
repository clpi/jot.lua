local S = Mod.create("lsp.workspace.folders")
function S.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.workspace.folders
S.data = {
  client = {
    ---@type lsp.FoldingRangeWorkspaceClientCapabilities
    capabilities = {
      refreshSupport = true,
    },
  },
  server = {
    ---@type lsp.WorkspaceFoldersServerCapabilities
    capabilities = {
      changeNotifications = true,
      supported = true,
    },
  },
}

return S
