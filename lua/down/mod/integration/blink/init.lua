local mod = require("down.mod")

---@type down.Mod
local M = mod.create("integration.blink")

local has_blink, blink = pcall(require, "blink.cmp")

---@class down.integration.blink.Config
M.config = {}
---@class down.integration.blink.Data
M.data = {}
M.data.source = require("down.mod.integration.blink.source")
M.data.format = require("down.mod.integration.blink.format")

return M
