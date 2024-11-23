if vim.g.word_loaded then
  return
end
vim.g.word_loaded = 1
vim.g.word_version = [[0.1.0]]
require("word")
