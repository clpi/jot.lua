local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("template")

init.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      template = {
        name = "template",
        subcommands = {
          list = {
            name = "template.list",
            args = 1, --filetype
          },
          edit = {
            name = "template.edit",
            args = 1, --filetype
          },
          new = {
            name = "template.new",
            argss = 1, -- filetype, ...
          },
          update = {
            args = 0,
            name = "template.update"
          },
          insert = {
            name = "template.insert",
            args = 0,
          },
        },
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
    ["template.new"] = true,
    ["template.edit"] = true,
    ["template.insert"] = true,
    ["template.update"] = true,
  },
}

return init
