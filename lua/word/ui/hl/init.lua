H = {}

H.add_hl_group = function(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

return H
