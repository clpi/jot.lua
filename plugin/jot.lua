if vim.g.jot_loaded then
  return
end
vim.g.jot_loaded = 1
vim.g.jot_version = [[0.1.0]]

assert(require("jot.util").is_minimum_version(0, 10, 0), "must have nvim 0.10.0+")
require("jot")
