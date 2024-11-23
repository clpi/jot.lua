local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.termguicolors = true
vim.opt.cursorline = true

-- Line settings
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.statuscolumn = '%s%=%{v:relnum?v:relnum:v:lnum} '

-- Mode is already in status line plugin
vim.opt.showmode = false
vim.opt.number = true
vim.opt.conceallevel = 2
vim.opt.winbar = "word.lua demo"
vim.opt.signcolumn = "yes:2"
vim.cmd [[nno ; :]]

require("lazy").setup({
          {
            'folke/tokyonight.nvim',
            config = function()
                ---@diagnostic disable-next-line: missing-fields
                require('tokyonight').setup({ style = 'night' })
                vim.cmd.colorscheme('tokyonight')
            end,
        },
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = function()
                require('lualine').setup({
                    sections = {
                        lualine_a = { 'mode' },
                        lualine_b = { { 'filename', path = 0 } },
                        lualine_c = {},
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = { 'location' },
                    },
                })
            end,
        },
  {
    "clpi/word.lua",
    lazy = false,
    version = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
          ---@diagnostic
          ---disable-next-line
          require("nvim-treesitter.configs").setup({
            ensure_installed = {
              "markdown_inline",
              "markdown"
            },
            highlight = { enable = true },
          })
        end,
      },
      "pysan3/pathlib.nvim",
    },
    opts = {
      mods = {
        config = {},
        workspace = {
          config = {
            default = "clp",
            workspaces = {
              clp = "~/clp"
            }
          }
        }
      }
    }
  }
})
