B = {}

local fn, uv = vim.fn, vim.uv

B.check_md = function()
  return fn.expand("%:e") == "md"
end
B.check_ext = function(ext)
  return ext == fn.expand("%:e")
end

return B
