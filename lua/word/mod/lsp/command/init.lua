local C = Mod.create("lsp.command")

function C.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.command
C.data = {

  ---@type lsp.ExecuteCommandClientCapabilities
  capabilities = {
    dynamicRegistration = true,
  },
  ---@type lsp.ExecuteCommandOptions
  opts = {
    workDoneProgress = true,
    commands = {
      "test",
      "chat",
    },
  },

  ---@param params lsp.ExecuteCommandParams
  handle = function(params)
    if params.command == "test" then
      vim.notify("test")
    elseif params.command == "chat" then
      vim.notify("chat")
    end
    return {

      loaded = true,
    }
  end,
}
C.config.public = {

  enable = true,
}

return C
