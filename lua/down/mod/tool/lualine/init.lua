local mod = require("down.mod")
---@type down.Mod
local L = mod.create("tool.lualine")

L.setup = function()
  return {
    loaded = true,
  }
end

---@class word.tool.lualine.Config
L.config = {}
---@class word.tool.lualine.Data
L.data = {}

return L
