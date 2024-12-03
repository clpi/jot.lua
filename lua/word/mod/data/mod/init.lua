---@type word.mod
local M = require("word.mod").create("data.mod")

M.setup = function()
  return {
    loaded = true,
  }
end

M.config.public = {}

---@class module
M.data = {

  data = {},
}

return M
