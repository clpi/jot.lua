H = {}

local health = vim.health
local healthp = vim.provider.health
local start, ok, warn, error, info = vim.health.start, vim.health.ok, vim.health.warn, vim.health.error, vim.health.info
local fmt = string.format

return {
  check = function()
    start("jot Configuration")
  end
}
