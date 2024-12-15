local M = require("down.mod").create("lsp.document.lens")

---@class lsp.document.lens
M.data = {
  ---@type lsp.CodeLensOptions
  opts = {
    resolveProvider = true,
    workDoneProgress = true,

  },
  ---@type lsp.CodeLensRegistrationOptions
  registration = {
    documentSelector = {
      scheme = "file",
      language = "markdown",
    },
    id = "markdown-lens",
    workDoneProgress = true,
  },
  ---@type lsp.CodeLensClientCapabilities
  capabilities = {
    dynamicRegistration = true,
  },
}

return M
