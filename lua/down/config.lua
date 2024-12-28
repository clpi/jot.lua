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
    maps = function() end,
    opts = function()
      vim.o.conceallevel = 2
      vim.o.concealcursor = [[nc]]
    end,
  },
}

--- @param ... string
--- @return string
function Config.vimdir(...)
  return vim.fs.joinpath(vim.fn.stdpath('data'), 'down/', ...)
end

--- @param ... string
--- @return string
function Config.homedir(...)
  return vim.fs.joinpath(os.getenv('HOME') or '~/', '.down/', ...)
end

--- @param file string | nil
--- @return string
function Config.file(file)
  return vim.fs.joinpath(file or Config.vimdir('down.json'))
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
  return vim.fn.writefile(self.user, Config.file(f))
end

---@param user down.config.User
---@param default string[]
---@return boolean
function Config.setup(user, default, ...)
  if Config.started or not user or vim.tbl_isempty(user) then
    return false
  end
  user = util.extend(user, default)
  Config.user = util.extend(Config.user, user)
  if Config.user.hook then
    Config.user.hook(...)
  end
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
