---@author clpi
---@file down.lua 0.1.0
---@license MIT
---@package down.lua
---@mle "down"
---@version JIT
---@brief neovim note-taking plugin with the
---@brief comfort of mmarkdown and the power of org

---TODO: make variety of commands on autocmd load markdown only

---@class down.down
local W = {
  cfg = require('down.config').config,
  mod = require('down.mod'),
  config = require('down.config'),
  callbacks = require('down.util.event.callback'),
  log = require('down.util.log'),
  health = require('down.health'),
  core = require('down.core'),
  util = {
    util = require('down.util'),
    log = require('down.util.log'),
    buf = require('down.util.buf'),
    -- cb = require("down.event.cb"),
  },
  utils = require('down.util'),
  lib = require('down.util.lib'),
}

-- local e = require("down")
local con, log, m, utils = require('down.config').config, W.log, W.mod, W.utils
local a, f, ext = vim.api, vim.fn, vim.tbl_deep_extend

--- @init "down.config"

--- Initializes down. Parses the supplied user config, initializes all selected mod and adds filetype checking for `.down`.
--- @param conf down.config.UserMod? A table that reflects the structure of `config.user`.
function W.setup(conf)
  conf = conf or {}
  con.user = utils.extend(con.user, conf)
  -- log.new(con.user.logger or log.get_base_config(), true)
  require('down.config').setup_maps()
  require('down.config').setup_opts()

  if W.util.buf.check_md() or not con.user.lazy then
    W.enter(false)
  else
    -- a.nvim_create_user_command("downInit", function()
    --   vim.cmd.delcommand("downInit")
    --   W.enter(true)
    -- end, {})
    a.nvim_create_autocmd('BufAdd', {
      pattern = { 'markdown' },
      callback = function()
        W.enter(false)
      end,
    })
  end
  if conf.config and conf.config.dev then
    require 'down.util.lsp'.setup()
    require 'down.util.lsp'.run()
  end
end

---@param manual table
---@param args table
function W.enter(manual, args)
  local mods = con and con.user or {}
  if con.started or not mods or vim.tbl_isempty(mods) then ---@diagnostic disable-line
    return
  end
  if con.hook then
    con.hook(manual, args)
  end
  con.manual = manual
  if args and args:len() > 0 then
    for key, value in args:gmatch('([%w%W]+)=([%w%W]+)') do
      con.args[key] = value
    end
  end

  for name, lm in pairs(mods) do
    con[name] = utils.extend(con[name] or {}, lm or {})
  end
  for name, _ in pairs(mods) do
    if not m.load_mod(name) then
      log.warn('Error recovery')
      m.loaded_mod[name] = nil
    end
  end
  for _, lm in pairs(m.loaded_mod) do
    lm.post_load()
  end
  con.started = true

  m.broadcast({
    type = 'started',
    split_type = {
      'started',
    },
    filename = '',
    filehead = '',
    cursor_position = { 0, 0 },
    referrer = 'config',
    topic = 'started',
    line_content = '',
    broadcast = true,
    buffer = a.nvim_get_current_buf(),
    window = a.nvim_get_current_win(),
    mode = f.mode(),
  })
  vim.api.nvim_exec_autocmds('User', {
    pattern = 'downLoaded', --
  })
end

-- require("telescope").setup_extension("down")
return W
