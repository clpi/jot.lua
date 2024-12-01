local C = {}
-- local defaults = require("jot.config.default")
local osi = require("jot.util").get_os_info()
-- local wv = require("jot.config.version")
local f = vim.fn

--- @alias OperatingSystem
--- | "windows"
--- | "wsl"
--- | "wsl2"
--- | "mac"
--- | "linux"
--- | "bsd"
--- @alias jot.configuration.init { config?: table }

--- @class (exact) jot.config.ft
--- @field md boolean
--- @field mdx boolean
--- @field markdown boolean

--- @class (exact) jot.configuration.user
--- @field hook? fun(manual: boolean, arguments?: string)    A user-defined function that is invoked whenever jot starts up. May be used to e.g. set custom keybindings.
--- @field lazy? boolean                             Whether to defer loading the jot base until after the user has entered a `.jot` file.
--- @field logger? jot.log.configuration                   A configuration table for the logger.

--- @class (exact) jot.configuration
--- @field args table<string, string>                   A list of arguments provided to the `:jotStart` function in the form of `key=value` pairs. Only applicable when `user_config.lazy_loading` is `true`.
--- @field manual boolean?                                   Used if jot was manually loaded via `:jotStart`. Only applicable when `user_config.lazy_loading` is `true`.
--- @field mods table<string, jot.configuration.init> Acts as a copy of the user's configuration that may be modified at runtime.
--- @field os OperatingSystem                           The operating system that jot is currently running under.
--- @field pathsep "\\"|"/"                                  The operating system that jot is currently running under.
--- @field loaded boolean                                   Set to `true` when jot is fully initialized.
--- @field data string
--- @field user jot.configuration.user              Stores the configuration provided by the user.
--- @field version string                                    The version of jot that is currently active. Automatically updated by CI on every release.

--- Stores the configuration for the entirety of jot.
--- This includes not only the user configuration (passed to `setup()`), but also internal
--- variables that describe something specific about the user's hardware.
--- @see jot.setup
---
--- @type jot.configuration
-- TODO: What goes below this line until the next notice used to belong to mod
C.config = {
  ---@type jot.configuration.user
  user = {
    mods = {},
  },

  data = f.stdpath("data") .. "/jot.mpack",

  ---@type jot.config.ft
  ft = {
    md = true,
    mdx = true,
    markdown = true,
  },

  mods = {},
  manual = nil,
  args = {},
  version = "0.1.0",
  os = osi,
  pathsep = osi == "windows" and "\\" or "/",
  hook = nil,
  loaded = false,
}

C.version = "0.1.0"

C.setup_telescope = function() end
C.n = function(k, c)
  vim.api.nvim_set_keymap("n", k, c, { silent = true })
end
C.ni = function(k, c)
  vim.keymap.set({ "n", "i" }, k, c, { silent = true })
end
C.setup_maps = function()
  vim.api.nvim_set_keymap(
    "n",
    ",wl",
    "<CMD>jot lsp lens<CR>",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    ",wa",
    "<CMD>jot lsp action<CR>",
    { silent = true }
  )
end

C.setup_opts = function()
  vim.o.conceallevel = 2
  vim.o.concealcursor = [[nc]]
end
return C
