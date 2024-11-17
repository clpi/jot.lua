local hastel, tel = pcall(require, "telescope")
-- local act = require("telescope.actions")
-- local set = require("telescope.actions.set")
-- local sta = require("telescope.actions.state")
-- local edi = require("telescope.pickers.entry_display")
-- local cfg = require("telescope.config")
-- local pic = require("telescope.pickers")
-- local fnd = require("telescope.finders")
-- local pre = require("telescope.previewers")
-- local srt = require("telescope.sorters")
local hasbui, bui = pcall(require, "telescope.builtin")
-- local win = require("telescope.pickers.window")

local has_word, word = pcall(require, "word")

local M = {}


function M.setup_keys()
  local map = vim.api.nvim_set_keymap
  local opt = { noremap = true, silent = true }
  map("n", ",vv", "<cmd>lua require('telescope._extensions.word').custom_picker()<CR>", opt)
end

function M.custom_picker()
  pic.new({}, {
    prompt_title = "word",
    sorter = srt.get_generic_fuzzy_sorter(),
    finder = fnd.new_table {
      results = {
        'Index',
        'Notes'
      }
    },
    attach_mappings = function(prompt_bufnr, map)
      act.select_base:replace(function()
        local selection = act.get_selected_entry()
        act.close(prompt_bufnr)
        if selection.value == 'Index' then
          require('word.index').index()
        elseif selection.value == 'Notes' then
          require('word.notes').notes()
        end
      end)
      return true
    end,
    previewer = pre.new_termopen_previewer({
      get_command = function(entry)
        return { "echo", entry.value }
      end
    })
  }):find()
end

function M.setup()
  tel.register_extension({
    exports = {
      notes = M.custom_picker()

    }
  })
  tel.load_extension("word")
end

-- return M
--
return tel.register_extension {
  -- setup = word.setup,
  exports = {
    -- word = require("telescope.builtin").find_files
  }
}
