local util = require('down.util')
local lsp = require('down.util.lsp')
local os = util.get_os()

---@todo TODO: Setup configuration and parse user config
---@todo       in this config module only

--- The down.lua configuration
--- @type down.Config
local Config = {
  --- Start in dev mode
  dev = false,
  workspace = {},
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
    lsp = lsp.setup,
  },
}

---@param user down.config.User
function Config.setup(user, ...)
  if Config.started or not user or vim.tbl_isempty(user) then
    return
  end
  Config.user = util.extend(Config.user, user or {})
  if Config.user.hook then
    Config.user.hook(...)
  end
  for name, val in pairs(Config.user) do
    if type(val) == 'table' then
      if name == 'workspaces' then
        for wsname, ws in pairs(val) do
          Config.workspace[wsname] = ws
        end
      else
        if name == 'workspace' then
          val['workspaces'] = util.extend(val['workspaces'], Config.workspace or {})
        end
        Config.mod[name] = util.extend(Config.mod[name] or {}, val)
      end
    else
      Config[name] = val
    end
  end
  Config.load.maps()
  Config.load.opts()
  if Config.dev then
    Config.load.lsp()
  end
  Config.started = true
end

return setmetatable(Config, {
  __index = function(mode, keymap) end,
  __newindex = function(cfg, key, val)
    Config[key] = val
  end,
})
