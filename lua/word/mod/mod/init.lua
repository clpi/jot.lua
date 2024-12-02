---@type word.mod
local M = require("word.mod").create("mod")

---@class module
M.data = {}

M.setup = function()
  return {
    loaded = true,
  }
end

return M
