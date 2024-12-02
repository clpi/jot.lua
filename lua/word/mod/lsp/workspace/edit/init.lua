local M = Mod.create("lsp.workspace.edit")

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
