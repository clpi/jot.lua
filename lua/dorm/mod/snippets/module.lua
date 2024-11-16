local d = require("dorm")
local lib, mod = d.lib, d.mod

local module = mod.create("snippets")

module.load = function()
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
    ["snippets.insert"] = true,
    ["snippets.update"] = true,
  },
}

return module
