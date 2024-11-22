H = {}

local health = vim.health
local healthp = vim.provider.health
local start, ok, warn, error, info = vim.health.start, vim.health.ok, vim.health.warn, vim.health.error, vim.health.info
local fmt = string.format

return {
  check = function()
    local config = require("word").config.user_config
    local modules = require("word.mod")

    start("word Configuration")

    if config.setup == nil or vim.tbl_isempty(config.setup) then
      ok("Empty configuration provided: word will load `base` by default.")
    elseif type(config.setup) ~= "table" then
      error("Invalid data type provided. `load` table should be a dictionary of modules!")
    else
      info("Checking `load` table...")

      for key, value in pairs(config.setup) do
        if type(key) ~= "string" then
          error(
            fmt(
              "Invalid data type provided within `load` table! Expected a module name (e.g. `base`), got a %s instead.",
              type(key)
            )
          )
        elseif not modules.setup_module(key) then
          warn(
            fmt(
              "You are attempting to load a module `%s` which is not recognized by word at this time. You may receive an error upon launching word.",
              key
            )
          )
        elseif type(value) ~= "table" then
          error(
            fmt(
              "Invalid data type provided within `load` table for module `%s`! Expected module data (e.g. `{ config = { ... } }`), got a %s instead.",
              key,
              type(key)
            )
          )
        elseif value.config and type(value.config) ~= "table" then
          error(
            fmt(
              "Invalid data type provided within data table for module `%s`! Expected configuration data (e.g. `config = { ... }`), but `config` was set to a %s instead.",
              key,
              type(key)
            )
          )
        elseif #vim.tbl_keys(value) > 1 and value.config ~= nil then
          warn(
            fmt(
              "Unexpected extra data provided to module `%s` - each module only expects a `config` table to be provided, nothing else.",
              key
            )
          )
        elseif (#vim.tbl_keys(value) > 0 and value.config == nil) or #vim.tbl_keys(value) > 1 then
          warn(
            fmt(
              "Misplaced configuration data for module `%s` - it seems like you forgot to put your module configuration inside a `config = {}` table?",
              key
            )
          )
        else
          ok(fmt("Module declaration for `%s` is well-formed", key))
        end
      end

      -- TODO(vhyrro): Check the correctness of the logger table too
      if config.logger == nil or vim.tbl_isempty(config.logger) then
        ok("Default configuration for logger provided, word will not output debug info.")
      end
    end

    start("word Dependencies")

    if vim.fn.executable("luarocks") then
      ok("`luarocks` is installed.")
    else
      error(
        "`luarocks` not installed on your system! Please consult the word README for installation instructions."
      )
    end

    start("word Keybinds")

    modules.setup_module("core.keybinds")
    local keybinds = modules.get_module("core.keybinds")
    local keybinds_config = modules.get_module_config("core.keybinds")

    if keybinds_config.default_keybinds then
      local key_healthcheck = keybinds.health()

      if key_healthcheck.preset_exists then
        info(fmt("word is configured to use keybind preset `%s`", keybinds_config.preset))
      else
        error(
          fmt(
            "Invalid configuration found: preset `%s` does not exist! Did you perhaps make a typo?",
            keybinds_config.preset
          )
        )
        return
      end

      for remap_key, remap_rhs in vim.spairs(key_healthcheck.remaps) do
        ok(
          fmt(
            "Action `%s` (bound to `%s` by default) has been remapped to something else in your configuration.",
            remap_rhs,
            remap_key
          )
        )
      end

      local ok = true

      for conflict_key, rhs in vim.spairs(key_healthcheck.conflicts) do
        warn(
          fmt(
            "Key `%s` conflicts with a key bound by the user. word will not bind this key.",
            conflict_key
          ),
          fmt("consider mapping `%s` to a different key than the one bound by word.", rhs)
        )
        ok = false
      end

      if ok then
        ok("No keybind conflicts found.")
      end
    else
      ok("word is not configured to set any default keybinds.")
    end
  end,
}
