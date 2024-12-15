local W = Mod.create("lsp.window.msg")

function W.setup()
  return {
    requires = {
      "ui.status",
      "workspace",
      "lsp.workspace",
    },
    loaded = true,
  }
end

---@class lsp.window.msg.Config
W.config = {

}

---@class lsp.window.msg.Data
W.data = {

}

return W
