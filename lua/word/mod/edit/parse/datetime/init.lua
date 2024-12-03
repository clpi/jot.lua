local M = Mod.create("edit.parse.datetime")

local l = vim.lpeg

M.setup = function()
  return {
    loaded = true,
  }
end

---@class parse.datetime.Config
M.config.public = {}
---@class parse.datetime.Data
---@field date parse.datetime.Date
---@field grammar parse.datetime.Grammar
---@field time parse.datetime.Time
M.data = {}
---@class (exact) parse.datetime.Grammar
M.data.grammar = {}
---@class (exact) parse.datetime.Time
M.data.time = {}
---@class (exact) parse.datetime.Date
M.data.date = {}

return M
