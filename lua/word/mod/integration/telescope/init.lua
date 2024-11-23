local M = Mod.create("integration.telescope")
local k = vim.keymap.set

M.setup = function()
  return {
    success = true,
    requires = { "workspace" }
  }
end

M.private = {
  picker_names = {
    "linkable",
    "find_md",
    -- "insert_link",
    -- "insert_file_link",
    -- "search_headings",
    -- "find_project_tasks",
    -- "find_aof_project_tasks",
    -- "find_aof_tasks",
    -- "find_context_tasks",
    "workspace",
    -- "backlinks.file_backlinks",
    -- "backlinks.header_backlinks",
  },
}
M.pickers = function()
  local r = {}
  for _, pic in ipairs(M.private.picker_names) do
    local ht, te = pcall(require, "telescope._extensions.word.picker." .. pic)
    if ht then
      r[pic] = te
    end
    r[pic] = require("telescope._extensions.word.picker." .. pic)
  end
  return r
end
M.load = function()
  local hast, t = pcall(require, "telescope")
  assert(hast, t)
  t.load_extension("word")
  for _, pic in ipairs(M.private.picker_names) do
    -- t.load_extension(pic)
    k("n", "<plug>word.telescope." .. pic .. "", M.pickers()[pic])
  end
end

return M
