local d = require "word"
local mod, u = d.mod, d.utils

u.ns("word-lsp")
local M = d.mod.create("lsp")

M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      ["lsp"] = {
        subcommands = {
          update = {
            args = 0,
            name = "lsp.update"
          },
          insert = {
            name = "lsp.insert",
            args = 0,
          },
        },
        name = "lsp"
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
    ["lsp.insert"] = true,
    ["lsp.update"] = true,
  },
}


return M
