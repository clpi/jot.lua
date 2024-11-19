local bi = require("telescope.builtin")
local act = require("telescope.actions")
local state = require("telescope.actions.state")

local M = {}

M.browse_markdown_files = function(opts)
  opts = opts or {}
  opts.prompt_title = "Browse Markdown Files"
  opts.find_command = { "rg", "--files", "--glob", "*.md" }
  bi.find_files(opts)
end

M.grep_markdown_files = function(opts)
  opts = opts or {}
  opts.prompt_title = "Grep in Markdown Files"
  opts.search_dirs = { "path/to/markdown/files" }
  bi.live_grep(opts)
end

return M
