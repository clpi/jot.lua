local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("pick")

init.load = function()
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
    ["pick.insert"] = true,
    ["pick.update"] = true,
  },
}

return init
