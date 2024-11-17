local files = {
  "./../lua/word/init.lua",
  "./../lua/word/core/init.lua",
  "./../lua/word/mod/init.lua",
  "./../lua/word/util/lib.lua",
}
local destination = 'doc/word_api.txt'

vim.fn.system(('lemmy-help %s > %s'):format(table.concat(files, ' '), destination))
vim.cmd([[qa!]])
