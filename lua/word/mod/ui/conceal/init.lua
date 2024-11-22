-- mkdnflow.nvim (Tools for personal markdown notebook navigation and management)
-- Copyright (C) 2022 Jake W. Vincent <https://github.com/jakewvincent>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local word = require('word')
local mod, config = word.mod, word.cfg
local M = mod.create("ui.conceal")
local fn, a, madd = vim.fn, vim.api, vim.fn.matchadd

M.setup = function()
  return {
    success = true,
    requires = {}
  }
end

M.config.public = {
  link_style = "markdown"
}
M.private.start_link_concealing = function()
  if M.config.public == 'markdown' then
    madd('Conceal', '\\[[^[]\\{-}\\]\\zs([^(]\\{-})\\ze', 0, -1, { conceal = '' })
    madd('Conceal', '\\zs\\[\\ze[^[]\\{-}\\]([^(]\\{-})', 0, -1, { conceal = '' })
    madd('Conceal', '\\[[^[]\\{-}\\zs\\]\\ze([^(]\\{-})', 0, -1, { conceal = '' })
    madd(
      'Conceal',
      '\\[[^[]\\{-}\\]\\zs\\%[ ]\\[[^[]\\{-}\\]\\ze\\%[ ]\\v([^(]|$)',
      0,
      -1,
      { conceal = '' }
    )
    madd(
      'Conceal',
      '\\zs\\[\\ze[^[]\\{-}\\]\\%[ ]\\[[^[]\\{-}\\]\\%[ ]\\v([^(]|$)',
      0,
      -1,
      { conceal = '' }
    )
    madd(
      'Conceal',
      '\\[[^[]\\{-}\\zs\\]\\ze\\%[ ]\\[[^[]\\{-}\\]\\%[ ]\\v([^(]|$)',
      0,
      -1,
      { conceal = '' }
    )
    madd(
      'Conceal',
      '\\[[^[]\\{-}\\]\\zs\\%[ ]\\[[^[]\\{-}\\]\\ze\\n',
      0,
      -1,
      { conceal = '' }
    )
    madd(
      'Conceal',
      '\\zs\\[\\ze[^[]\\{-}\\]\\%[ ]\\[[^[]\\{-}\\]\\n',
      0,
      -1,
      { conceal = '' }
    )
    madd(
      'Conceal',
      '\\[[^[]\\{-}\\zs\\]\\ze\\%[ ]\\[[^[]\\{-}\\]\\n',
      0,
      -1,
      { conceal = '' }
    )
  elseif M.config.public.link_style == 'wiki' then
    madd(
      'Conceal',
      '\\zs\\[\\[[^[]\\{-}[|]\\ze[^[]\\{-}\\]\\]',
      0,
      -1,
      { conceal = '' }
    )
    madd(
      'Conceal',
      '\\[\\[[^[\\{-}[|][^[]\\{-}\\zs\\]\\]\\ze',
      0,
      -1,
      { conceal = '' }
    )
    madd('Conceal', '\\zs\\[\\[\\ze[^[]\\{-}\\]\\]', 0, -1, { conceal = '' })
    madd('Conceal', '\\[\\[[^[]\\{-}\\zs\\]\\]\\ze', 0, -1, { conceal = '' })
  end

  -- Set conceal level
  vim.wo.conceallevel = 2

  -- Don't change the highlighting of concealed characters
  a.nvim_exec([[highlight Conceal ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE]], false)
end

-- Set up autocommands to trigger the link concealing setup in Markdown files
M.public.conceal_augroup = a.nvim_create_augroup('MkdnflowLinkConcealing', { clear = true })

M.public.ft_patterns = function()
  -- Create ft pattern
  local filetypes = config.ft
  local ft_pattern = ''

  for ext, _ in pairs(filetypes) do
    ft_pattern = ft_pattern .. '*.' .. ext .. ','
  end
  return ft_pattern
end

a.nvim_create_autocmd({ 'FileType', 'BufRead', 'BufEnter' }, {
  pattern = M.public.ft_patterns(),
  callback = function()
    M.public.start_link_concealing()
  end,
  group = M.public.conceal_augroup,
})

return M
