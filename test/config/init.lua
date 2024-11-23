vim.cmd [[
  set rtp+=./
  " set rtp+=~/.local/share/nvim/lazy/nvim-nio
  set rtp+=~/.local/share/nvim/lazy/nvim-treesitter
  set rtp+=~/.local/share/nvim/lazy/pathlib.nvim
  set rtp+=~/.local/share/nvim/lazy/nui.nvim
  set rtp+=~/.local/share/nvim/lazy/plenary.nvim
]]

local word = require("word")
word.setup(
  {
    load = {
      workspace = {
        config = {
          workspaces = {
            book = "./book"
          }
        }
      },
      base = {},
    }
  }
)
