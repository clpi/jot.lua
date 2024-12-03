local M = Mod.create("data.code.snippet")

M.setup = function()
  return {
    loaded = true,
    requires = { "workspace", "cmd" },
  }
end

M.load = function()
  Mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      snippet = {
        subcommands = {
          insert = {
            args = 0,
            name = "data.snippet.insert",
          },
          update = {
            name = "data.snippet.update",
            args = 0,
          },
        },
        name = "snippet",
      },
    })
  end)
end

M.config.public = {}

M.data.data = {}

M.data = {}

M.events.subscribed = {
  cmd = {
    ["data.snippet.insert"] = true,
    ["data.snippet.update"] = true,
  },
}

return M
