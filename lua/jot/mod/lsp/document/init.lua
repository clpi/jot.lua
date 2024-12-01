local M = Mod.create("lsp.document", {
  "lens",
  "highlight",
  "fold",
  "format",
  "diagnostic",
  "symbol",
  "color",
  "link",
})

---@class lsp.document
M.public = {
  ---@type lsp.Options
  opts = {

  },
  document = {
    ---@type lsp.TextDocumentClientCapabilities
    opts = {


    },
    change = {
      ---@type lsp.Tex
      ---@type lsp.TextDocumentChangeRegistrationOptions
      opts = {

      }

    },
    save = {


      ---@type lsp.TextDocumentSaveRegistrationOptions
      opts = {

      }
    }
  },
  sync = {
    ---@type lsp.TextDocumentSyncOptions
    opts = {

    }


  }
}

return M
