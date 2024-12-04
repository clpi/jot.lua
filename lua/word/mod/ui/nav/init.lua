local mod = require("word.mod")

local M = mod.create("ui.nav")

M.setup = function()
  return {
    loaded = true,
    requires = {},
  }
end

---@class word.ui.nav.Data
M.data = {}
---@class word.ui.nav.Config
M.config.public = {}

return M
