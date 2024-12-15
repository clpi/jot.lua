local mod = require("down.mod")
local M = mod.create("data.save")

M.setup = function()
  -- mod.await("cmd", function(cmd)
  --   cmd.add_commands_from_table({
  --     save = {
  --       subcommands = {
  --         current = {
  --           args = 0,
  --           name = "data.save.current",
  --         },
  --         new = {
  --           name = "data.save.new",
  --           args = 0,
  --         },
  --       },
  --       name = "save",
  --     },
  --   })
  -- end)
  return {
    loaded = true,
    required = {
      "cmd",
      "workspace",
    },
  }
end

---@class down.data.save.Config
M.config = {}

---@class down.data.save.Data
M.data = {}

M.events.subscribed = {
  cmd = {
    ["data.save.current"] = true,
    ["data.save.new"] = true,
  },
}

return M
