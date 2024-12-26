local util = require('down.util')
-- local mod = require('down.util.mod')
local os = util.get_os()

---@todo TODO: Setup configuration and parse user config
---@todo       in this config module only

--- The down.lua configuration
--- @type down.Config
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
  os = os,
  hook = nil,
  started = false,
  pathsep = os == 'windows' and '\\' or '/',
  load = {
    maps = function()
      vim.api.nvim_set_keymap('n', ',wl', '<cmd>down lsp lens<cr>', { silent = true })
      vim.api.nvim_set_keymap('n', ',wa', '<cmd>down lsp action<cr>', { silent = true })
    end,
    opts = function()
      vim.o.conceallevel = 2
      vim.o.concealcursor = [[nc]]
    end,
  },
}

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

Config.post_load = function()
  Config.load.maps()
  Config.load.opts()
  Config.started = true
  return Config.started
end

return setmetatable(Config, {
  __index = function(mode, keymap) end,
  __newindex = function(cfg, key, val)
    Config.mod[key] = val
  end,
})
