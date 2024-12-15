local mod = require "down.mod"

local M = mod.create("integration.cmp")

local has_cmp, cmp = pcall(require, "cmp")

---@class down.integration.cmp.Data
M.data = {

}
---@class down.integration.cmp.Config
M.config = {

}

M.setup = function()
  return {
    loaded = true
  }
end


return M
