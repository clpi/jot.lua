---@type down.Mod
local M = require "down.mod".create("data.sync")

---@return down.mod.Setup
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
  ---@type down.mod.Setup
  return {
    loaded = true,
    requires = {
      "cmd",
      "workspace",
    },
  }
end

---@class down.mod.data.sync.Data
M.data = {}

---@class down.mod.data.sync.Config
M.config = {}

---@return down.mod.data.sync.Events
M.events = {}

---@class down.mod.data.sync.Subscribed
M.subscribed = {
  cmd = {
    ["sync.insert"] = true,
    ["sync.update"] = true,
  },
}

return M
