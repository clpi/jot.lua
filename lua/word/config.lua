local C = {}
-- local defaults = require("word.config.default")
local os_info = require("word.util").get_os_info()
-- local wv = require("word.config.version")
local f = vim.fn

--- @alias word.configuration.init { config?: table }

--- @class (exact) word.configuration.user
--- @field hook? fun(manual: boolean, arguments?: string)    A user-defined function that is invoked whenever word starts up. May be used to e.g. set custom keybindings.
--- @field lazy? boolean                             Whether to defer loading the word base until after the user has entered a `.word` file.
--- @field logger? word.log.configuration                   A configuration table for the logger.

--- @class (exact) word.configuration
--- @field arguments table<string, string>                   A list of arguments provided to the `:wordStart` function in the form of `key=value` pairs. Only applicable when `user_config.lazy_loading` is `true`.
--- @field manual boolean?                                   Used if word was manually loaded via `:wordStart`. Only applicable when `user_config.lazy_loading` is `true`.
--- @field mods table<string, word.configuration.init> Acts as a copy of the user's configuration that may be modified at runtime.
--- @field word_version string                               The version of the file format to be used throughout word. Used internally.
--- @field os_info OperatingSystem                           The operating system that word is currently running under.
--- @field pathsep "\\"|"/"                                  The operating system that word is currently running under.
--- @field started boolean                                   Set to `true` when word is fully initialized.
--- @field data string
--- @field user word.configuration.user              Stores the configuration provided by the user.
--- @field version string                                    The version of word that is currently active. Automatically updated by CI on every release.

--- Stores the configuration for the entirety of word.
--- This includes not only the user configuration (passed to `setup()`), but also internal
--- variables that describe something specific about the user's hardware.
--- @see word.setup
---
--- @type word.configuration

-- TODO: What goes below this line until the next notice used to belong to mod
C.config = {
  user = {
    mods = {

    }
  },

  data = f.stdpath("data") .. "/word.mpack",

  ft = {
    md = true,
    rmd = true,
    markdown = true
  },

  mods = {},
  manual = nil,
  args = {},

  -- word_version = wv.word_version,
  -- version = wv.version,
  word_version = "0.1.0",
  version = "0.1.0",

  os_info = os_info,
  pathsep = os_info == "windows" and "\\" or "/",

  hook = nil,
  started = false,
}

C.version = "0.1.0"
C.word_version = "0.1.0"

C.setup_telescope = function()
end
C.setup_maps = function()
end

C.setup_opts = function()
  vim.o.conceallevel = 2
  vim.o.concealcursor = [[nc]]
  vim.o.shellslash = true
end
return C
