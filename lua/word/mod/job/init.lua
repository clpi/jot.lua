local uv = vim.uv

local d = require("word")
local lib, mod = d.lib, d.mod

local init = mod.create("job")

init.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["job"] = {
        subcommands = {
          update = {
            args = 0,
            name = "job.update"
          },
          insert = {
            name = "job.insert",
            args = 0,
          },
        },
        name = "job"
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
    ["job.insert"] = true,
    ["job.update"] = true,
  },
}

return init
