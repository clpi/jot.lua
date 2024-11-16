local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("capture")

init.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["capture"] = {
        subcommands = {
          update = {
            args = 0,
            name = "capture.update"
          },
          insert = {
            name = "capture.insert",
            args = 0,
          },
        },
        name = "capture"
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
    ["capture.insert"] = true,
    ["capture.update"] = true,
  },
}

return init
