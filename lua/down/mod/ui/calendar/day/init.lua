---@class down.mod.ui.calendar.Day: down.Mod
local D = require("down.mod").new("ui.calendar.day")

---@return down.mod.Setup
D.setup = function()
  return { ---@type down.mod.Setup
    loaded = true,
    requires = {

    }
  }
end

---@class down.mod.ui.calendar.day.Data
D.data = {

}

---@class down.mod.ui.calendar.day.Config
D.config = {

}

return D
