local down = require("down")

local S = down.mod.create("ui.render")

S.setup = function()
  return {
    loaded = true,
  }
end

---@class down.ui.render.Config
S.config = {}

---@class down.ui.render.Data
S.data = {}

return S
