local M = Mod.create("edit.parse.heading")

local l = vim.lpeg

---@class down.edit.parse.heading.Config
M.config = {}

---@class down.edit.parse.heading.Data
---@field heading parse.heading.Heading
M.data = {}
---@class (exact) down.edit.parse.heading.Heading
---@field level integer: Level of heading
---@field isTitle boolean: Is title of document
---@field content string: Content of heading
M.data.heading = {
  level = 1,
  isTitle = true,
  content = "",
}
return M
