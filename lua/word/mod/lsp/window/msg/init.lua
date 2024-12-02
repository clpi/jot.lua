local W = Mod.create("lsp.window.msg")

function W.setup()
  return {
    requires = {
      "workspace",
      "lsp.workspace",
    },
    loaded = true,
  }
end

return W
