local M = Mod.create("lsp.document.hover")

function M.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.document.hover.Data
M.data = {

  ---@type lsp.HoverOptions
  opts = {
    workDoneProgress = true,
  },

  ---@type lsp.HoverClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    contentFormat = { "markdown", "plaintext" },
  },

  ---@param params lsp.HoverParams
  ---@param callback fun(lsp.Hover):nil
  ---@param notify_reply_callback fun(lsp.Hover):nil
  ---@return nil
  handle = function(params, callback, notify_reply_callback)
    ---@type lsp.Hover
    local h = {
      contents = {
        value = "Hello, World!",
        kind = "markdown",
      },
      range = {
        start = {
          line = 0,
          character = 0,
        },
        ["end"] = {
          line = 0,
          character = 0,
        },
      },
    }
    callback(h)
    notify_reply_callback(h)
  end,
}

return M
