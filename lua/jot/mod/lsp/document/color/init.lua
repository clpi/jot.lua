local M = Mod.create("lsp.document.color")

---@class lsp.document.color
M.public = {
  ---@param param lsp.DocumentColorParams
  ---@param callback fun(hints: lsp.Color[]):nil
  ---@param notify_reply_callback fun():nil
  ---@return nil
  handle = function(param, callback, notify_reply_callback)
    callback(hints)
    notify_reply_callback()
  end,
  ---@type lsp.DocumentColorClientCapabilities
  capabilities = {
    dynamicRegistration = true,

  },
  ---@type lsp.DocumentColorRegistrationOptions
  registration = {
    documentSelector = {
      scheme = "file",
      language = "markdown",
    },
    id = "markdown-color",
    workDoneProgress = true,

  },
  ---@type lsp.DocumentColorOptions
  opts = {
    resolveProvider = true,
    workDoneProgress = true,
  },
}

return M
