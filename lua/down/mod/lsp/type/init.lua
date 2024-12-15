local T = Mod.create("lsp.type")

function T.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

T.config = {}

T.data = {}
return T
