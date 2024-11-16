M = {}

function M.dorm(ns)
  local hasdorm, v = pcall(require, "dorm")
  assert(hasdorm, "dorm is not loaded - load it before telescope")
  vim.api.nvim_create_namespace(ns)
end

return M
