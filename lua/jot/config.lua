local C = {}
-- local defaults = require("jot.config.default")
local osi = require("jot.util").get_os_info()
-- local wv = require("jot.config.version")
local f = vim.fn

--- @type jot.config
-- TODO: What goes below this line until the next notice used to belong to mod
C.config = {
  ---@type jot.config.user
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
    "<CMD>Jot lsp lens<CR>",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    ",wa",
    "<CMD>Jot lsp action<CR>",
    { silent = true }
  )
end

C.setup_opts = function()
  vim.o.conceallevel = 2
  vim.o.concealcursor = [[nc]]
end
return C
