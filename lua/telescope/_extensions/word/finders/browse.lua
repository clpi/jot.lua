local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local browse_markdown_files = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Browse Markdown Files",
    finder = finders.new_oneshot_job({ "rg", "--files", "--glob", "*.md" }, opts),
    sorter = sorters.get_fuzzy_file(),
    previewer = previewers.vim_buffer_cat.new(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd("edit " .. selection.value)
      end)
      return true
    end,
  }):find()
end

return browse_markdown_files
