B = {}

-- local Path = require("plenary.path")
local scandir = require("plenary.scandir")
local ft = require("plenary.filetype")

local fn, uv = vim.fn, vim.uv

---@return boolean
B.check_md = function()
  return fn.expand("%:e") == "md"
end

---@return boolean
B.check_ext = function(ext)
  return ext == fn.expand("%:e")
end

B.file = function()
  return fn.expand("%:t")
end
B.path = function()
  return fn.expand("%:p")
end
B.cwd = function()
  return fn.expand("%:p:h")
end

B.buf = function() vim.api.nvim_get_current_buf() end

B.win = function() vim.api.nvim_get_current_win() end

B.ln = function() vim.api.nvim_get_current_line() end

return B
