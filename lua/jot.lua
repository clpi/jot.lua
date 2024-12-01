---@author clpi
---@file jot.lua 0.1.0
---@version JIT
---@package jot.lua
---@module "jot"
---@see jot.mod
---
---@brief   neovim note-taking plugin with the
---@brief   comfort of mmarkdown and the power of org
---
---@diagnostic enable
---@class jot.jot
local W = {
  cfg = require("jot.config").config,
  mod = require("jot.mod"),
  config = require("jot.config"),
  callbacks = require("jot.util.callback"),
  log = require("jot.util.log"),
  util = {
    util = require("jot.util"),
    log = require("jot.util.log"),
    buf = require("jot.util.buf"),
    -- cb = require("jot.event.cb"),
  },
  utils = require("jot.util"),
  lib = require("jot.util.lib"),
}

local con, log, modu, utils =
    require("jot.config").config, W.log, W.mod, W.utils
local a, f, ext = vim.api, vim.fn, vim.tbl_deep_extend

--- @init "jot.config"

--- Initializes jot. Parses the supplied user configuration, initializes all selected mod and adds filetype checking for `.jot`.
--- @param conf jot.configuration.user? A table that reflects the structure of `config.user`.
--- @see config.user
--- @see jot.configuration.user
function W.setup(conf)
  conf = conf or { mods = {} }
  if conf.mods == nil then
    conf.mods = {}
  end
  con.user = utils.extend(con.user, conf)
  log.new(con.user.logger or log.get_base_config(), true)
  require("jot.config").setup_maps()
  require("jot.config").setup_opts()

  -- If the file we have entered has a `.jot` extension:
  if W.util.buf.check_md() or not con.user.lazy then
    W.enter_md(false)
  else
    -- a.nvim_create_user_command("jotInit", function()
    --   vim.cmd.delcommand("jotInit")
    --   W.enter_md(true)
    -- end, {})

    a.nvim_create_autocmd("BufAdd", {
      pattern = "markdown",
      callback = function()
        W.enter_md(false)
      end,
    })
  end
end

function W.enter_md(manual, args)
  local mod_list = con.user and con.user.mods or {}
  if con.loaded or not mod_list or vim.tbl_isempty(mod_list) then
    return
  end
  if con.user.hook then
    con.user.hook(manual, args)
  end
  con.manual = manual
  if args and args:len() > 0 then
    for key, value in args:gmatch("([%w%W]+)=([%w%W]+)") do
      con.args[key] = value
    end
  end

  for name, lm in pairs(mod_list) do
    con.mods[name] = utils.extend(con.mods[name] or {}, lm.config or {})
  end
  local load_mod = modu.load_mod
  for name, _ in pairs(mod_list) do
    if not load_mod(name) then
      log.warn("Error recovery")
      modu.loaded_mod[name] = nil
    end
  end
  for _, lm in pairs(modu.loaded_mod) do
    lm.post_load()
  end
  con.loaded = true

  modu.broadcast_event({
    type = "loaded",
    split_type = {
      "loaded",
    },
    filename = "",
    filehead = "",
    cursor_position = { 0, 0 },
    referrer = "config",
    topic = "loaded",
    line_content = "",
    broadcast = true,
    buffer = a.nvim_get_current_buf(),
    window = a.nvim_get_current_win(),
    mode = f.mode(),
  })
  vim.api.nvim_exec_autocmds("User", {
    pattern = "jotLoaded", --
  })
end

_G.V = vim

-- require("telescope").setup_extension("jot")
return W
