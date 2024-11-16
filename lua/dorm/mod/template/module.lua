local d = require("dorm")
local lib, mod = d.lib, d.mod

local module = mod.create("template")

module.load = function()
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
    ["template.insert"] = true,
    ["template.update"] = true,
  },
}

return module
