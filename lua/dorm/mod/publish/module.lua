local d = require "dorm"

local M = d.mod.create("publish")


M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["publish"] = {
        subcommands = {
          update = {
            args = 0,
            name = "publish.update"
          },
          insert = {
            name = "publish.insert",
            args = 0,
          },
        },
        name = "publish"
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
    ["publish.insert"] = true,
    ["publish.update"] = true,
  },
}


return M
