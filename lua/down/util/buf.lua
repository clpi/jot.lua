B = {}

-- local Path = require("plenary.path")
local ft = require("plenary.filetype")
local scandir = require("plenary.scandir")

-- local vim = require("vim")
local fn, uv, v = vim.fn, vim.uv or vim.loop, vim.v

B.lines = function()
  return vim
end
B.ft = {
  ---@return boolean
  markdown = function(ext)
    return (ext or vim.fn.expand("%:e")) == "md"
  end,
  ---@return boolean
  down = function(ext)
    ext = ext or vim.fn.expand("%:e")
    return ext == "dn"
        or ext == "down"
        or ext == "downrc"
        or ext == "dd"
  end
}
B.check_dn = function()
  local ext = fn.expand("%:e")
  return ext == "md"
      or ext == "dn"
      or ext == "do"
      or ext == "docd"
      or ext == "ddoc"
      or ext == "down"
      or ext == "downrc"
end
---@return boolean
B.check_md = function()
  local ext = fn.expand("%:e")
  return ext == "md" or ext == "mdx"
end

---@return boolean
B.check_ext = function(ext)
  return ext == fn.expand("%:e")
end

B.base = function()
  return fn.expand("%:t:s?\\.[^\\.]\\+$??")
end
B.file = function()
  return fn.expand("%:t")
end
B.clipboard = function()
  fn.getreg(v.register, true)
end
B.path = function()
  return fn.expand("%:p")
end
function B.weekday()
  return os.date("%A")
end

function B.month()
  return os.date("%m")
end

function B.month_name()
  return os.date("%B")
end

function B.getOffsetTz(ts)
  local utcdate = os.date("!*t", ts)
  local localdate = os.date("*t", ts)
  localdate.isdst = false -- this is the trick
  ---@diagnostic disable-next-line
  local diff = os.difftime(os.time(localdate), os.time(utcdate))
  local h, m = math.modf(diff / 3600)
  return string.format("%+.4d", 100 * h + 60 * m)
end

function B.offsetTz()
  return B.getOffsetTz(os.time()):gsub("([+-])(%d%d)(%d%d)$", "%1%2:%3")
end

math.randomseed(os.time())

function B.year()
  return os.date("%Y")
end

function B.syear()
  return os.date("%y")
end

function B.date()
  return os.date("%d")
end

function B.smonth_name()
  return os.date("%b")
end

function B.sweekday()
  return os.date("%a")
end

B.sec = function()
  return os.date("%S")
end
B.min = function()
  return os.date("%M")
end
B.hr = function()
  return os.date("%H")
end
B.dir = function()
  return fn.expand("%:p:h")
end
B.cwd = B.dir

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
