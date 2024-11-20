local sys = require("word.util.sys")
-- local defaults = require("word.config.default")
local os_info = sys.get_os_info()
-- local wv = require("word.config.version")
local f = vim.fn

--- Stores the configuration for the entirety of word.
--- This includes not only the user configuration (passed to `setup()`), but also internal
--- variables that describe something specific about the user's hardware.
--- @see word.setup
---
--- @type word.configuration
C = {
  user_config = {
    lazy_loading = false,
    load = {

    }
  },

  store_path = f.stdpath("data") .. "/word.mpack",

  mod = {},
  manual = nil,
  arguments = {},

  -- word_version = wv.word_version,
  -- version = wv.version,
  word_version = "0.1.0",
  version = "0.1.0",

  os_info = os_info,
  pathsep = os_info == "windows" and "\\" or "/",

  hook = nil,
  started = false,
}

return C
