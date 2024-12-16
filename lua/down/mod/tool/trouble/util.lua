local mod = require("word.mod")

local M = mod.create("tool.trouble")

local tro_ok, tro = pcall(require, "trouble")

---@return
function M.has_trouble()
  if tro_ok then return tro
  else return nil
end
