local word = require("word")
local mod = word.mod

local module = mod.create("icon.diamond")

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
