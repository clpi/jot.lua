local uv = vim.uv
local e = vim.lpeg

local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("search")

init.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      agenda = {
        subcommands = {
          update = {
            args = 0,
            name = "agenda.update",
          },
          insert = {
            name = "agenda.insert",
            args = 0,
          },
        },
        name = "agenda",
      },
    })
  end)
end

init.setup = function()
  return {
    loaded = true,
    requires = {
      "workspace",
    },
  }
end

init.data = {}

init.config.public = {}
init.data.data = {}
init.events = {}

init.events.subscribed = {
  cmd = {
    ["agenda.insert"] = true,
    ["agenda.update"] = true,
  },
}

return init
