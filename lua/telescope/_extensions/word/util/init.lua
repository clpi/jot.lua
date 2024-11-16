M = {}

function M.word(ns)
  local hasword, v = pcall(require, "word")
  assert(hasword, "word is not loaded - load it before telescope")
  vim.api.nvim_create_namespace(ns)
end

return M
