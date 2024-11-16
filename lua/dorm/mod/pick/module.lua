local d = require("dorm")
local lib, mod = d.lib, d.mod

local module = mod.create("pick")

module.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["pick"] = {
        subcommands = {
          update = {
            args = 0,
            name = "pick.update"
          },
          insert = {
            name = "pick.insert",
            args = 0,
          },
        },
        name = "pick"
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
    ["pick.insert"] = true,
    ["pick.update"] = true,
  },
}

return module
