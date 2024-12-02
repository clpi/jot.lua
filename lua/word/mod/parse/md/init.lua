local M = Mod.create("parse.md")

local tsu = require("nvim-treesitter.ts_utils")
local tsu = require("nvim-treesitter.utils")

local p = vim.lpeg

-- local R, P, V, S, C, Cc, Ct = p.R, p.P, p.V, p.S, p.C, p.Cc, p.Ct

M.data = {
}
M.config.public = {

}
M.setup = function()
  return {
    loaded = true
  }
end

return M
