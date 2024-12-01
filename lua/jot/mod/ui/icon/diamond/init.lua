local jot = require("jot")
local mod = jot.mod

local module = mod.create("ui.icon.diamond")

module.config.private.icon_diamond = {
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
}

return module
