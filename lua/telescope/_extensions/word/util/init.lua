M = {}

local a = vim.api

function M.word(ns)
  local hasword, v = pcall(require, "word")
  assert(hasword, "word is not loaded - load it before telescope")
  a.nvim_create_namespace(ns)
end

function M.get_markdown_files()
  local markdown_files = {}
  local handle = io.popen('find . -type f -name "*.md"')
  if handle then
    for file in handle:lines() do
      table.insert(markdown_files, file)
    end
    handle:close()
  end
  return markdown_files
end

function M.grep_markdown_files(query)
  local results = {}
  local handle = io.popen('grep -r "' .. query .. '" . --include "*.md"')
  if handle then
    for line in handle:lines() do
      table.insert(results, line)
    end
    handle:close()
  end
  return results
end

return M
