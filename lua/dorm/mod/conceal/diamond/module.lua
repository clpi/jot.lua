local dorm = require("dorm")
local mod = dorm.mod

local module = mod.create("conceal.preset_diamond")

module.config.private.icon_preset_diamond = {
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
