local M = Mod.create("data.metadata")

M.setup = function()
  return {
    loaded = true,
    required = {
      "cmd",
      "workspace",
    },
  }
end

M.config = {
  fields = {},
}

M.load = function()
  Mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      metadata = {
        subcommands = {
          update = {
            args = 0,
            name = "data.metadata.update",
          },
          insert = {
            name = "data.metadata.insert",
            args = 0,
          },
        },
        name = "metadata",
      },
    })
  end)
end

M.config = {}

M.public.data = {}

M.public = {}

M.events.subscribed = {
  cmd = {
    ["data.metadata.insert"] = true,
    ["data.metadata.update"] = true,
  },
}

M.on_event = function(e) end

return M
