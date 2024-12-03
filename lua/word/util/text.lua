local U = {}
function U.trim(s)
  return s:match("^%s*(.-)%s*$")
end

return U
