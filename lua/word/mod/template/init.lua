local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("template")

init.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["template"] = {
        subcommands = {
          update = {
            args = 0,
            name = "template.update"
          },
          insert = {
            name = "template.insert",
            args = 0,
          },
        },
        name = "template"
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
    ["template.insert"] = true,
    ["template.update"] = true,
  },
}

return init
