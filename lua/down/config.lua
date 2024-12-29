local util = require('down.util')
local print = require('down.util.print')
local map = require('down.util.maps')
-- local mod = require('down.util.mod')
local osinfo = util.get_os()

---@todo TODO: Setup configuration and parse user config
---@todo       in this config module only

--- The down.lua configuration
--- @class down.Config
local Config = {
  --- Start in dev mode
  dev = false,
  workspace = {
    default = vim.fn.getcwd(0),
  },
  --- The user config to load in
  ---@type down.config.User
  user = {},
  ---@type table<string, down.Mod.Config>
  mod = {},
  version = '0.1.2-alpha',
  os = osinfo,
  hook = nil,
  started = false,
  pathsep = osinfo == 'windows' and '\\' or '/',
  load = {
    maps = function()
      map.n(',dd', '<CMD>Down<CR>')
      map.n(',D', '<CMD>Down<CR>')
      map.n('~', '<CMD>Down<CR>')
      map.n('|', '<CMD>Down<CR>')
    end,
    opts = function()
      vim.o.conceallevel = 2
      vim.o.concealcursor = [[nc]]
    end,
  },
}

--- @param ... string
--- @return string
function Config.vimdir(...)
  local d = vim.fs.joinpath(vim.fn.stdpath('data'), 'down/')
  vim.fn.mkdir(d, 'p')
  local dir = vim.fs.joinpath('data', ...)
  return dir
end

--- @param ... string
--- @return string
function Config.homedir(...)
  local d = vim.fs.joinpath(os.getenv('HOME') or '~/', '.down/', ...)
  vim.fn.mkdir(d, 'p')
  return d
end

--- @param file string | nil
--- @return string
function Config.file(fp)
  local f = vim.fs.joinpath(fp or Config.vimdir('down.json'))
end

--- @param f string | nil
--- @return down.config.User
function Config.fromfile(f)
  local file = vim.fn.readfile(Config.file(f))
  local conf = vim.json.decode(file) ---@type down.config.User
  return conf
end

--- @param f string | nil
function Config:save(f)
  local json = vim.json.encode(self.user)
  json = vim.fn.str2list(json)
  return vim.fn.writefile(json, self.file(f), 'S')
end

--- @param self down.Config
---@param user down.config.User
---@param default string[]
---@return boolean
function Config.setup(self, user, default, ...)
  if self.started or not user or vim.tbl_isempty(user) then
    return false
  end
  user = util.extend(user, default)
  self.user = util.extend(self.user, user)
  if self.user.hook then
    self.user.hook(...)
  end
  -- self:save()
  return true
end

function Config:post_load()
  Config.load.maps()
  Config.load.opts()
  Config.started = true
  return Config.started
end

return setmetatable(Config, {
  __index = function(mode, key)
    return Config.mod[key]
  end,
  __newindex = function(cfg, key, val)
    Config.mod[key] = val
  end,
})
