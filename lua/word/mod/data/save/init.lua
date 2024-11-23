local M = Mod.create('data.save')

M.setup = function()
  return {
    success = true,
    required = {
      'cmd',
      'workspace',
    },
  }
end


M.load = function()
  Mod.await('cmd', function(cmd)
    cmd.add_commands_from_table({
      save = {
        subcommands = {
          current = {
            args = 0,
            name = 'data.save.current'
          },
          new = {
            name = 'data.save.new',
            args = 0,
          },
        },
        name = 'save'
      }
    })
  end)
end

M.config.public = {

}

M.private = {

}

M.public = {

}

M.events.subscribed = {
  cmd = {
    ["data.save.current"] = true,
    ["data.save.new"] = true,
  }
}


return M
