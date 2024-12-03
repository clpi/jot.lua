local M = Mod.create("integration.blink")

local has_blink, blink = pcall(require, "blink.cmp")

M.data.source = require("word.mod.integration.blink.source")
M.data.format = require("word.mod.integration.blink.format")

return M
