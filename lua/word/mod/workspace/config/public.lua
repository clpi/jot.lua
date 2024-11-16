local mod = require("word").mod
local log = require("word").log
local utils = require("word").utils
local Path = require("pathlib")
M = {
  -- The list of active word workspaces.
  --
  -- There is always an inbuilt workspace called `base`, whose location is
  -- set to the Neovim current working directory on boot.
  ---@type table<string, PathlibPath>
  workspaces = {
    default = require("pathlib").cwd(),
    base = require("pathlib").cwd(),
  },
  -- The name for the index file.
  --
  -- The index file is the "entry point" for all of your notes.
  index = "index.md",
  -- The base workspace to set whenever Neovim starts.
  base_workspace = nil,
  -- Whether to open the last workspace's index file when `nvim` is executed
  -- without arguments.
  --
  -- May also be set to the string `"base"`, due to which word will always
  -- open up the index file for the workspace defined in `base_workspace`.
  open_last_workspace = false,
  -- Whether to use base.ui.text_popup for `workspace.new.note` event.
  -- if `false`, will use vim's base `vim.ui.input` instead.
  use_popup = true,
}
return M
