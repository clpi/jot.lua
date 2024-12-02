local M = Mod.create('data.tag')

M.setup = function()
  return {
    loaded = true,
    requires = { 'workspace', 'cmd' }
  }
end

M.load = function()
  Mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      tag = {
        subcommands = {
          delete = {
            args = 0,
            name = 'data.tag.delete'
          },
          new = {
            args = 0,
            name = 'data.tag.new'
          },
          list = {
            name = 'data.tag.list',
            args = 0,
          },
        },
        name = 'tag'
      }
    })
  end)
end

M.config = {

}

M.public.data = {

}

M.public = {

}

M.events = {

}

M.events.subcribed = {
  cmd = {
    ['data.tag.delete'] = true,
    ['data.tag.new'] = true,
    ['data.tag.list'] = true,

  }
}

M.on_event = function(e)

end

return M
