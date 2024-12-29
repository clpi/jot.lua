local mod = require('down.mod')
local E = Mod.new('data.export')

E.commands = {
  export = {
    subcommands = {
      file = {
        args = 0,
        name = 'data.export.update',
      },
      workspace = {
        name = 'data.export.insert',
        args = 0,
      },
    },
    name = 'export',
  },
}

E.setup = function()
  return {
    loaded = true,
    dependencies = {
      'tool.treesitter',
      'cmd',
      'workspace',
    },
  }
end

---@class down.data.export.Config
E.config = {}

---@class down.data.export.Data
E.data = {}

E.handle = function(e) end

E.handle = {
  cmd = {
    ['data.export.insert'] = function(e) end,
    ['data.export.update'] = function(e) end,
  },
}

return E
