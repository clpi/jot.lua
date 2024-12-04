local C = Mod.create("lsp.command")

function C.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.command.Config
C.config.public = {
}

---@class lsp.command.Data
C.data = {

  ---@type fun(p: lsp.ExecuteCommandParams)
  handler = function(p)
    local c = C.data.commands[p.command]
    if c then c(p.arguments) end
  end,

  commands = {

  },

  open_file = function(uri)
    local vu = require("vim.ui")
    vu.open(uri)
  end,

  open_uri = function(uri)
    local vu = require("vim.ui")
    vu.open(uri)
  end,

  ---@type lsp.ServerCapabilities
  server = {
    executeCommandProvider = {
      commands = {
        {

        }
      },
    },
  },
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
  end
}
C.config.public = {

  enable = true,
}

return C
