--- @brief [[
--- This file marks the beginning of the entire plugin. It's here that everything fires up and starts pumping.
--- @brief ]]

local word = {
  callbacks = require("word.util.callback"),
  config = require("word.config"),
  lsp = require("word.lsp"),
  cmd = require("word.cmd"),
  ui = require("word.ui"),
  log = require("word.util.log"),
  mod = require("word.mod"),
  utils = require("word.util"),
  lib = require("word.util.lib")
}

local config, log, mod, utils = word.config, word.log, word.mod, word.utils

--- @init "word.config"

--- Initializes word. Parses the supplied user configuration, initializes all selected mod and adds filetype checking for `.word`.
--- @param cfg word.configuration.user? A table that reflects the structure of `config.user_config`.
--- @see config.user_config
--- @see word.configuration.user
function word.setup(cfg)
  -- Ensure that we are running Neovim 0.10+
  assert(utils.is_minimum_version(0, 10, 0), "word requires at least Neovim version 0.10 to operate!")

  -- If the user supplied no configuration then generate a base one (assume the user wants the base)
  cfg = cfg or {
    load = {
      base = {},
      workspace = {
        config = {
          workspaces = {
            word = "~/word"
          }
        }
      }
    },
  }

  -- If no `load` table was passed whatsoever then assume the user wants the base ones.
  -- If the user explicitly sets `load = {}` in their configs then that means they do not want
  -- any mod loaded.
  --
  -- We check for nil specifically because some users might think `load = false` is a valid thing.
  -- With the explicit check `load = false` will issue an error.
  if cfg.load == nil then
    cfg.load = {
      ["base"] = {},
    }
  end

  config.user_config = vim.tbl_deep_extend("force", config.user_config, cfg)

  -- Create a new global instance of the word logger.
  log.new(config.user_config.logger or log.get_base_config(), true)

  -- If the file we have entered has a `.word` extension:
  if vim.fn.expand("%:e") == "word" or not config.user_config.lazy_loading then
    -- Then boot up the environment.
    word.org_file_entered(false)
  else
    -- Else listen for a BufAdd event for `.word` files and fire up the word environment.
    vim.api.nvim_create_user_command("wordStart", function()
      vim.cmd.delcommand("wordStart")
      word.org_file_entered(true)
    end, {})

    vim.api.nvim_create_autocmd("BufAdd", {
      pattern = "word",
      callback = function()
        word.org_file_entered(false)
      end,
    })
  end

  -- Call Mod.load_inits to load all inits
  mod.load_inits()
end

--- This function gets called upon entering a .word file and loads all of the user-defined mod.
--- @param manual boolean If true then the environment was kickstarted manually by the user.
--- @param arguments string? A list of arguments in the format of "key=value other_key=other_value".
function word.org_file_entered(manual, arguments)
  -- Extract the init list from the user config
  local init_list = config.user_config and config.user_config.load or {}

  -- If we have already started word or if we haven't defined any mod to load then bail
  if config.started or not init_list or vim.tbl_isempty(init_list) then
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
  for name, init in pairs(init_list) do
    -- Apply the config
    config.mod[name] = vim.tbl_deep_extend("force", config.mod[name] or {}, init.config or {})
  end

  -- After all config are merged proceed to actually load the mod
  local load_init = mod.load_init
  for name, _ in pairs(init_list) do
    -- If it could not be loaded then halt
    if not load_init(name) then
      log.warn("Recovering from error...")
      mod.loaded_mod[name] = nil
    end
  end

  -- Goes through each loaded init and invokes word_post_load()
  for _, init in pairs(mod.loaded_mod) do
    init.word_post_load()
  end

  -- Set this variable to prevent word from loading twice
  config.started = true

  -- Lets the entire word environment know that word has started!
  mod.broadcast_event({
    type = "started",
    split_type = { "base", "started" },
    filename = "",
    filehead = "",
    cursor_position = { 0, 0 },
    referrer = "base",
    line_content = "",
    broadcast = true,
    buffer = vim.api.nvim_get_current_buf(),
    window = vim.api.nvim_get_current_win(),
    mode = vim.fn.mode(),
  })

  -- Sometimes external plugins prefer hooking in to an autocommand
  vim.api.nvim_exec_autocmds("User", {
    pattern = "wordStarted",
  })
end

--- Returns whether or not word is loaded
--- @return boolean
function word.is_loaded()
  return config.started
end

-- require("telescope").load_extension("word")
return word
