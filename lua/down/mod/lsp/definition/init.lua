local I = Mod.create("lsp.definition")

function I.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

I.config = {}

I.data = {}

return I
