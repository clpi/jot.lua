local mod = require("down.mod")

local M = mod.create("ui.nav")

M.setup = function()
  return {
    loaded = true,
    requires = {},
  }
end

---@class down.ui.nav.Data
M.data = {}

---@class down.ui.nav.Config
M.config = {}

return M
