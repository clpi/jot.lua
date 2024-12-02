local D = Mod.create("lsp.document.link")

---@class lsp.document.link
D.data = {

  ---@type lsp.DocumentLinkRegistrationOptions
  registration = {
    ---@type lsp.DocumentSelector
    documentSelector = {
      scheme = "markdown",
    },
    workDoneProgress = true,
    resolveProvider = false,
  },
  ---@type lsp.DocumentLinkParams
  params = {
    ---@type lsp.TextDocumentIdentifier
    textDocument = {
      ---@type lsp.DocumentUri
      uri = vim.api.nvim_buf_get_name(0),
    },
  },
  ---@param params lsp.DocumentLinkParams
  ---@param cb fun(params: lsp.DocumentLinkParams, cb: fun(params: lsp.DocumentLinkParams): lsp.DocumentLink[], notify_cb: fun(params: lsp.DocumentLinkParams): lsp.DocumentLink[]): lsp.DocumentLink
  ---@param notify_cb fun(params: lsp.DocumentLinkParams): lsp.DocumentLink[]
  ---@return lsp.DocumentLink
  handle = function(params, cb, notify_cb)
    return {
      ---@type lsp.URI
      target = "",
      ---@type lsp.Range
      range = {
        start = {
          line = 1,
          character = 1,
        },
        ["end"] = {
          line = 1,
          character = 1,
        },
      },
    }
  end,
  ---@type lsp.DocumentLinkOptions
  opts = {
    resolveProvider = true,
    workDoneProgress = true,
  },
  ---@type lsp.DocumentLinkClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    tooltipSupport = true,
  },
}

return D
