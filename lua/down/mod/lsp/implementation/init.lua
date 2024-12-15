local I = Mod.create("lsp.implementation")

function I.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.implementation
I.data = {
  ---@type lsp.ImplementationOptions
  opts = { workDoneProgress = true },
  ---@type lsp.ImplementationClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    linkSupport = true,
  },
  ---@type lsp.Definition
  ---@type lsp.Handler
  ---@param err lsp.ResponseError
  ---@param context lsp.HandlerContext
  ---@param config? table
  ---@return ...any
  handler = function(err, context, config)
    vim.print(context)
  end,
}

return I
