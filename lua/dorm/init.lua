--- @brief [[
--- This file marks the beginning of the entire plugin. It's here that everything fires up and starts pumping.
--- @brief ]]

local dorm = {
  callbacks = require("dorm.util.callback"),
  config = require("dorm.config"),
  lsp = require("dorm.lsp"),
  cmd = require("dorm.cmd"),
  ui = require("dorm.ui"),
  log = require("dorm.util.log"),
  mod = require("dorm.mod"),
  utils = require("dorm.util"),
  lib = require("dorm.util.lib")
}

local config, log, mod, utils = dorm.config, dorm.log, dorm.mod, dorm.utils

--- @module "dorm.config"

--- Initializes dorm. Parses the supplied user configuration, initializes all selected mod and adds filetype checking for `.dorm`.
--- @param cfg dorm.configuration.user? A table that reflects the structure of `config.user_config`.
--- @see config.user_config
--- @see dorm.configuration.user
function dorm.setup(cfg)
  -- Ensure that we are running Neovim 0.10+
  assert(utils.is_minimum_version(0, 10, 0), "dorm requires at least Neovim version 0.10 to operate!")

  -- If the user supplied no configuration then generate a base one (assume the user wants the base)
  cfg = cfg or {
    load = {
      base = {},
      workspace = {
        config = {
          workspaces = {
            dorm = "~/dorm"
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

  -- Create a new global instance of the dorm logger.
  log.new(config.user_config.logger or log.get_base_config(), true)

  -- If the file we have entered has a `.dorm` extension:
  if vim.fn.expand("%:e") == "dorm" or not config.user_config.lazy_loading then
    -- Then boot up the environment.
    dorm.org_file_entered(false)
  else
    -- Else listen for a BufAdd event for `.dorm` files and fire up the dorm environment.
    vim.api.nvim_create_user_command("dormStart", function()
      vim.cmd.delcommand("dormStart")
      dorm.org_file_entered(true)
    end, {})

    vim.api.nvim_create_autocmd("BufAdd", {
      pattern = "dorm",
      callback = function()
        dorm.org_file_entered(false)
      end,
    })
  end

  -- Call Mod.load_modules to load all modules
  mod.load_modules()
end

--- This function gets called upon entering a .dorm file and loads all of the user-defined mod.
--- @param manual boolean If true then the environment was kickstarted manually by the user.
--- @param arguments string? A list of arguments in the format of "key=value other_key=other_value".
function dorm.org_file_entered(manual, arguments)
  -- Extract the module list from the user config
  local module_list = config.user_config and config.user_config.load or {}

  -- If we have already started dorm or if we haven't defined any mod to load then bail
  if config.started or not module_list or vim.tbl_isempty(module_list) then
    return
  end

  -- If the user has defined a post-load hook then execute it
  if config.user_config.hook then
    config.user_config.hook(manual, arguments)
  end

  -- If dorm was loaded manually (through `:DormStart`) then set this flag to true
  config.manual = manual

  -- If the user has supplied any dorm environment variables
  -- then parse those here
  if arguments and arguments:len() > 0 then
    for key, value in arguments:gmatch("([%w%W]+)=([%w%W]+)") do
      config.arguments[key] = value
    end
  end

  -- Go through each defined module and grab its config
  for name, module in pairs(module_list) do
    -- Apply the config
    config.mod[name] = vim.tbl_deep_extend("force", config.mod[name] or {}, module.config or {})
  end

  -- After all config are merged proceed to actually load the mod
  local load_module = mod.load_module
  for name, _ in pairs(module_list) do
    -- If it could not be loaded then halt
    if not load_module(name) then
      log.warn("Recovering from error...")
      mod.loaded_mod[name] = nil
    end
  end

  -- Goes through each loaded module and invokes dorm_post_load()
  for _, module in pairs(mod.loaded_mod) do
    module.dorm_post_load()
  end

  -- Set this variable to prevent dorm from loading twice
  config.started = true

  -- Lets the entire dorm environment know that dorm has started!
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
    pattern = "dormStarted",
  })
end

--- Returns whether or not dorm is loaded
--- @return boolean
function dorm.is_loaded()
  return config.started
end

-- require("telescope").load_extension("dorm")
return dorm
