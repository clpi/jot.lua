local uv = vim.uv
local e = vim.lpeg

local d = require("word")
local lib, mod = d.lib, d.mod

local M = mod.create("edit.find")

M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      find = {
        subcommands = {
          update = {
            args = 0,
            name = "edit.find.update",
          },
          insert = {
            name = "edit.find.insert",
            args = 0,
          },
        },
        name = "edit.find",
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
    ["edit.find.insert"] = true,
    ["edit.find.update"] = true,
  },
}

return M
