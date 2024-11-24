P = {}

local peg = vim.lpeg
local P, R, S, V, B = peg.P, peg.R, peg.S, peg.V, peg.B
local C, Cc, Cf, Cg, Cs, Ct = peg.C, peg.Cc, peg.Cf, peg.Cg, peg.Cs, peg.Ct

local pathsep = P("/")

local patt = peg.P

return P
