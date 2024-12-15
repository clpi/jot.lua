local down = require("down")
local mod = down.mod

local M = mod.create("ui.icon.diamond")

---@class down.ui.icon.diamond.Config
M.config = {
  icon_diamond = {
    heading = {
      icons = { "◈", "◇", "◆", "⋄", "❖", "⟡" },
    },

    footnote = {
      single = {
        icon = "†",
      },
      multi_prefix = {
        icon = "‡ ",
      },
      multi_suffix = {
        icon = "‡ ",
      },
    },
  },
}

---@class down.ui.icon.diamond.Data
M.data = {}

return M
