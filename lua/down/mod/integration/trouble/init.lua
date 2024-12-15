local mod = require "down.mod"
---@alias down.integration.trouble.Trouble down.Mod
local T = mod.create("integration.trouble")
local tok, t = pcall(require, "trouble")

---@class down.integration.trouble.Data
T.data = {

}

T.setup = function()
  if not tok then return {
      loadeed = false
  }
  else return {
    loaded = true,
    requires = {
      "ui",
      "ui.win",
      "ui.popup"
    }
  }
  end
end

---@class down.integration.trouble.Config
T.config = {

}



return T
