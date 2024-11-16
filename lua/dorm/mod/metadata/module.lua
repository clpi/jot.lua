local d = require("dorm")
local lib, mod = d.lib, d.mod

local module = mod.create("metadata")

module.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["metadata"] = {
        subcommands = {
          update = {
            args = 0,
            name = "metadata.update"
          },
          insert = {
            name = "metadata.insert",
            args = 0,
          },
        },
        name = "metadata"
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
    ["metadata.insert"] = true,
    ["metadata.update"] = true,
  },
}

return module
