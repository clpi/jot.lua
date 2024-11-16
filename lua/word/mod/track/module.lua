local d = require("word")
local lib, mod = d.lib, d.mod

local module = mod.create("track")

module.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["track"] = {
        subcommands = {
          update = {
            args = 0,
            name = "track.update"
          },
          insert = {
            name = "track.insert",
            args = 0,
          },
        },
        name = "track"
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
    ["track.insert"] = true,
    ["track.update"] = true,
  },
}

return module
