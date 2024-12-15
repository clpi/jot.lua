local mod = require("word.mod")

local M = mod.create("data.sync")

M.setup = function()
  --   mod.await("cmd", function(cmd)
  --     cmd.add_commands_from_table({
  --       sync = {
  --         subcommands = {
  --           update = {
  --             args = 0,
  --             name = "sync.update",
  --           },
  --           insert = {
  --             name = "sync.insert",
  --             args = 0,
  --           },
  --         },
  --         name = "sync",
  --       },
  --     })
  --   end)
  return {
    loaded = true,
    requires = {
      "cmd",
      "workspace",
    },
  }
end

M.data = {}

M.config.public = {}
M.data.data = {}
M.events = {}

M.events.subscribed = {
  cmd = {
    ["sync.insert"] = true,
    ["sync.update"] = true,
  },
}

return M
