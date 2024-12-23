local mod = require("down.mod")
local M = mod.create("data.media")

---@return down.mod.Setup
M.setup = function()
  ---@type down.mod.Setup
  return {
    requires = {
      "data.dirs",
    },
    loaded = true,
  }
end
---@class data.data.media.Data
M.data = {}

---@class data.data.media.Config
M.config = {}

return M
