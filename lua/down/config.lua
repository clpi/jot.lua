local C = {}
local osi = require("down.util").get_os_info()
local f = vim.fn

--- @type down.Config
C.config = {
  ---@type down.config.UserMod
  user = {
    mod = {
      config = {},
    },
  },

  -- data = f.stdpath("data") .. "/down.mpack",

  ---@type down.config.Ft
  ft = {
    md = true,
    mdx = true,
    markdown = true,
    down = true,
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
    "<CMD>down lsp lens<CR>",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    ",wa",
    "<CMD>down lsp action<CR>",
    { silent = true }
  )
end

C.setup_opts = function()
  vim.o.conceallevel = 2
  vim.o.concealcursor = [[nc]]
end
return C
