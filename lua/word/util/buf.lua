B = {}

-- local Path = require("plenary.path")
local ft = require("plenary.filetype")
local scandir = require("plenary.scandir")

local fn, uv = vim.fn, vim.uv

B.lines = function()
  return vim
end
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

---@return integer
B.buf = function()
  return vim.api.nvim_get_current_buf()
end

---@return integer
B.win = function()
  return vim.api.nvim_get_current_win()
end

B.em = {
  set = function() end,
}

---@return string[]
B.lns = function()
  return vim.api.nvim_buf_get_lines(B.buf(), 0, -1, false)
end
---@return string
B.ln = function()
  return vim.api.nvim_get_current_line()
end

---@return integer[]
B.cursor = function()
  return vim.api.nvim_win_get_cursor(B.win())
end

---@return integer
B.ns = function(name)
  return vim.api.nvim_create_namespace(name)
end

B.h = function()
  vim.api.nvim_win_get_height(0)
end
B.w = function()
  vim.api.nvim_win_get_width(0)
end

B.em = {
  ls = function(name)
    local ni = B.ns(name)
    return vim.api.nvim_buf_get_extmarks(B.buf(), ni, 0, -1, {})
  end,
  set_vt = function(name, conceal, vtext)
    local ni = B.ns(name)
    local c = B.cursor()
    vim.api.nvim_buf_set_extmark(
      B.buf(),
      ni,
      c[0],
      c[1],
      { conceal = conceal, virt_text = vtext }
    )
  end,
  get = function(name, id)
    local ni = B.ns(name)
    return vim.api.nvim_buf_del_extmark(B.buf(), ni, id)
  end,
}

return B
