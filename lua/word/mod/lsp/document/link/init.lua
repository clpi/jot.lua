local D = Mod.create("lsp.document.link")

---@class lsp.document.link.Data
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

---@class (exact) lsp.document.link.Wikilink
---@field public target string: doc
---@field public doc? string: doc
---@field public heading? string | nil: doc
D.data.wikilink = {
  target = "index",
  doc = "# index",
  heading = nil,
}
---@class (exact) lsp.document.link.LinkRef
---@field public content string
---@field public kind lsp.document.link.LinkRefKind: 'full' | 'collapsed' | 'shortcut'
---@field public target? string
D.data.ref = {
  ---@type string
  content = "link",
  ---@type string | nil
  target = nil,
  ---@alias lsp.document.link.LinkRefKind "shortcut"|"full"|"collapsed"
  kind = "shortcut",
}

---@class (exact) lsp.document.link.DocumentLink
---@field text string: text
---@field url? string: url target
---@field anchor? string: anchor
D.data.link = {
  url = "file://./",
  anchor = "",
  text = "",
}

---@alias lsp.document.link.Link lsp.document.link.Wikilink|lsp.document.link.LinkRef|lsp.document.link.DocumentLink

return D
