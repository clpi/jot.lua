local mod = require('down.mod')
local io, os, bit = require('io'), require('os'), require('bit')
local E = mod.new('data.encrypt')

E.commands = {
  encrypt = {
    subcommands = {
      file = {
        args = 0,
        name = 'data.encrypt.update',
      },
      workspace = {
        name = 'data.encrypt.insert',
        args = 0,
      },
    },
    name = 'data.encrypt',
  },
}
E.setup = function()
  return {
    loaded = true,
    requires = {
      'tool.treesitter',
      'cmd',
      'workspace',
    },
  }
end

---@class down.data.encrypt.Config
E.config = {}

---@class down.data.encrypt.Data
E.data = {}

E.handle = function(e) end

E.subscribed = {
  cmd = {
    ['data.encrypt'] = true,
    ['data.encrypt.insert'] = true,
    ['data.encrypt.update'] = true,
  },
}

return E
