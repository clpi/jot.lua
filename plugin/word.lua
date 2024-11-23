if vim.g.word_loaded then
  return
end
vim.g.word_loaded = 1
vim.g.word_version = [[0.1.0]]

assert(require("word.util").is_minimum_version(0, 10, 0), "must have nvim 0.10.0+")
require("word")
