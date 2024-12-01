local hastel, tel = pcall(require, "telescope")
local hasact, act = pcall(require, "telescope.actions")
-- local set = require("telescope.actions.set")
-- local sta = require("telescope.actions.state")
-- local edi = require("telescope.pickers.entry_display")
-- local cfg = require("telescope.config")
local haspic, pic = pcall(require, "telescope.pickers")
local hassrt, srt = pcall(require, "telescope.sorters")
local hasfnd, fnd = pcall(require, "telescope.finders")
local haspre, pre = pcall(require, "telescope.previewers")
-- local haspre, pre = pcall(require,"telescope.")
local hasbui, bui = pcall(require, "telescope.builtin")
-- local win = require("telescope.pickers.window")

local has_jot, jot = pcall(require, "jot")

local M = {}


function M.setup_keys()
  local map = vim.api.nvim_set_keymap
  local opt = { noremap = true, silent = true }
  map("n", ",vv", "<cmd>lua require('telescope._extensions.jot').custom_picker()<CR>", opt)
end

function M.custom_picker()
  pic.new({}, {
    prompt_title = "jot finder",
    results_title = "results",
    sorter = srt.get_generic_fuzzy_sorter(),
    finder = fnd.new_table {
      results = {
        'Index',
        'Notes'
      }
    },
    attach_mappings = function(prompt_bufnr, map)
      act.select_base:replace(function()
        local sel = act.get_selected_entry()
        act.close(prompt_bufnr)
        if sel.value == 'Index' then
          require('jot.index').index()
        elseif sel.value == 'Notes' then
          require('jot.notes').notes()
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
      notes = M.custom_picker(),
      headings = bui.live_grep(),
      grep = bui.live_grep()
    }
  })
  tel.setup_extension("jot")
end

-- return M
--
return tel.register_extension {
  -- setup = jot.setup,
  exports = {
    jot = require("telescope.builtin").find_files,
    todo = bui.live_grep,
    lsp = bui.lsp_definitions,
    books = bui.fd,
    find_jot = require("telescope._extensions.jot.picker.files"),
    linkables = require("telescope._extensions.jot.picker.linkable"),
    workspace = require("telescope._extensions.jot.picker.workspace")
  }
}
