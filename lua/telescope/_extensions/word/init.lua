local hastel, tel = pcall(require, "telescope")
local hasact, act = pcall(require, "telescope.actions")
local haspic, pic = pcall(require, "telescope.pickers")
local hassrt, srt = pcall(require, "telescope.sorters")
local hasfnd, fnd = pcall(require, "telescope.finders")
local haspre, pre = pcall(require, "telescope.previewers")
local hasbui, bui = pcall(require, "telescope.builtin")

local has_word, word = pcall(require, "word")

local M = {}

function M.setup_keys()
  local map = vim.api.nvim_set_keymap
  local opt = { noremap = true, silent = true }
  map("n", ",vv", "<cmd>lua require('telescope._extensions.word').custom_picker()<CR>", opt)
end

function M.custom_picker()
  pic.new({}, {
    prompt_title = "word finder",
    results_title = "results",
    sorter = srt.get_generic_fuzzy_sorter(),
    finder = fnd.new_table {
      results = {
        'Index',
        'Notes'
      }
    },
    attach_mappings = function(prompt_bufnr, map)
      act.select_default:replace(function()
        local sel = act.get_selected_entry()
        act.close(prompt_bufnr)
        if sel.value == 'Index' then
          require('word.index').index()
        elseif sel.value == 'Notes' then
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

function M.setup_telescope()
  tel.setup {
    extensions = {
      word = {
        pickers = {
          markdown_files = {
            theme = "dropdown",
            previewer = false,
            layout_config = {
              width = 0.5,
              height = 0.4,
            },
          },
          grep_markdown_files = {
            theme = "dropdown",
            previewer = false,
            layout_config = {
              width = 0.5,
              height = 0.4,
            },
          },
        },
      },
    },
  }
end

function M.setup()
  M.setup_telescope()
  tel.register_extension({
    exports = {
      notes = M.custom_picker,
      headings = bui.live_grep,
      grep = bui.live_grep,
      markdown_files = function(opts)
        opts = opts or {}
        opts.prompt_title = "Markdown Files"
        opts.find_command = { "rg", "--files", "--glob", "*.md" }
        bui.find_files(opts)
      end,
      grep_markdown_files = function(opts)
        opts = opts or {}
        opts.prompt_title = "Grep in Markdown Files"
        opts.search_dirs = { "path/to/markdown/files" }
        bui.live_grep(opts)
      end,
    }
  })
  tel.load_extension("word")
end

return tel.register_extension {
  exports = {
    notes = M.custom_picker,
    headings = bui.live_grep,
    grep = bui.live_grep,
    markdown_files = function(opts)
      opts = opts or {}
      opts.prompt_title = "Markdown Files"
      opts.find_command = { "rg", "--files", "--glob", "*.md" }
      bui.find_files(opts)
    end,
    grep_markdown_files = function(opts)
      opts = opts or {}
      opts.prompt_title = "Grep in Markdown Files"
      opts.search_dirs = { "path/to/markdown/files" }
      bui.live_grep(opts)
    end,
  }
}
