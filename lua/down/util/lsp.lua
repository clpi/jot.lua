local M = {}

M.config = {
  name = 'downls',
  cmd = { 'down', 'lsp' },
  root_dir = vim.fn.getcwd(),
  settings = {
    markdown = {},
    down = {
      completion = {
        enable = true,
      },
      hover = {
        enable = true,
      },
      highlight = {
        enable = true,
      },
    },
  },
}

function M.setup()
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
    pattern = '*',
    callback = M.run,
    desc = 'Run downls',
  })
end

function M.run()
  local ft = vim.bo.filetype
  local ext = vim.fn.expand('%:e')
  if ext == 'md' or ext == 'dn' or ext == 'dd' or ext == 'down' or ext == 'downrc' then
    vim.lsp.start(M.config)
  end
end

function M.augroup()
  return vim.api.nvim_create_augroup('down.lsp', {
    clear = true,
  })
end

M.run()

return M
