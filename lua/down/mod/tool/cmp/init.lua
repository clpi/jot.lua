local mod = require "down.mod"

local M = mod.new("tool.cmp")

local has_cmp, cmp = pcall(require, "cmp")

---@class down.tool.cmp.Data
M.data = {

}
---@class down.tool.cmp.Config
M.config = {

}

M.setup = function()
  return {
    loaded = true
  }
end


return M
