--[[
    file: conceal
    title: Display Markup as Icons, not Text
    description: The conceal M converts verbose markup elements into beautified icons for your viewing pleasure.
    summary: Enhances the basic dorm experience by using icons instead of text.
    embed: https://user-images.githubusercontent.com/76052559/216767027-726b451d-6da1-4d09-8fa4-d08ec4f93f54.png
    ---
"Concealing" is the process of hiding away from plain sight. When writing raw dorm, long strings like
`***** Hello` or `$$ Definition` can be distracting and sometimes unpleasant when sifting through large notes.

To reduce the amount of cognitive load required to "parse" dorm documents with your own eyes, this M
masks, or sometimes completely hides many categories of markup.

The conceal depends on [Nerd Fonts >=v3.0.1](https://github.com/ryanoasis/nerd-fonts/releases/latest) to be
installed on your system.

This M respects `:h conceallevel` and `:h concealcursor`. Setting the wrong values for these options can
make it look like this M isn't working.
--]]

-- utils  to be refactored

local d = require("dorm")
local u = require("dorm.mod.icon.util")
local log, mod, utils = d.log, d.mod, d.utils


--- end utils

local M = mod.create("icon", {
  -- "basic",
  -- "diamond"
})

M.setup = function()
  return {
    success = true,
    requires = {
      "autocmd",
      "treesitter",
    },
  }
end

M.private = {
  ns_icon = utils.ns("dorm-icon"),
  ns_prettify_flag = utils.ns("dorm-icon.prettify-flag"),
  rerendering_scheduled_bufids = {},
  enabled = true,
  cursor_record = {},
}



---@class base.icon
M.public = {
  icon_renderers = {
    on_left = function(config, bufid, node)
      if not config.icon then
        return
      end
      local row_0b, col_0b, len = get_node_position_and_text_length(bufid, node)
      local text = (" "):rep(len - 1) .. config.icon
      set_mark(bufid, row_0b, col_0b, text, config.highlight)
    end,

    multilevel_on_right = function(is_ordered)
      return function(config, bufid, node)
        if not config.icons then
          return
        end

        local row_0b, col_0b, len = get_node_position_and_text_length(bufid, node)
        local icon_pattern = table_get_base_last(config.icons, len)
        if not icon_pattern then
          return
        end

        local icon = not is_ordered and icon_pattern
            or format_ordered_icon(icon_pattern, get_ordered_index(bufid, node))
        if not icon then
          return
        end

        local text = (" "):rep(len - 1) .. icon

        local _, first_unicode_end = text:find("[%z\1-\127\194-\244][\128-\191]*", len)
        local highlight = config.hl and table_get_base_last(config.hl, len)
        set_mark(bufid, row_0b, col_0b, text:sub(1, first_unicode_end), highlight)
        if vim.fn.strcharlen(text) > len then
          set_mark(bufid, row_0b, col_0b + len, text:sub(first_unicode_end + 1), highlight, {
            virt_text_pos = "inline",
          })
        end
      end
    end,

    footnote_concealed = function(config, bufid, node)
      local link_title_node = node:next_named_sibling()
      local link_title = vim.treesitter.get_node_text(link_title_node, bufid)
      if config.numeric_superscript and link_title:match("^[-0-9]+$") then
        local t = {}
        for i = 1, #link_title do
          local d = link_title:sub(i, i)
          table.insert(t, superscript_digits[d])
        end
        local superscripted_title = table.concat(t)
        local row_start_0b, col_start_0b, _, _ = link_title_node:range()
        local highlight = config.title_highlight
        set_mark(bufid, row_start_0b, col_start_0b, superscripted_title, highlight)
      end
    end,

    ---@param node TSNode
    quote_concealed = function(config, bufid, node)
      if not config.icons then
        return
      end

      local prefix = node:named_child(0)

      local row_0b, col_0b, len = get_node_position_and_text_length(bufid, prefix)

      local last_icon, last_highlight

      for _, child in ipairs(node:field("content")) do
        local row_last_0b, col_last_0b = child:end_()

        -- Sometimes the parser overshoots to the next newline, breaking
        -- the range.
        -- To counteract this we correct the overshoot.
        if col_last_0b == 0 then
          row_last_0b = row_last_0b - 1
        end

        for line = row_0b, row_last_0b do
          if get_line_length(bufid, line) > len then
            for col = 1, len do
              if config.icons[col] ~= nil then
                last_icon = config.icons[col]
              end
              if not last_icon then
                goto continue
              end
              last_highlight = config.hl[col] or last_highlight
              set_mark(bufid, line, col_0b + (col - 1), last_icon, last_highlight)
              ::continue::
            end
          end
        end
      end
    end,

    fill_text = function(config, bufid, node)
      if not config.icon then
        return
      end
      local row_0b, col_0b, len = get_node_position_and_text_length(bufid, node)
      local text = config.icon:rep(len)
      set_mark(bufid, row_0b, col_0b, text, config.highlight)
    end,

    fill_multiline_chop2 = function(config, bufid, node)
      if not config.icon then
        return
      end
      local row_start_0b, col_start_0b, row_end_0bin, col_end_0bex = node:range()
      for i = row_start_0b, row_end_0bin do
        local l = i == row_start_0b and col_start_0b + 1 or 0
        local r_ex = i == row_end_0bin and col_end_0bex - 1 or get_line_length(bufid, i)
        set_mark(bufid, i, l, config.icon:rep(r_ex - l), config.highlight)
      end
    end,

    render_horizontal_line = function(config, bufid, node)
      if not config.icon then
        return
      end

      local row_start_0b, col_start_0b, _, col_end_0bex = node:range()
      local render_col_start_0b = config.left == "here" and col_start_0b or 0
      local opt_textwidth = vim.bo[bufid].textwidth
      local render_col_end_0bex = config.right == "textwidth" and (opt_textwidth > 0 and opt_textwidth or 79)
          or vim.api.nvim_win_get_width(assert(vim.fn.bufwinid(bufid)))
      local len = math.max(col_end_0bex - col_start_0b, render_col_end_0bex - render_col_start_0b)
      set_mark(bufid, row_start_0b, render_col_start_0b, config.icon:rep(len), config.highlight)
    end,

    render_code_block = function(config, bufid, node)
      local tag_name = vim.treesitter.get_node_text(node:named_child(0), bufid)
      if not (tag_name == "code" or tag_name == "embed") then
        return
      end

      local row_start_0b, col_start_0b, row_end_0bin = node:range()
      assert(row_start_0b < row_end_0bin)
      local conceal_on = (vim.wo.conceallevel >= 2) and config.conceal

      if conceal_on then
        for _, row_0b in ipairs({ row_start_0b, row_end_0bin }) do
          vim.api.nvim_buf_set_extmark(
            bufid,
            M.private.ns_icon,
            row_0b,
            0,
            { end_col = get_line_length(bufid, row_0b), conceal = "" }
          )
        end
      end

      if conceal_on or config.content_only then
        row_start_0b = row_start_0b + 1
        row_end_0bin = row_end_0bin - 1
      end

      local line_lengths = {}
      local max_len = config.min_width or 0
      for row_0b = row_start_0b, row_end_0bin do
        local len = get_line_length(bufid, row_0b)
        if len > max_len then
          max_len = len
        end
        table.insert(line_lengths, len)
      end

      local to_eol = (config.width ~= "content")

      for row_0b = row_start_0b, row_end_0bin do
        local len = line_lengths[row_0b - row_start_0b + 1]
        local mark_col_start_0b = math.max(0, col_start_0b - config.padding.left)
        local mark_col_end_0bex = max_len + config.padding.right
        local priority = 101
        if len >= mark_col_start_0b then
          vim.api.nvim_buf_set_extmark(bufid, M.private.ns_icon, row_0b, mark_col_start_0b, {
            end_row = row_0b + 1,
            hl_eol = to_eol,
            hl_group = config.highlight,
            hl_mode = "blend",
            virt_text = not to_eol and { { (" "):rep(mark_col_end_0bex - len), config.highlight } } or nil,
            virt_text_pos = "overlay",
            virt_text_win_col = len,
            spell = config.spell_check,
            priority = priority,
          })
        else
          vim.api.nvim_buf_set_extmark(bufid, M.private.ns_icon, row_0b, len, {
            end_row = row_0b + 1,
            hl_eol = to_eol,
            hl_group = config.highlight,
            hl_mode = "blend",
            virt_text = {
              { (" "):rep(mark_col_start_0b - len) },
              { not to_eol and (" "):rep(mark_col_end_0bex - mark_col_start_0b) or "", config.highlight },
            },
            virt_text_pos = "overlay",
            virt_text_win_col = len,
            spell = config.spell_check,
            priority = priority,
          })
        end
      end
    end,
  },

  icon_removers = {
    quote = function(_, bufid, node)
      for _, content in ipairs(node:field("content")) do
        local end_row, end_col = content:end_()

        -- This counteracts the issue where a quote can span onto the next
        -- line, even though it shouldn't.
        if end_col == 0 then
          end_row = end_row - 1
        end

        vim.api.nvim_buf_clear_namespace(bufid, M.private.ns_icon, (content:start()), end_row + 1)
      end
    end,
  },
}

M.config.public = {
  -- Which icon preset to use.
  --
  -- The currently available icon presets are:
  -- - "basic" - use a mixture of icons (includes cute flower icons!)
  -- - "diamond" - use diamond shapes for headings
  preset = "basic",

  -- If true, dorm will enable folding by base for `.dorm` documents.
  -- You may use the inbuilt Neovim folding options like `foldnestmax`,
  -- `foldlevelstart` and others to then tune the behaviour to your liking.
  --
  -- Set to `false` if you do not want dorm setting anything.
  folds = true,

  -- When set to `auto`, dorm will open all folds when opening new documents if `foldlevel` is 0.
  -- When set to `always`, dorm will always open all folds when opening new documents.
  -- When set to `never`, dorm will not do anything.
  init_open_folds = "auto",

  -- Configuration for icons.
  --
  -- This table contains the full configuration set for each icon, including
  -- its query (where to be placed), render functions (how to be placed) and
  -- characters to use.
  --
  -- For most use cases, the only values that you should be changing is the `icon`/`icons` field.
  -- `icon` is a string, while `icons` is a table of strings for multilevel elements like
  -- headings, lists, and quotes.
  --
  -- To disable part of the config, replace the table with `false`, or prepend `false and` to it.
  -- For example: `done = false` or `done = false and { ... }`.
  icons = {
    todo = {
      done = {
        icon = "󰄬",
        nodes = { "todo_item_done" },
        render = M.public.icon_renderers.on_left,
      },
      pending = {
        icon = "󰥔",
        nodes = { "todo_item_pending" },
        render = M.public.icon_renderers.on_left,
      },
      undone = {
        icon = " ",
        nodes = { "todo_item_undone" },
        render = M.public.icon_renderers.on_left,
      },
      uncertain = {
        icon = "",
        nodes = { "todo_item_uncertain" },
        render = M.public.icon_renderers.on_left,
      },
      on_hold = {
        icon = "",
        nodes = { "todo_item_on_hold" },
        render = M.public.icon_renderers.on_left,
      },
      cancelled = {
        icon = "",
        nodes = { "todo_item_cancelled" },
        render = M.public.icon_renderers.on_left,
      },
      recurring = {
        icon = "↺",
        nodes = { "todo_item_recurring" },
        render = M.public.icon_renderers.on_left,
      },
      urgent = {
        icon = "⚠",
        nodes = { "todo_item_urgent" },
        render = M.public.icon_renderers.on_left,
      },
    },

    list = {
      icons = { "•" },
      nodes = {
        "unordered_list1_prefix",
        "unordered_list2_prefix",
        "unordered_list3_prefix",
        "unordered_list4_prefix",
        "unordered_list5_prefix",
        "unordered_list6_prefix",
      },
      render = M.public.icon_renderers.multilevel_on_right(false),
    },
    ordered = {
      icons = { "1.", "A.", "a.", "(1)", "I.", "i." },
      nodes = {
        "ordered_list1_prefix",
        "ordered_list2_prefix",
        "ordered_list3_prefix",
        "ordered_list4_prefix",
        "ordered_list5_prefix",
        "ordered_list6_prefix",
      },
      render = M.public.icon_renderers.multilevel_on_right(true),
    },
    quote = {
      icons = { "│" },
      nodes = {
        "quote1",
        "quote2",
        "quote3",
        "quote4",
        "quote5",
        "quote6",
      },
      hl = {
        "@dorm.quotes.1.prefix",
        "@dorm.quotes.2.prefix",
        "@dorm.quotes.3.prefix",
        "@dorm.quotes.4.prefix",
        "@dorm.quotes.5.prefix",
        "@dorm.quotes.6.prefix",
      },
      render = M.public.icon_renderers.quote_concealed,
      clear = M.public.icon_removers.quote,
    },
    heading = {
      icons = { "◉", "◎", "○", "✺", "▶", "⤷" },
      hl = {
        "@dorm.headings.1.prefix",
        "@dorm.headings.2.prefix",
        "@dorm.headings.3.prefix",
        "@dorm.headings.4.prefix",
        "@dorm.headings.5.prefix",
        "@dorm.headings.6.prefix",
      },
      nodes = {
        "heading1_prefix",
        "heading2_prefix",
        "heading3_prefix",
        "heading4_prefix",
        "heading5_prefix",
        "heading6_prefix",
        concealed = {
          "link_target_heading1",
          "link_target_heading2",
          "link_target_heading3",
          "link_target_heading4",
          "link_target_heading5",
          "link_target_heading6",
        },
      },
      render = M.public.icon_renderers.multilevel_on_right(false),
    },
    definition = {
      single = {
        icon = "≡",
        nodes = { "single_definition_prefix", concealed = { "link_target_definition" } },
        render = M.public.icon_renderers.on_left,
      },
      multi_prefix = {
        icon = "⋙ ",
        nodes = { "multi_definition_prefix" },
        render = M.public.icon_renderers.on_left,
      },
      multi_suffix = {
        icon = "⋘ ",
        nodes = { "multi_definition_suffix" },
        render = M.public.icon_renderers.on_left,
      },
    },

    footnote = {
      single = {
        icon = "⁎",
        -- When set to true, footnote link with numeric title will be
        -- concealed to superscripts.
        numeric_superscript = true,
        title_highlight = "@dorm.footnotes.title",
        nodes = { "single_footnote_prefix", concealed = { "link_target_footnote" } },
        render = M.public.icon_renderers.on_left,
        render_concealed = M.public.icon_renderers.footnote_concealed,
      },
      multi_prefix = {
        icon = "⁑ ",
        nodes = { "multi_footnote_prefix" },
        render = M.public.icon_renderers.on_left,
      },
      multi_suffix = {
        icon = "⁑ ",
        nodes = { "multi_footnote_suffix" },
        render = M.public.icon_renderers.on_left,
      },
    },

    delimiter = {
      weak = {
        icon = "⟨",
        highlight = "@dorm.delimiters.weak",
        nodes = { "weak_paragraph_delimiter" },
        render = M.public.icon_renderers.fill_text,
      },
      strong = {
        icon = "⟪",
        highlight = "@dorm.delimiters.strong",
        nodes = { "strong_paragraph_delimiter" },
        render = M.public.icon_renderers.fill_text,
      },
      horizontal_line = {
        icon = "─",
        highlight = "@dorm.delimiters.horizontal_line",
        nodes = { "horizontal_line" },
        -- The starting position of horizontal lines:
        -- - "window": the horizontal line starts from the first column, reaching the left of the window
        -- - "here": the horizontal line starts from the node column
        left = "here",
        -- The ending position of horizontal lines:
        -- - "window": the horizontal line ends at the last column, reaching the right of the window
        -- - "textwidth": the horizontal line ends at column `textwidth` or 79 when it's set to zero
        right = "window",
        render = M.public.icon_renderers.render_horizontal_line,
      },
    },

    markup = {
      spoiler = {
        icon = "•",
        highlight = "@dorm.markup.spoiler",
        nodes = { "spoiler" },
        render = M.public.icon_renderers.fill_multiline_chop2,
      },
    },

    -- Options that control the behaviour of code block dimming
    -- (placing a darker background behind `@code` tags).
    code_block = {
      -- If true will only dim the content of the code block (without the
      -- `@code` and `@end` lines), not the entirety of the code block itself.
      content_only = true,

      -- The width to use for code block backgrounds.
      --
      -- When set to `fullwidth` (the base), will create a background
      -- that spans the width of the buffer.
      --
      -- When set to `content`, will only span as far as the longest line
      -- within the code block.
      width = "fullwidth",

      -- When set to a number, the code block background will be at least
      -- this many chars wide. Useful in conjunction with `width = "content"`
      min_width = nil,

      -- Additional padding to apply to either the left or the right. Making
      -- these values negative is considered undefined behaviour (it is
      -- likely to work, but it's not officially supported).
      padding = {
        left = 0,
        right = 0,
      },

      -- If `true` will conceal (hide) the `@code` and `@end` portion of the code
      -- block.
      conceal = false,

      -- If `false` will disable spell check on code blocks when 'spell' option is switched on.
      spell_check = true,

      nodes = { "ranged_verbatim_tag" },
      highlight = "@dorm.tags.ranged_verbatim.code_block",
      render = M.public.icon_renderers.render_code_block,
      insert_enabled = true,
    },
  },
}


M.config.public =
    vim.tbl_deep_extend("force", M.config.public, { icons = preset }, M.config.custom or {})

-- M.required["autocmd"].enable_autocommand("BufNewFile")
M.required["autocmd"].enable_autocommand("FileType", true)
M.required["autocmd"].enable_autocommand("BufReadPost")
M.required["autocmd"].enable_autocommand("InsertEnter")
M.required["autocmd"].enable_autocommand("InsertLeave")
M.required["autocmd"].enable_autocommand("CursorMoved")
M.required["autocmd"].enable_autocommand("CursorMovedI")
M.required["autocmd"].enable_autocommand("WinScrolled", true)

mod.await("cmd", function(cmd)
  cmd.add_commands_from_table({
    ["icon"] = {
      name = "icon",
      args = 0,
      condition = "dorm",
      subcommands = {
        ["toggle"] = {
          args = 0,
          name = "icon.toggle"

        }
      }
    },
  })
end)

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "conceallevel",
  callback = function()
    local bufid = vim.api.nvim_get_current_buf()
    if vim.bo[bufid].ft ~= "dorm" then
      return
    end
    mark_all_lines_changed(bufid)
  end,
})
-- end

M.events.subscribed = {
  ["autocmd"] = {
    -- bufnewfile = true,
    filetype = true,
    bufreadpost = true,
    insertenter = true,
    insertleave = true,
    cursormoved = true,
    cursormovedi = true,
    winscrolled = true,
  },

  ["cmd"] = {
    ["icon.toggle"] = true,
  },
}

return M
