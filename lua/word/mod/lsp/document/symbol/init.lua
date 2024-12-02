local M = Mod.create("lsp.document.symbol")

---@class lsp.document.symbol
M.data = {
  ---@type lsp.DocumentSymbolClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    hierarchicalDocumentSymbolSupport = true,
    labelSupport = true,
    symbolKind = nil,
    tagSupport = nil,
  },
  ---@type lsp.DocumentSymbolOptions
  opts = {
    label = "Document Symbol",
    workDoneProgress = true,

  }
}

return M
