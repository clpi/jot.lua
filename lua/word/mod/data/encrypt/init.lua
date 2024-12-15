local mod = require("word.mod")
local E = mod.create("data.encrypt")

E.setup = function()
  -- mod.await("cmd", function(cmd)
  --   cmd.add_commands_from_table({
  --     encrypt = {
  --       subcommands = {
  --         file = {
  --           args = 0,
  --           name = "data.encrypt.update",
  --         },
  --         workspace = {
  --           name = "data.encrypt.insert",
  --           args = 0,
  --         },
  --       },
  --       name = "encrypt",
  --     },
  --   })
  -- end)
  return {
    loaded = true,
    requires = {
      "integration.treesitter",
      "cmd",
      "workspace",
    },
  }
end

---@class word.data.encrypt.Config
E.config.public = {}

---@class word.data.encrypt.Data
E.data = {}

E.on = function(e) end

E.events.subscribed = {
  cmd = {
    ["data.encrypt.insert"] = true,
    ["data.encrypt.update"] = true,
  },
}

return E
