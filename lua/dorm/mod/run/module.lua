local d = require("dorm")
local lib, mod = d.lib, d.mod

local module = mod.create("run")

module.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["run"] = {
        subcommands = {
          update = {
            args = 0,
            name = "run.update"
          },
          insert = {
            name = "run.insert",
            args = 0,
          },
        },
        name = "run"
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
    ["run.insert"] = true,
    ["run.update"] = true,
  },
}

return module
