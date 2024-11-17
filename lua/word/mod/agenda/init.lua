local uv = vim.uv

local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("agenda")

init.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["agenda"] = {
        subcommands = {
          update = {
            args = 0,
            name = "agenda.update"
          },
          insert = {
            name = "agenda.insert",
            args = 0,
          },
        },
        name = "agenda"
      }
    })
  end)
end



init.setup = function()
  return {
    success = true,
    requires = {
      "workspace"
    }

  }
end

init.public = {

}

init.config.private = {

}
init.config.public = {

}
init.private = {

}
init.events = {}


init.events.subscribed = {
  cmd = {
    ["agenda.insert"] = true,
    ["agenda.update"] = true,
  },
}

return init
