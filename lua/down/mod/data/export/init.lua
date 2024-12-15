local mod = require("down.mod")
local E = Mod.create("data.export")

E.setup = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      export = {
        subcommands = {
          file = {
            args = 0,
            name = "data.export.update",
          },
          workspace = {
            name = "data.export.insert",
            args = 0,
          },
        },
        name = "export",
      },
    })
  end)
  return {
    loaded = true,
    requires = {
      "integration.treesitter",
      "cmd",
      "workspace",
    },
  }
end

---@class down.data.export.Config
E.config = {}

---@class down.data.export.Data
E.data = {}

E.on = function(e) end

E.events.subscribed = {
  cmd = {
    ["data.export.insert"] = true,
    ["data.export.update"] = true,
  },
}

return E
