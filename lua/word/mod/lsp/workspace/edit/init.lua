local M = Mod.create("lsp.workspace.edit")

---@class lsp.workspace.edit
M.public = {
  ---@type lsp.WorkspaceEditClientCapabilities
  capabilites = {
    changeAnnotationSupport = {
      groupsOnLabel = true
    },
    resourceOperations = {
      filterSupport = true
    },
    failureHandling = {
      textOnlyTransactional = true
    },
    versionSupport = true

  }
}
return M
