M = {}

M.setup_opts = function()
  vim.o.conceallevel = 2
  vim.o.concealcursor = [[nc]]
  vim.o.shellslash = true
end

return M
