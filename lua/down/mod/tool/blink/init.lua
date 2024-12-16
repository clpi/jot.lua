local mod = require("down.mod")

---@type down.Mod
local M = mod.create("tool.blink")

local has_blink, blink = pcall(require, "blink.cmp")

---@class down.tool.blink.Config
M.config = {}
---@class down.tool.blink.Data
M.data = {}
M.data.source = require("down.mod.tool.blink.source")
M.data.format = require("down.mod.tool.blink.format")

return M
