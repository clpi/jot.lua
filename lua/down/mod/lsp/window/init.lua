local W = Mod.create("lsp.window", {
  "msg",
})

function W.setup()
  return {
    requires = {
      "workspace",
      "lsp.workspace",
    },
    loaded = true,
  }
end

---@class (exact) lsp.window.Config
W.config = {}

---@class lsp.window.Data
W.data = {}

W.data.handlers = {

  ["telemetry/event"] = function(p)
  end,
  ["$/cancelRequest"] = function(p)
  end,
  ["$/progress"] = function(p)

  end,
  ["$/logTrace"] = function(p)
  end,
  ["window/logMessage"] = function(p)

  end,
  ["window/showMessage"] = function(p)

  end

}

return W
