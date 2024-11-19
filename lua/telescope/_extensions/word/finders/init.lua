local browse_markdown_files = require("telescope._extensions.word.finders.browse")
local find_markdown_files = require("telescope._extensions.word.finders.files")
local grep_markdown_files = require("telescope._extensions.word.finders.grep")

local M = {}

function M.init()
  -- Initialize the finders
  browse_markdown_files()
  find_markdown_files()
  grep_markdown_files()
end

return M
