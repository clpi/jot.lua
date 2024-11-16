local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("encrypt")

init.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["encrypt"] = {
        subcommands = {
          update = {
            args = 0,
            name = "encrypt.update"
          },
          insert = {
            name = "encrypt.insert",
            args = 0,
          },
        },
        name = "encrypt"
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
    ["encrypt.insert"] = true,
    ["encrypt.update"] = true,
  },
}

return init
