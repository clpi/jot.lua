local mod = require("word.mod")

local M = mod.create("ui.status")

M.setup = function() return {
  loaded = true,
  requires = {

  }
} end

---@class word.ui.status.Config
M.config.public = {

}

---@class word.ui.status.Data
M.data = {

}

return M
