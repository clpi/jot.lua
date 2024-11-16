local d = require("dorm")
local lib, mod = d.lib, d.mod

local module = mod.create("sync")

module.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["sync"] = {
        subcommands = {
          update = {
            args = 0,
            name = "sync.update"
          },
          insert = {
            name = "sync.insert",
            args = 0,
          },
        },
        name = "sync"
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
    ["sync.insert"] = true,
    ["sync.update"] = true,
  },
}

return module
