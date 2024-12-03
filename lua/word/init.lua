---@author clpi
---@file word.lua 0.1.0
---@license MIT
---@package word.lua
---@module "word"
---
---@brief   neovim note-taking plugin with the
---@brief   comfort of mmarkdown and the power of org
---
---@diagnostic enable
---@class word.word
---@field cfg word.config
local W = {
  cfg = require("word.config").config,
  mod = require("word.mod"),
  config = require("word.config"),
  callbacks = require("word.util.event.callback"),
  log = require("word.util.log"),
  types = require("word.types"),
  health = require("word.health"),
  core = require("word.core"),
  util = {
    util = require("word.util"),
    log = require("word.util.log"),
    buf = require("word.util.buf"),
    -- cb = require("word.event.cb"),
  },
  utils = require("word.util"),
  lib = require("word.util.lib"),
}

-- local e = require("word")
local con, log, modu, utils =
  require("word.config").config, W.log, W.mod, W.utils
local a, f, ext = vim.api, vim.fn, vim.tbl_deep_extend

--- @init "word.config"

--- Initializes word. Parses the supplied user config, initializes all selected mod and adds filetype checking for `.word`.
--- @param conf word.config.user? A table that reflects the structure of `config.user`.
--- @see config.user
--- @see word.config.user
function W.setup(conf)
  conf = conf or { mod = {} }
  if conf.mod == nil then
    conf.mod = {}
  end
  con.user = utils.extend(con.user, conf)
  log.new(con.user.logger or log.get_base_config(), true)
  require("word.config").setup_maps()
  require("word.config").setup_opts()

  if W.util.buf.check_md() or not con.user.lazy then
    W.enter_md(false)
  else
    -- a.nvim_create_user_command("wordInit", function()
    --   vim.cmd.delcommand("wordInit")
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
  local mod_list = con.user and con.user.mod or {}
  if con.started or not mod_list or vim.tbl_isempty(mod_list) then
    return
  end
  if con.hook then
    con.hook(manual, args)
  end
  con.manual = manual
  if args and args:len() > 0 then
    for key, value in args:gmatch("([%w%W]+)=([%w%W]+)") do
      con.args[key] = value
    end
  end

  for name, lm in pairs(mod_list) do
    con.mod[name] = utils.extend(con.mod[name] or {}, lm.config or {})
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
  con.started = true

  modu.broadcast_event({
    type = "started",
    split_type = {
      "started",
    },
    filename = "",
    filehead = "",
    cursor_position = { 0, 0 },
    referrer = "config",
    topic = "started",
    line_content = "",
    broadcast = true,
    buffer = a.nvim_get_current_buf(),
    window = a.nvim_get_current_win(),
    mode = f.mode(),
  })
  vim.api.nvim_exec_autocmds("User", {
    pattern = "wordLoaded", --
  })
end

-- require("telescope").setup_extension("word")
return W
