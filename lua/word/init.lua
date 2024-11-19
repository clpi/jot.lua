--- @brief [[
--- This file marks the beginning of the entire plugin. It's here that everything fires up and starts pumping.
--- @brief ]]

-- core = {
--   core = require("word.core"),
-- },
W = {
  graph = require("word.core"),
  -- mod = require("word.mod"),
  version = require("word.config.version").version,
  cfg = {
    cfg = require("word.config"),
    opts = require("word.config.opts"),
    version = require("word.config.version"),
    default = require("word.config.default"),
  },
  callbacks = require("word.util.callback"),
  config = require("word.config"),
  lsp = require("word.lsp"),
  -- cmd = require("word.cmd"),
  ui = require("word.ui"),
  log = require("word.util.log"),
  util = {
    util = require("word.util"),
    log = require("word.util.log"),
    buf = require("word.util.buf"),
    cb = require("word.util.callback"),
  },
  utils = require("word.util"),
  lib = require("word.util.lib")
}

local config, log, modu, utils = W.config, W.log, W.mod, W.utils
local a, f, ext = vim.api, vim.fn, vim.tbl_deep_extend

--- @init "word.config"

--- Initializes word. Parses the supplied user configuration, initializes all selected mod and adds filetype checking for `.word`.
--- @param cfg word.configuration.user? A table that reflects the structure of `config.user_config`.
--- @see config.user_config
--- @see word.configuration.user
function W.setup(conf)
  -- Ensure that we are running Neovim 0.10+
  assert(utils.is_minimum_version(0, 10, 0), "word requires at least Neovim version 0.10 to operate!")

  conf = conf or require "word.config.default".user
  if conf.load == nil then conf.load = { base = {} } end
  config.user_config = utils.extend(config.user_config, conf)
  log.new(config.user_config.logger or log.get_base_config(), true)

  -- If the file we have entered has a `.word` extension:
  if W.util.buf.check_ext("md") or not config.user_config.lazy_loading then
    W.enter_md(false)
  else
    a.nvim_create_user_command("WordInit", function()
      vim.cmd.delcommand("WordInit")
      W.enter_md(true)
    end, {})

    a.nvim_create_autocmd("BufAdd", {
      pattern = "markdown",
      callback = function()
        W.enter_md(false)
      end,
    })
  end

  -- Call Mod.load_mods to load all inits
  -- mod.load_mods()

  -- P9884
  require("telescope").load_extension("word")
end

function W.enter_md(manual, arguments)
  -- Extract the init list from the user config
  local mod_list = config.user_config and config.user_config.load or {}

  -- If we have already started word or if we haven't defined any mod to load then bail
  if config.started or not mod_list or vim.tbl_isempty(mod_list) then
    return
  end

  -- If the user has defined a post-load hook then execute it
  if config.user_config.hook then
    config.user_config.hook(manual, arguments)
  end

  -- If word was loaded manually (through `:wordStart`) then set this flag to true
  config.manual = manual

  -- If the user has supplied any word environment variables
  -- then parse those here
  if arguments and arguments:len() > 0 then
    for key, value in arguments:gmatch("([%w%W]+)=([%w%W]+)") do
      config.arguments[key] = value
    end
  end

  -- Go through each defined init and grab its config
  for name, init in pairs(mod_list) do
    config.mod[name] = utils.extend(config.mod[name] or {}, init.config or {})
  end

  -- After all config are merged proceed to actually load the mod
  local load_mod = require("word.mod").load_mod
  for name, _ in pairs(mod_list) do
    -- If it could not be loaded then halt
    if not load_mod(name) then
      log.warn("Recovering from error...")
      require("word.mod").loaded_mod[name] = nil
    end
  end

  -- Goes through each loaded init and invokes word_post_load()
  for _, init in pairs(require("word.mod").loaded_mod) do
    init.word_post_load()
  end

  -- Set this variable to prevent word from loading twice
  config.started = true

  -- Lets the entire word environment know that word has started!
  require("word.mod").broadcast_event({
    type = "started",
    split_type = {
      "base", "started"
    },
    filename = "",
    filehead = "",
    cursor_position = { 0, 0 },
    referrer = "", -- TODO: consider editing out? Not sure base
    line_content = "",
    broadcast = true,
    buffer = a.nvim_get_current_buf(),
    window = a.nvim_get_current_win(),
    mode = f.mode(),
  })

  -- Sometimes external plugins prefer hooking in to an autocommand
  vim.api.nvim_exec_autocmds("User", {
    modeline = true,
    pattern = "markdown", -- wordInit
  })
end

--- Returns whether or not word is loaded
--- @return boolean
function W.is_loaded()
  return config.started
end

-- require("telescope").load_extension("word")
return W
