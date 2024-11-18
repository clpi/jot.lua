M = {}

local a = vim.api

function M.word(ns)
  local hasword, v = pcall(require, "word")
  assert(hasword, "word is not loaded - load it before telescope")
  a.nvim_create_namespace(ns)
end

return M
