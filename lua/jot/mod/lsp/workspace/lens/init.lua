local M = Mod.create("lsp.workspace.lens")

---@class lsp.workspace.lens
M.public = {
  ---@type lsp.CodeLensWorkspaceClientCapabilities
  capabilities = {
    refreshSupport = true,
  },
  ---@type lsp.CodeLensOptions
  opts = {
    workDoneProgress = true,
    resolveProvider = true,


  },

  ---@param param lsp.CodeLensParams
  ---@param callback fun(codeLens: lsp.CodeLens[]):nil
  ---@param notify_reply_callback fun():nil
  ---@return nil
  handle = function(param, callback, notify_reply_callback)
    ---@type lsp.URI
    local uri = param.textDocument.uri
    ---@type lsp.CodeLens[]
    local cl = {
      {
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
        command = {
          command = "test",
          title = "test",
          arguments = {
            "test",
          },
        },
      },
    }
    callback(cl)
    notify_reply_callback()
  end,
}

return M
