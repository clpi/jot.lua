--[[
    file: link
    title: Find link/target in the buffer
    description: Utility M to handle link/link targets in the buffer
    internal: true
    ---

This M provides utility functions that are used to find link and their targets in the buffer.
--]]

local word = require("word")
local lib, mod, u = word.lib, word.mod, word.utils

local M = mod.create("link")
u.ns("word-link")
M.pathType = function(path, anchor)
  if not path then
    return nil
  elseif string.find(path, '^file:') then
    return 'file'
  elseif string.find(path, "https://") then
    return 'url'
  elseif string.find(path, '^@') then
    return 'citation'
  elseif path == '' and anchor then
    return 'anchor'
  else
    return 'nb_page'
  end
end
M.setup = function()
  return {
    success = true,
    requires = {
      "workspace",
      "data"
    }
  }
end

M.config.public = {
  conceal = true,
  style = "markdown",
  implicit_extension = nil,
  tranform_implicit = false,
  create_on_follow_fail = true,
  context = 0,
  name_as_source = false,
  transform_explicit = function(text)
    text = text:gsub('[ /]', '-')
    text = text:lower()
    text = os.date('%Y-%m-%d_') .. text
    return text
  end,
}
---@class link
M.public = {
  contains = function(start_row, start_col, end_row, end_col, cur_row, cur_col)
    local contained = cur_row > start_row and cur_row < end_row
    if cur_row == start_row and start_row == end_row then
      contained = cur_col > start_col - 1 and cur_col <= end_col
    elseif cur_row == start_row then
      contained = cur_col > start_col - 1
    elseif cur_row == end_row then
      contained = cur_col <= end_col
    end
    return contained
  end,
  getLinkUnderCursor = function(col)
    local position = vim.api.nvim_win_get_cursor(0)
    local capture, start_row, start_col, end_row, end_col, match, match_lines
    col = col or position[2]
    local patterns = {
      md_link = '(%b[]%b())',
      wiki_link = '(%[%b[]%])',
      ref_style_link = '(%b[]%s?%b[])',
      auto_link = '(%b<>)',
      citation = "[^%a%d]-(@[%a%d_%.%-']*[%a%d]+)[%s%p%c]?",
    }
    local row = position[1]
    local lines = vim.api.nvim_buf_get_lines(0, row - 1 - M.config.public.context, row + M.config.public.context, false)
    -- Iterate through the patterns to see if there's a matching link under the cursor
    for link_type, pattern in pairs(patterns) do
      local init_row, init_col = 1, 1
      local continue = true
      while continue do
        -- Look for the pattern in the line(s)
        --link_start, link_finish, capture = string.find(lines, pattern, init)
        start_row, start_col, end_row, end_col, capture, match_lines =
            utils.mFind(lines, pattern, row - M.config.public.context, init_row, init_col)
        if start_row and link_type == 'citation' then
          local possessor = string.gsub(capture, "'s$", '') -- Remove Saxon genitive if it's on the end of the citekey
          if #capture > #possessor then
            capture = possessor
            end_col = end_col - 2
          end
        end
        -- Check for overlap w/ cursor
        if start_row then -- There's a match
          local overlaps =
              M.public.contains(start_row, start_col, end_row, end_col, position[1], position[2] + 1)
          if overlaps then
            match = capture
            continue = false
          else
            init_row, init_col = end_row, end_col
          end
        else
          continue = false
        end
      end
      if match then -- Return the match and type of link if there was a match
        return { match, match_lines, link_type, start_row, start_col, end_row, end_col }
      end
    end
  end,
  formatLink = function(text, source, part)
    local replacement, path_text
    -- If the text starts with a hash, format the link as an anchor link
    if string.sub(text, 0, 1) == '#' and not source then
      path_text = string.gsub(text, '[^%a%s%d%-_]', '')
      text = string.gsub(text, '^#* *', '')
      path_text = string.gsub(path_text, '^ ', '')
      path_text = string.gsub(path_text, ' ', '-')
      path_text = string.gsub(path_text, '%-%-', '-')
      path_text = '#' .. string.lower(path_text)
    elseif not source then
      path_text = M.transformPath(text)
      -- If no path_text, end here
      if not path_text then
        return
      end
      if not M.config.public.implicit_extension then
        path_text = path_text .. '.md'
      end
    else
      path_text = source
    end
    -- Format the replacement depending on the user's link style preference
    if M.config.public.style == 'wiki' then
      replacement = (M.config.public.name_as_source and { '[[' .. text .. ']]' })
          or { '[[' .. path_text .. '|' .. text .. ']]' }
    else
      replacement = { '[' .. text .. ']' .. '(' .. path_text .. ')' }
    end
    -- Return the requested part
    if part == nil then
      return replacement
    elseif part == 1 then
      return text
    elseif part == 2 then
      return path_text
    end
  end,
  -- TS query strings for different link targets
  ---@param link_type "generic" | "definition" | "footnote" | string
  get_link_target_query_string = function(link_type)
    return lib.match(link_type)({
      generic = [[
                [(_
                  [(strong_carryover_set
                     (strong_carryover
                       name: (tag_name) @tag_name
                       (tag_parameters) @title
                       (#eq? @tag_name "name")))
                   (weak_carryover_set
                     (weak_carryover
                       name: (tag_name) @tag_name
                       (tag_parameters) @title
                       (#eq? @tag_name "name")))]?
                  title: (paragraph_segment) @title)
                 (inline_link_target
                   (paragraph) @title)]
            ]],

      [{ "definition", "footnote" }] = string.format(
        [[
                (%s_list
                    (strong_carryover_set
                          (strong_carryover
                            name: (tag_name) @tag_name
                            (tag_parameters) @title
                            (#eq? @tag_name "name")))?
                    .
                    [(single_%s
                       (weak_carryover_set
                          (weak_carryover
                            name: (tag_name) @tag_name
                            (tag_parameters) @title
                            (#eq? @tag_name "name")))?
                       (single_%s_prefix)
                       title: (paragraph_segment) @title)
                     (multi_%s
                       (weak_carryover_set
                          (weak_carryover
                            name: (tag_name) @tag_name
                            (tag_parameters) @title
                            (#eq? @tag_name "name")))?
                        (multi_%s_prefix)
                          title: (paragraph_segment) @title)])
                ]],
        lib.reparg(link_type, 5)
      ),
      _ = string.format(
        [[
                    (%s
                      [(strong_carryover_set
                         (strong_carryover
                           name: (tag_name) @tag_name
                           (tag_parameters) @title
                           (#eq? @tag_name "name")))
                       (weak_carryover_set
                         (weak_carryover
                           name: (tag_name) @tag_name
                           (tag_parameters) @title
                           (#eq? @tag_name "name")))]?
                      (%s_prefix)
                      title: (paragraph_segment) @title)
                ]],
        lib.reparg(link_type, 2)
      ),
    })
  end,
  createLink = function(args)
    args = args or {}
    local from_clipboard = args.from_clipboard or false
    local range = args.range or false
    -- Get mode from vim
    local mode = vim.api.nvim_get_mode()['mode']
    -- Get the cursor position
    local position = vim.api.nvim_win_get_cursor(0)
    local row = position[1]
    local col = position[2]
    -- If the current mode is 'normal', make link from word under cursor
    if mode == 'n' and not range then
      -- Get the text of the line the cursor is on
      local line = vim.api.nvim_get_current_line()
      local url_start, url_end = M.hasUrl(line, 'positions', col)
      if url_start and url_end then
        -- Prepare the replacement
        local url = line:sub(url_start, url_end - 1)
        local replacement = (M.config.public.links.style == 'wiki' and { '[[' .. url .. '|]]' })
            or { '[]' .. '(' .. url .. ')' }
        -- Replace
        vim.api.nvim_buf_set_text(0, row - 1, url_start - 1, row - 1, url_end - 1, replacement)
        -- Move the cursor to the name part of the link and change mode
        if M.config.public.links.style == 'wiki' then
          vim.api.nvim_win_set_cursor(0, { row, url_end + 2 })
        else
          vim.api.nvim_win_set_cursor(0, { row, url_start })
        end
        vim.cmd('startinsert')
      else
        -- Get the word under the cursor
        local cursor_word = vim.fn.expand('<cword>')
        -- Make a markdown link out of the date and cursor
        local replacement
        if from_clipboard then
          replacement = M.formatLink(cursor_word, vim.fn.getreg('+'))
        else
          replacement = M.formatLink(cursor_word)
        end
        -- If there's no replacement, stop here
        if not replacement then
          return
        end
        -- Find the (first) position of the matched word in the line
        local left, right = string.find(line, cursor_word, nil, true)
        -- Make sure it's not a duplicate of the word under the cursor, and if it
        -- is, perform the search until a match is found whose right edge follows
        -- the cursor position
        if cursor_word ~= '' then
          for _left, _right in utils.gmatch(line, cursor_word) do
            if _right >= col then
              left = _left
              right = _right
              break
            end
          end
        else
          left, right = col + 1, col
        end
        -- Replace the word under the cursor w/ the formatted link replacement
        vim.api.nvim_buf_set_text(0, row - 1, left - 1, row - 1, right, replacement)
        vim.api.nvim_win_set_cursor(0, { row, col + 1 })
      end
      -- If current mode is 'visual', make link from selection
    elseif mode == 'v' or range then
      -- Get the start of the visual selection (the end is the cursor position)
      local vis = vim.fn.getpos('v')
      -- If the start of the visual selection is after the cursor position,
      -- use the cursor position as start and the visual position as finish
      local inverted = range and false or vis[3] > col
      local start, finish
      if range then
        start = vim.api.nvim_buf_get_mark(0, '<')
        finish = vim.api.nvim_buf_get_mark(0, '>')
        -- Update char offsets
        start[1] = start[1] - 1
        finish[1] = finish[1] - 1
      else
        start = (inverted and { row - 1, col }) or { vis[2] - 1, vis[3] - 1 + vis[4] }
        finish = (inverted and { vis[2] - 1, vis[3] - 1 + vis[4] }) or { row - 1, col }
      end
      local start_row = (inverted and row - 1) or vis[2] - 1
      local start_col = (inverted and col) or vis[3] - 1
      local end_row = (inverted and vis[2] - 1) or row - 1
      -- If inverted, use the col value from the visual selection; otherwise, use the col value
      -- from start.
      local end_col = (inverted and vis[3]) or finish[2] + 1
      -- Make sure the selection is on a single line; otherwise, do nothing & throw a warning
      if start_row == end_row then
        local lines = vim.api.nvim_buf_get_lines(0, start[1], finish[1] + 1, false)

        -- Check if last byte is part of a multibyte character & adjust end index if so
        local is_multibyte_char =
            utils.isMultibyteChar({ buffer = 0, row = finish[1], start_col = end_col })
        if is_multibyte_char then
          end_col = is_multibyte_char['finish']
        end

        -- Reduce the text only to the visual selection
        lines[1] = lines[1]:sub(start_col + 1, end_col)

        -- If start and end are on different rows, reduce the text on the last line to the visual
        -- selection as well
        if start[1] ~= finish[1] then
          lines[#lines] = lines[#lines]:sub(start_col + 1, end_col)
        end
        -- Save the text selection & format as a link
        local text = table.concat(lines)
        local replacement = from_clipboard and M.formatLink(text, vim.fn.getreg('+'))
            or M.formatLink(text)
        -- If no replacement, end here
        if not replacement then
          return
        end
        -- Replace the visual selection w/ the formatted link replacement
        vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, replacement)
        -- Leave visual mode
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes('<esc>', true, false, true),
          'x',
          true
        )
        -- Retain original cursor position
        vim.api.nvim_win_set_cursor(0, { row, col + 1 })
      else
        vim.api.nvim_echo(
          {
            {
              '⬇️  Creating links from multi-line visual selection not supported',
              'WarningMsg',
            },
          },
          true,
          {}
        )
      end
    end
  end,

  --[[
destroyLink() replaces any link the cursor is currently overlapping with just
the name part of the link.
--]]
  destroyLink = function()
    -- Get link name, indices, and row the cursor is currently on
    local link = M.getLinkUnderCursor()
    if link then
      local link_name = M.getLinkPart(link, 'name')
      -- Replace the link with just the name
      vim.api.nvim_buf_set_text(0, link[4] - 1, link[5] - 1, link[6] - 1, link[7], { link_name })
    else
      vim.api.nvim_echo(
        { { "⬇️  Couldn't find a link under the cursor to destroy!", 'WarningMsg' } },
        true,
        {}
      )
    end
  end,

  --[[
followLink() passes a path and anchor (passed in or picked up from a link under
the cursor) to handlePath from the paths module. If no path or anchor are passed
in and there is no link under the cursor, createLink() is called to create a
link from the word under the cursor or a visual selection (if there is one).
--]]
  followLink = function(args)
    args = args or {}
    local path = args.path
    local anchor = args.anchor
    local range = args.range or false
    local link_type
    if path or anchor then
      path, anchor = path, anchor
    else
      path, anchor, link_type = M.getLinkPart(M.getLinkUnderCursor(), 'source')
    end
    if path then
      require('mkdnflow').paths.handlePath(path, anchor)
    elseif link_type == 'ref_style_link' then -- If this condition is met, no reference was found
      vim.api.nvim_echo(
        { { "⬇️  Couldn't find a matching reference label!", 'WarningMsg' } },
        true,
        {}
      )
    elseif M.config.public.links.create_on_follow_fail then
      M.createLink({ range = range })
    end
  end,
  transformPath = function(text)
    if type(M.config.public.links.transform_explicit) ~= 'function' or not M.config.public.links.transform_explicit then
      return text
    else
      return (M.config.public.links.transform_explicit(text))
    end
  end,
  get_ref = function(refnr, start_row)
    start_row = start_row or vim.api.nvim_win_get_cursor(0)[1]
    local row = start_row + 1
    local line_count, continue = vim.api.nvim_buf_line_count(0), true
    -- Look for reference
    while continue and row <= line_count do
      local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
      local start, finish, match = string.find(line, '^(%[' .. refnr .. '%]: .*)')
      if match then
        local _, label_finish = string.find(match, '^%[.-%]: ')
        continue = false
        return string.sub(match, label_finish + 1), row, label_finish + 1, finish
      else
        row = row + 1
      end
    end
  end
}

M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      preview = {
        name = "link",
        subcommands = {
          update = {
            args = 0,
            name = "link.new"
          },
          insert = {
            name = "link.backlinks",
            args = 0,
          },
        },
      }
    })
  end)
end
M.events.subscribed = {
  cmd = {
    ["link.new"] = true,
    ["link.backlinks"] = true,
  },
}

return M
