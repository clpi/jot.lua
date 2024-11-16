local d = require "word"

local M = d.mod.create("preview")

local mod, lib, u = d.mod, d.lib, d.utils

u.ns("word-preview")


M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      preview = {
        subcommands = {
          update = {
            args = 0,
            name = "preview.update"
          },
          insert = {
            name = "preview.insert",
            args = 0,
          },
        },
        name = "preview"
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
    ["preview.insert"] = true,
    ["preview.update"] = true,
  },
}


return M
