local word = require("word")
local mod = word.mod

local M = mod.create("ui.icon.diamond")

---@class word.ui.icon.diamond.Config
M.config.public = {
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

---@class word.ui.icon.diamond.Data
M.data = {}

return M
