local d = require("jot")
local lib, mod = d.lib, d.mod

local M = Mod.create("data.sync")

M.load = function()
  Mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      sync = {
        subcommands = {
          update = {
            args = 0,
            name = "sync.update",
          },
          insert = {
            name = "sync.insert",
            args = 0,
          },
        },
        name = "sync",
      },
    })
  end)
end

M.setup = function()
  return {
    loaded = true,
    requires = {
      "cmd",
      "workspace",
    },
  }
end

M.public = {}

M.config = {}
M.public.data = {}
M.events = {}

M.events.subscribed = {
  cmd = {
    ["sync.insert"] = true,
    ["sync.update"] = true,
  },
}

return M
