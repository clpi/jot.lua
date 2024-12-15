local word = require("word")

local S = word.mod.create("ui.sidebar")

S.setup = function()
  return {
    loaded = true,
  }
end

---@class word.ui.sidebar.Config
S.config.public = {}

---@class word.ui.sidebar.Data
S.data = {}

return S
