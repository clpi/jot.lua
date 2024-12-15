local down = require("down")
local mod, config = down.mod, down.cfg
local M = mod.create("edit.conceal")
local fn, a, madd = vim.fn, vim.api, vim.fn.matchadd
M.chars = require("down.mod.edit.conceal.chars")
M.math = require("down.mod.edit.conceal.math")
M.border = require("down.mod.edit.conceal.border")

M.setup = function()
  return {
    loaded = true,
    requires = {},
  }
end

M.data.math = M.math.data
M.data.border = M.border.data
M.data.chars = M.chars.data
M.config = {
  link_style = "markdown",
}
M.data.data.start_link_concealing = function()
  if M.config == "markdown" then
    madd(
      "Conceal",
      "\\[[^[]\\{-}\\]\\zs([^(]\\{-})\\ze",
      0,
      -1,
      { conceal = "" }
    )
    madd(
      "Conceal",
      "\\zs\\[\\ze[^[]\\{-}\\]([^(]\\{-})",
      0,
      -1,
      { conceal = "" }
    )
    madd(
      "Conceal",
      "\\[[^[]\\{-}\\zs\\]\\ze([^(]\\{-})",
      0,
      -1,
      { conceal = "" }
    )
    madd(
      "Conceal",
      "\\[[^[]\\{-}\\]\\zs\\%[ ]\\[[^[]\\{-}\\]\\ze\\%[ ]\\v([^(]|$)",
      0,
      -1,
      { conceal = "" }
    )
    madd(
      "Conceal",
      "\\zs\\[\\ze[^[]\\{-}\\]\\%[ ]\\[[^[]\\{-}\\]\\%[ ]\\v([^(]|$)",
      0,
      -1,
      { conceal = "" }
    )
    madd(
      "Conceal",
      "\\[[^[]\\{-}\\zs\\]\\ze\\%[ ]\\[[^[]\\{-}\\]\\%[ ]\\v([^(]|$)",
      0,
      -1,
      { conceal = "" }
    )
    madd(
      "Conceal",
      "\\[[^[]\\{-}\\]\\zs\\%[ ]\\[[^[]\\{-}\\]\\ze\\n",
      0,
      -1,
      { conceal = "" }
    )
    madd(
      "Conceal",
      "\\zs\\[\\ze[^[]\\{-}\\]\\%[ ]\\[[^[]\\{-}\\]\\n",
      0,
      -1,
      { conceal = "" }
    )
    madd(
      "Conceal",
      "\\[[^[]\\{-}\\zs\\]\\ze\\%[ ]\\[[^[]\\{-}\\]\\n",
      0,
      -1,
      { conceal = "" }
    )
  elseif M.config.link_style == "wiki" then
    madd(
      "Conceal",
      "\\zs\\[\\[[^[]\\{-}[|]\\ze[^[]\\{-}\\]\\]",
      0,
      -1,
      { conceal = "" }
    )
    madd(
      "Conceal",
      "\\[\\[[^[\\{-}[|][^[]\\{-}\\zs\\]\\]\\ze",
      0,
      -1,
      { conceal = "" }
    )
    madd("Conceal", "\\zs\\[\\[\\ze[^[]\\{-}\\]\\]", 0, -1, { conceal = "" })
    madd("Conceal", "\\[\\[[^[]\\{-}\\zs\\]\\]\\ze", 0, -1, { conceal = "" })
  end

  -- Set conceal level
  vim.wo.conceallevel = 2

  -- Don't change the highlighting of concealed characters
  a.nvim_exec(
    [[highlight Conceal ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE]],
    false
  )
end

-- Set up autocommands to trigger the link concealing setup in Markdown files

M.data.ft_patterns = function()
  -- Create ft pattern
  local filetypes = config.ft
  local ft_pattern = ""

  for ext, _ in pairs(filetypes) do
    ft_pattern = ft_pattern .. "*." .. ext .. ","
  end
  return ft_pattern
end

a.nvim_create_autocmd({ "FileType", "BufRead", "BufEnter" }, {
  pattern = M.data.ft_patterns(),
  callback = function()
    M.data.start_link_concealing()
  end,
})

return M
