M = {
  pick = function(s) return require("lua.telescope._extensions.word.picker." .. s) end
}
M = {
  find_md = M.pick("find_md"),
  workspace = M.pick("workspace"),
  linkable = M.pick("linkable"),

}

return M
