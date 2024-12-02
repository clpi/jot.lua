local M = Mod.create("lsp.workspace.symbol")


---@class lsp.workspace.symbol
M.data = {
  ---@type lsp.WorkspaceSymbolClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits"
      }
    },
    ---@type lsp.SymbolKind[]
    symbolKind = {
      1, 2, 3, 4
    },
    tagSupport = {
      valueSet = {
        1,
      }
    },


  },
  ---@type lsp.WorkspaceSymbolOptions
  opts = {
    resolveProvider = true,
    workDoneProgress = true

  }
}
return M
