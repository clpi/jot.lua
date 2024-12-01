local E = Mod.create("data.encrypt")

E.setup = function()
  return {
    success = true,
    requires = {
      "integration.treesitter",
      'cmd',
      'workspace',
    }
  }
end

E.config.public = {
}

E.load = function()
  Mod.await('cmd', function(cmd)
    cmd.add_commands_from_table({
      encrypt = {
        subcommands = {
          file = {
            args = 0,
            name = 'data.encrypt.update'
          },
          workspace = {
            name = 'data.encrypt.insert',
            args = 0,
          },
        },
        name = 'encrypt'
      }
    })
  end)
end

E.config.public = {

}

E.private = {

}

E.public = {

}

E.on_event = function(e)

end

E.events.subscribed = {
  cmd = {
    ["data.encrypt.insert"] = true,
    ["data.encrypt.update"] = true,
  }
}



return E
