---@type down.Mod
local M = require("down.mod").create("data.mod")

M.setup = function()
  return {
    loaded = true,
  }
end

---@class down.data.mod.Config
M.config = {}

---@class down.data.mod.Data
M.data = {}

return M
