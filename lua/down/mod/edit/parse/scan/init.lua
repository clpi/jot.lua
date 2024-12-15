local M = Mod.create("edit.parse.scan")

M.setup = function()
  return {
    loaded = true,
  }
end

---@class down.edit.parse.scan.Config
M.config = {}

---@class down.edit.parse.scan.Data
M.data = {}

return M
