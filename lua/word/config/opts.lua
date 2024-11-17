M = {}

M.setup_opts = function()
  local o = vim.opt
  o.conceallevel = 2
  o.concealcursor = [[nc]]
  o.shellslash = true
end

return M
