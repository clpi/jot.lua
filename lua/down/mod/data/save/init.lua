local mod = require("down.mod")
local M = mod.create("data.save")

---@return down.mod.Setup
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
  ---@type down.mod.Setup
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

---@class down
M.subscribed = {
  cmd = {
    ["data.save.current"] = true,
    ["data.save.new"] = true,
  },
}

return M
