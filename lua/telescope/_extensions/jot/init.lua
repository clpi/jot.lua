local hastel, tel = pcall(require, "telescope")
local hasact, act = pcall(require, "telescope.actions")
local set = require("telescope.actions.set")
local sta = require("telescope.actions.state")
local edi = require("telescope.pickers.entry_display")
local haspic, pic = pcall(require, "telescope.pickers")
local hassrt, srt = pcall(require, "telescope.sorters")
local hasfnd, fnd = pcall(require, "telescope.finders")
local haspre, pre = pcall(require, "telescope.previewers")
local hasbui, bui = pcall(require, "telescope.builtin")
local win = require("telescope.pickers.window")

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

function M.register()
  return tel.register_extension({
    exports = {
      jot = require("telescope.builtin").find_files,
      note = require("telescope._extensions.jot.picker.note"),
      lsp = require("telescope._extensions.jot.picker.lsp"),
      workspace = require("telescope._extensions.jot.picker.workspace"),
      todo = require("telescope._extensions.jot.picker.todo"),
      books = bui.fd,
      media = bui.fd,
      template = bui.fd,
      snippet = bui.fd,
      saved = bui.fd,
      images = bui.fd,
      log = bui.fd,
      commands = bui.fd,
      tag = bui.fd,
      plugin = bui.fd,
      config = bui.fd,
      actions = require("telescope._extensions.jot.picker.actions"),
      files = require("telescope._extensions.jot.picker.files"),
      linkables = require("telescope._extensions.jot.picker.linkable"),
      link = require("telescope._extensions.jot.picker.link")
    }
  })
end

function M.setup()
  M.register()
  -- tel.setup_extension("jot")
end

-- return M
--
return M
