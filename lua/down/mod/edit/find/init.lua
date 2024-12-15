local uv = vim.uv
local e = vim.lpeg

local d = require("down")
local lib, mod = d.lib, d.mod

local M = mod.create("edit.find")

M.setup = function()
  -- mod.await("cmd", function(cmd)
  --   cmd.add_commands_from_table({
  --     find = {
  --       subcommands = {
  --         update = {
  --           args = 0,
  --           name = "edit.find.update",
  --         },
  --         insert = {
  --           name = "edit.find.insert",
  --           args = 0,
  --         },
  --       },
  --       name = "edit.find",
  --     },
  --   })
  -- end)
  return {
    loaded = true,
    requires = {
      "workspace",
    },
  }
end

---@class down.edit.find.Data
M.data = {}

---@class down.edit.find.Config
M.config = {}
M.events = {}

M.events.subscribed = {
  cmd = {
    ["edit.find.insert"] = true,
    ["edit.find.update"] = true,
  },
}

return M
