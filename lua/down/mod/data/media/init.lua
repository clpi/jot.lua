local mod = require("down.mod")
local M = mod.create("data.media")

M.setup = function()
  return {
    loaded = true,
  }
end
---@class data.media.Data
M.data = {}

---@class data.media.Config
M.config = {}

return M
