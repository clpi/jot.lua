local mod = require("down.mod")

local M = mod.create("ui.status")

M.setup = function() return {
  loaded = true,
  requires = {

  }
} end

---@class down.ui.status.Config
M.config = {

}

---@class down.ui.status.Data
M.data = {

}

return M
