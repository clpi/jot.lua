local word = require("word")

local mod, config, util = word.mod, word.config, word.util

local M = mod.create("user.example", {
  --- @brief submodules
  ---         child directories containing
  ---         modules to load in tandem, relative
  ---         to this (parent) module.
  --- "subexample",
  --- "pre_example",
  --- ...
})

M.setup = function()
  return {
    requires = {
      ---@brief required modules
      ---         modules from builtin or custom
      ---         modules that can be loaded in (same as
      ---         if calling `require 'module'`) as a dependency
      ---         for the module.
      --- "ui.popup",
      --- "edit.link",
      --- "integration.treesitter",
      --- ...
    },
    loaded = true,
  }
end

---@class (exact) example.Config
M.config.public = {
  --- @brief module config
  ---          the public facing config for this module that can be
  ---          set by the user from its default values here.
  --- ...
}

---@class example.Data
M.data = {
  --- @brief module data
  ---          the home of the module's internal data and methods
  ---          TODO: split up concerns
  --- ...
}

M.load = function()
  --- @brief module load
  ---          a set of functions to run whenever the
  ---          module is fist loaded upon startup.
  ---          TODO: maybe just merge in with setup()
  --- ...
end

return M
