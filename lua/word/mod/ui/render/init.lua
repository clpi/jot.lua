local word = require("word")

local S = word.mod.create("ui.render")

S.setup = function()
  return {
    loaded = true,
  }
end

---@class word.ui.render.Config
S.config.public = {}

---@class word.ui.render.Data
S.data = {}

return S
