local I = Mod.create("lsp.definition")

function I.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

I.config.public = {}

I.data = {}

return I
