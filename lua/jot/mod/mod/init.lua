---@type jot.mod
local M = require("jot.mod").create("mod")

---@class module
M.public = {}

M.setup = function()
  return {
    loaded = true,
  }
end

return M
