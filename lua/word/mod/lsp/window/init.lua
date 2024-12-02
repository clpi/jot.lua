local W = Mod.create("lsp.window", {
  "msg",
})

function W.setup()
  return {
    required = {
      "workspace",
      "lsp.workspace",
    },
    loaded = true,
  }
end

---@class (exact) lsp.window.Config
W.config.public = {}

---@class lsp.window.Data
W.data = {}

return W
