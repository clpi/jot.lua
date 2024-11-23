---@author clpi
---@file word.lua 0.1.0
---@version JIT
---@package word.lua
---@module "word"
---@see word.mod
---
---@brief   neovim note-taking plugin with the
---@brief   comfort of mmarkdown and the power of org
---
---@diagnostic enable
---@class word.word
local W = {
  cfg = require("word.config").config,
  health = require("word.health"),
  mod = require("word.mod"),
  version = require("word.config").version,
  config = require("word.config"),
  callbacks = require("word.util.callback"),
  log = require("word.util.log"),
  util = {
    util = require("word.util"),
    fs = require("word.util.fs"),
    log = require("word.util.log"),
    buf = require("word.util.buf"),
    -- cb = require("word.event.cb"),
  },
  utils = require("word.util"),
  lib = require("word.util.lib")
}


local con, log, modu, utils = require "word.config".config, W.log, W.mod, W.utils
local a, f, ext = vim.api, vim.fn, vim.tbl_deep_extend


--- @init "word.config"

--- Initializes word. Parses the supplied user configuration, initializes all selected mod and adds filetype checking for `.word`.
--- @param conf word.configuration.user? A table that reflects the structure of `config.user`.
--- @see config.user
--- @see word.configuration.user
function W.setup(conf)
  assert(utils.is_minimum_version(0, 10, 0), "must have nvim 0.10.0+")
  conf = conf or { mods = {} }
  if conf.mods == nil then conf.mods = {} end
  con.user = utils.extend(con.user, conf)
  log.new(con.user.logger or log.get_base_config(), true)

  -- If the file we have entered has a `.word` extension:
  if W.util.buf.check_md() or not con.user.lazy then
    W.enter_md(false)
  else
    require("word.config").setup_maps()
    require("word.config").setup_opts()
    -- a.nvim_create_user_command("WordInit", function()
    --   vim.cmd.delcommand("WordInit")
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
  if con.started or not mod_list or vim.tbl_isempty(mod_list) then
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
  local load_mod = modu.setup_mod
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
      "loaded"
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
    pattern = "WordLoaded", --
  })
end

-- require("telescope").setup_extension("word")
return W
