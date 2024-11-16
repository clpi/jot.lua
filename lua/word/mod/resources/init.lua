local d = require "word"
local mod = d.mod

local M = d.mod.create("resources")


M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["resources"] = {
        subcommands = {
          update = {
            args = 0,
            name = "resources.update"
          },
          insert = {
            name = "resources.insert",
            args = 0,
          },
        },
        name = "resources"
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
    ["resources.insert"] = true,
    ["resources.update"] = true,
  },
}


return M
