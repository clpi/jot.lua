local down = require("down")
local lib, mod, utils, log = down.lib, down.mod, down.utils, down.log

local M = require "down.mod".new("data.code.run")

M.setup = function()
  return {
    loaded = true,
  }
end

---@class down.data.code.run.Config
M.config = {}

---@class down.data.code.run.Data
M.data = {}

return M
