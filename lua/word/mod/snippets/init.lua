local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("snippets")

init.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["snippets"] = {
        subcommands = {
          update = {
            args = 0,
            name = "snippets.update"
          },
          insert = {
            name = "snippets.insert",
            args = 0,
          },
        },
        name = "snippets"
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
    ["snippets.insert"] = true,
    ["snippets.update"] = true,
  },
}

return init
