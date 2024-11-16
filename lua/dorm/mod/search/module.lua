local d = require("dorm")
local lib, mod = d.lib, d.mod

local module = mod.create("search")

module.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["search"] = {
        subcommands = {
          update = {
            args = 0,
            name = "search.update"
          },
          insert = {
            name = "search.insert",
            args = 0,
          },
        },
        name = "search"
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
    ["search.insert"] = true,
    ["search.update"] = true,
  },
}

return module
