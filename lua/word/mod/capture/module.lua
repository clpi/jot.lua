local d = require("word")
local lib, mod = d.lib, d.mod

local module = mod.create("capture")

module.load = function()
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



module.setup = function()
  return {
    success = true,
    requires = {
      "workspace"
    }

  }
end

module.public = {

}

module.config.private = {

}
module.config.public = {

}
module.private = {

}
module.events = {}


module.events.subscribed = {
  cmd = {
    ["capture.insert"] = true,
    ["capture.update"] = true,
  },
}

return module
