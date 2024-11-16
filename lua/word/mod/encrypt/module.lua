local d = require("word")
local lib, mod = d.lib, d.mod

local module = mod.create("encrypt")

module.load = function()
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
    ["encrypt.insert"] = true,
    ["encrypt.update"] = true,
  },
}

return module
