local mod = require("word.mod")

local M = mod.create("ui.prompt")

M.setup = function()
  return {
    loaded = true,
    requires = {},
  }
end

---@class word.ui.prompt.Config
M.config.public = {}

---@class word.ui.prompt.Data
M.data = {}

return M
