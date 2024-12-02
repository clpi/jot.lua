local uv = vim.uv
local e = vim.lpeg

local d = require("word")
local lib, mod = d.lib, d.mod

local M = mod.create("find")

M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      find = {
        subcommands = {
          update = {
            args = 0,
            name = "find.update",
          },
          insert = {
            name = "find.insert",
            args = 0,
          },
        },
        name = "find",
      },
    })
  end)
end

M.setup = function()
  return {
    loaded = true,
    requires = {
      "workspace",
    },
  }
end

M.data = {}

M.config.public = {}
M.data.data = {}
M.events = {}

M.events.subscribed = {
  cmd = {
    ["find.insert"] = true,
    ["find.update"] = true,
  },
}

return M
