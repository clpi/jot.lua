local browse_markdown_files = require("telescope._extensions.word.finders.browse")
local find_markdown_files = require("telescope._extensions.word.finders.files")
local grep_markdown_files = require("telescope._extensions.word.finders.grep")

local M = {}

function M.browse_markdown_files(opts)
  browse_markdown_files(opts)
end

function M.find_markdown_files(opts)
  find_markdown_files(opts)
end

function M.grep_markdown_files(opts)
  grep_markdown_files(opts)
end

return M
