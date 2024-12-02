local M = Mod.create("parse.heading")

local l = vim.lpeg

---@class parse.heading.Data
---@field heading parse.heading.Heading
M.data = {}
---@class (exact) parse.heading.Heading
---@field level integer: Level of heading
---@field isTitle boolean: Is title of document
---@field content string: Content of heading
M.data.heading = {
  level = 1,
  isTitle = true,
  content = "",
}
return M
