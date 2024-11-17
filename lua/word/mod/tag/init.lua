local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("tag")

init.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["tag"] = {
        subcommands = {
          update = {
            args = 0,
            name = "tag.update"
          },
          insert = {
            name = "tag.insert",
            args = 0,
          },
        },
        name = "tag"
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
    ["tag.insert"] = true,
    ["tag.update"] = true,
  },
}

return init
