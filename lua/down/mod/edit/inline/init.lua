local mod = require "down.mod"

local M = mod.create("edit.inline")

M.setup = function()
  return {
    loaded = true
  }
end

---@class down.edit.inline.Config
M.config = {

}
---@class down.edit.inline.Data
M.data = {

}

return M
