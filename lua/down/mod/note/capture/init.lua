---@type down.Mod
local M = require 'down.mod'.new('note.capture')

---@return down.mod.Setup
M.setup = function()
  ---@type down.mod.Setup
  return {
    loaded = true,
    dependencies = {
      'cmd',
      'workspace',
    },
  }
end

---@class down.mod.note.capture.Data
M.data = {}

---@class down.mod.note.capture.Config
M.config = {}

---@class down.mod.note.capture.Events
M.events = {}

---@class down.mod.note.capture.Subscribed
M.handle = {
  cmd = {
    ['capture'] = true,
  },
}

return M
