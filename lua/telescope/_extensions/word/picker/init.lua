M = {
  pick = function(s) return require("telescope._extensions.word.picker." .. s) end
}
M = {
  find_md = M.pick("files"),
  workspace = M.pick("workspace"),
  linkable = M.pick("linkable"),

}

return M
