local mod = require("down.mod")
---@alias down.tool.trouble.Trouble down.Mod
local T = mod.create("tool.trouble")

local t_ok, trouble = pcall(require, "trouble")

T.setup = function()
  if t_ok ~= true then
    return {
      loadeed = false,
    }
  else
    return {
      loaded = true,
      requires = {
        "ui",
        "ui.win",
        "ui.popup",
      },
    }
  end
end

---@class down.tool.trouble.Data
T.data = {}

---@class down.tool.trouble.Config
T.config = {}

return T
