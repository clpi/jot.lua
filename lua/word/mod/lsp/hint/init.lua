local M = Mod.create("lsp.hint")

---@class lsp.hint
M.data = {
  ---@param param lsp.InlayHintParams
  ---@param callback fun(hints: lsp.InlayHint[]):nil
  ---@param notify_reply_callback fun():nil
  ---@return nil
  handle = function(param, callback, notify_reply_callback)
    local hints = {
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
        kind = 1,
        label = "test",
      },
    }
    callback(hints)
    notify_reply_callback()
  end,
  ---@type lsp.InlayHintClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    resolveSupport = {
      properties = {
        "label",
      },
    }

  },
  ---@type lsp.InlayHintOptions
  opts = {
    resolveProvider = true,
    workDoneProgress = true,
  },
}

return M
