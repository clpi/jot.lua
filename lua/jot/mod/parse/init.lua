---@type jot.mod
local P = Mod.create("parse", { "scan", "md" })

local p = vim.lpeg
local R, V, S, C, Cc, Ct = p.R, p.V, p.S, p.C, p.Cc, p.Ct

P.config = {

}

P.public.data = {

}

---@class parse.public
P.public = {
  header_html = function(n)
    pre = string.rep('#', n)
    return P(pre) * (((1 - V "NL") ^ 0) / function(str)
      return string.format("<h%d>%s</h%d>", n, str, n)
    end)
  end

}

P.setup = function()
  return {
    loaded = true,
    requires = {
      "integration.treesitter"
    }
  }
end

P.load = function()

end

P.maps = function()

end



-- local P, R, S, C, V = p.P, p.R, p.S, p.C, p.V
local Cc, Ct = p.Cc, p.Ct




return P
