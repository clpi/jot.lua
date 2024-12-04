local mod = require "word.mod"
---@alias word.integration.trouble.Trouble word.Mod
local T = mod.create("integration.trouble")
local tok, t = pcall(require, "trouble")

---@class word.integration.trouble.Data
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

---@class word.integration.trouble.Config
T.config.public = {

}



return T
