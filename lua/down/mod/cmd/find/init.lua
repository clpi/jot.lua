local M = require("down.mod").create("cmd.find")

---@class down.find.Config
M.config = {}

---@class down.find.Data
M.data = {}

M.setup = function()
  return {
    loaded = true,
  }
end

return M
