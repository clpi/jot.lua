local M = {}

local function browse_markdown_files(opts)
  opts = opts or {}
  opts.prompt_title = "Browse Markdown Files"
  opts.find_command = { "rg", "--files", "--glob", "*.md" }
  require("telescope.builtin").find_files(opts)
end

local function grep_markdown_files(opts)
  opts = opts or {}
  opts.prompt_title = "Grep in Markdown Files"
  opts.search_dirs = { "path/to/markdown/files" }
  require("telescope.builtin").live_grep(opts)
end

M.browse_markdown_files = browse_markdown_files
M.grep_markdown_files = grep_markdown_files

return M
