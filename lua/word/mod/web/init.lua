local d = require("word")
local lib, mod = d.lib, d.mod

local M = mod.create("web")

M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      web = {
        name = "web",
        subcommands = {
          serve = {
            args = 0,
            name = "web.serve"
          },
          build = {
            name = "web.build",
            args = 0,
          },
        },
      }
    })
  end)
end



M.setup = function()
  return {
    success = true,
    requires = {
      "workspace"
    }

  }
end

M.public = {

}

M.config.private = {

}
M.config.public = {

}
M.private = {

}
M.events = {}


M.events.subscribed = {
  cmd = {
    ["web.build"] = true,
    ["web.serve"] = true,
  },
}

return M
