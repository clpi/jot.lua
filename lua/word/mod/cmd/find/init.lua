local M = require("word.mod").create("cmd.find")

---@class word.find.Config
M.config.public = {}

---@class word.find.Data
M.data = {}

M.setup = function()
  return {
    loaded = true,
  }
end

return M
