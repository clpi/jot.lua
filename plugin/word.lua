if vim.g.wordlua ~= nil then
  return
else
  vim.g.wordlua = true
end

local api, lsp, fn = vim.api, vim.lsp, vim.fn

if fn.has("nvim-0.10") ~= 1 then
  local v = vim.version()
end

local cmd = vim.api.nvim_create_user_command
local acmd = vim.api.nvim_create_autocmd

cmd("WordInit", function()
  require("telescope.builtin").find_files({

  })
end, {
  desc = "Run a Word command",
  range = true,
  bang = false,
  nargs = 0
})
