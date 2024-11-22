local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("metadata")

init.load = function()
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



init.setup = function()
  return {
    success = true,
    requires = {
      "vault"
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
    ["metadata.insert"] = true,
    ["metadata.update"] = true,
  },
}

return init
