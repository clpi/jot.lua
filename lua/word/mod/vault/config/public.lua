local mod = require("word").mod
local log = require("word").log
local utils = require("word").utils
local Path = require("pathlib")
M = {
  -- The list of active word vaults.
  --
  -- There is always an inbuilt vault called `base`, whose location is
  -- set to the Neovim current working directory on boot.
  ---@type table<string, PathlibPath>
  vaults = {
    default = require("pathlib").cwd(),
    base = require("pathlib").cwd(),
  },
  -- The name for the index file.
  --
  -- The index file is the "entry point" for all of your notes.
  index = "index.md",
  -- The base vault to set whenever Neovim starts.
  base_vault = nil,
  -- Whether to open the last vault's index file when `nvim` is executed
  -- without arguments.
  --
  -- May also be set to the string `"base"`, due to which word will always
  -- open up the index file for the vault defined in `base_vault`.
  open_last_vault = false,
  -- Whether to use base.ui.text_popup for `vault.new.note` event.
  -- if `false`, will use vim's base `vim.ui.input` instead.
  use_popup = true,
}
return M
