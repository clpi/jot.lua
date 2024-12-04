local C = {}
local osi = require("word.util").get_os_info()
local f = vim.fn

--- @type word.mod.Config
C.config = {
  ---@type word.config.User
  user = {
    mod = {
      config = {},
    },
  },

  -- data = f.stdpath("data") .. "/word.mpack",

  ---@type word.config.Ft
  ft = {
    md = true,
    mdx = true,
    markdown = true,
    word = true,
  },

  mod = {
    config = {},
  },
  manual = nil,
  args = {},
  version = "0.1.0",
  os = osi,
  pathsep = osi == "windows" and "\\" or "/",
  hook = nil,
  started = false,
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
    "<CMD>Word lsp lens<CR>",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    ",wa",
    "<CMD>Word lsp action<CR>",
    { silent = true }
  )
end

C.setup_opts = function()
  vim.o.conceallevel = 2
  vim.o.concealcursor = [[nc]]
end
return C
