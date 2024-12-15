---@type word.Mod
local M = require("word.mod").create("data.mod")

M.setup = function()
  return {
    loaded = true,
  }
end

---@class word.data.mod.Config
M.config.public = {}

---@class word.data.mod.Data
M.data = {}

return M
