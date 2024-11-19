local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

function M.markdown_files(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Markdown Files",
    finder = finders.new_oneshot_job({ "rg", "--files", "--glob", "*.md" }),
    sorter = sorters.get_fuzzy_file(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd("edit " .. selection[1])
      end)
      return true
    end,
  }):find()
end

function M.grep_markdown_files(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Grep in Markdown Files",
    finder = finders.new_oneshot_job({ "rg", "--files", "--glob", "*.md" }),
    sorter = sorters.get_fuzzy_file(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd("grep " .. selection[1])
      end)
      return true
    end,
  }):find()
end

return M
