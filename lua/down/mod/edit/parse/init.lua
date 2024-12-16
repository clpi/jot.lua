---@type down.mod
local P = Mod.create("edit.parse", { "scan", "datetime", "heading" })

local p = vim.lpeg
local R, V, S, C, Cc, Ct = p.R, p.V, p.S, p.C, p.Cc, p.Ct

---@class down.edit.parse.Config
P.config = {}

---@class down.edit.parse.Data
P.data = {
  header_html = function(n)
    pre = string.rep("#", n)
    return P(pre)
        * (
          ((1 - V("NL")) ^ 0)
          / function(str)
            return string.format("<h%d>%s</h%d>", n, str, n)
          end
        )
  end,
}

P.setup = function()
  return {
    loaded = true,
    requires = {
      "tool.treesitter",
    },
  }
end

P.maps = function() end

-- local P, R, S, C, V = p.P, p.R, p.S, p.C, p.V
local Cc, Ct = p.Cc, p.Ct

return P
