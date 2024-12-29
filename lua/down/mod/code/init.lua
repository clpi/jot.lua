local mod = require('down.mod')

--- @class down.mod.Code: down.Mod
local Code = mod.new('code', { 'snippet', 'run' })

--- @class down.mod.code.Config
---   @field languages string[]
Code.config = {
  --- What languages to support
  languages = {},
}

--- @class down.mod.code.Data
Code.data = {
  ---@type table<string, string>
  code = {},
}

Code.commands = {
  code = {
    name = "code",
    condition = "markdown",
    args = 1,
    subcommands = {
      edit = {
        args = 0,
        name = "code.edit",
      },
      run = {
        args = 0,
        name = "code.run",
      },
      save = {
        args = 0,
        name = "code.save",
      }
    }
  }
}

Code.load = function()
end

Code.setup = function()
  return {
    loaded = true,
    requires = {
      'cmd',
      'workspace',
    },
  }
end

return Code
