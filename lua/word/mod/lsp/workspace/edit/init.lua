local M = Mod.create("lsp.workspace.edit")

function M.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.workspace.edit
M.data = {
  ---@type lsp.WorkspaceEditClientCapabilities
  capabilities = {
    changeAnnotationSupport = {
      groupsOnLabel = true,
    },
    resourceOperations = {
      filterSupport = true,
    },
    failureHandling = {
      textOnlyTransactional = true,
    },
    versionSupport = true,
  },
}
return M
