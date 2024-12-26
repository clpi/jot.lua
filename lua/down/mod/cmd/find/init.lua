local M = require("down.mod").new("cmd.find")

---@class down.cmd.find.Config
M.config = {}

---@class down.cmd.find.Data
M.data = {}

M.setup = function()
  return {
    loaded = true,
  }
end

return M
