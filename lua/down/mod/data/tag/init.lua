local mod = require("down.mod")
local M = require("down.mod").new("data.tag")

---@return down.mod.Setup
M.setup = function()
  -- mod.await("cmd", function(cmd)
  --   cmd.add_commands_from_table({
  --     tag = {
  --       subcommands = {
  --         delete = {
  --           args = 0,
  --           name = 'data.tag.delete'
  --         },
  --         new = {
  --           args = 0,
  --           name = 'data.tag.new'
  --         },
  --         list = {
  --           name = 'data.tag.list',
  --           args = 0,
  --         },
  --       },
  --       name = 'tag'
  --     }
  --   })
  -- end)
  return {
    loaded = true,
    requires = { "workspace", "cmd" },
  }
end

---@class down.mod.data.tag.Data
M.data = {}

---@class down.mod.data.tag.Config
M.config = {}

---@class down.mod.data.tag.Subscribed
M.subscribed = {
  cmd = {
    ["data.tag.delete"] = true,
    ["data.tag.new"] = true,
    ["data.tag.list"] = true,
  },
}

M.on = function(e) end

return M
