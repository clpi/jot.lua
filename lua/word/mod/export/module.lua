local d = require "word"
local mod = d.mod

local M = d.mod.create("export")


M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["export"] = {
        subcommands = {
          update = {
            args = 0,
            name = "export.update"
          },
          insert = {
            name = "export.insert",
            args = 0,
          },
        },
        name = "export"
      }
    })
  end)
end

M.setup = function()
  return {
    success = true,
    requires = {
      "workspace"
    }

  }
end

M.public = {

}

M.config.private = {

}
M.config.public = {

}
M.private = {

}
M.events = {}


M.events.subscribed = {
  cmd = {
    ["export.insert"] = true,
    ["export.update"] = true,
  },
}


return M
