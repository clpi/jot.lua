local mod = require("word.mod")
local M = mod.create("data.tag")

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

M.config.public = {}

M.data = {}

M.events = {}

M.events.subcribed = {
  cmd = {
    ["data.tag.delete"] = true,
    ["data.tag.new"] = true,
    ["data.tag.list"] = true,
  },
}

M.on = function(e) end

return M
