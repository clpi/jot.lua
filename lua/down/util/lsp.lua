local M = {}

M.config = function()
  return vim.lsp.config({
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
  })
end

function M.run()
  local ft = vim.bo.filetype
  if ft == 'down' or ft == 'docdown' or ft == 'markdown' or ft == 'mdx' then
    vim.lsp.start({
      name = 'downls',
      cmd = { 'down', 'lsp' },
      root_dir = vim.fn.getcwd(),
      settings = {},
    })
  end
end

function M.setup()
  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    callback = M.run,
    desc = 'Start down-lsp',
  })
  vim.o.rtp = vim.o.rtp .. ',/Users/clp/down'
  vim.o.rtp = vim.o.rtp .. ',/Users/clp/down/ext/lsp'
end

M.run()

return M
