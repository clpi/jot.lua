local word = require("word")
local lib, mod, utils, log = word.lib, word.mod, word.utils, word.log

local M = word.mod.create("data.code.run")

M.setup = function()
  return {
    loaded = true,
  }
end

---@class word.data.code.run.Config
M.config.public = {}

---@class word.data.code.run.Data
M.data = {}

return M
