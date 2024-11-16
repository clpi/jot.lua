M = {}

local d = require "dorm"
local log, utils = d.log, d.utils

M.in_range = function(k, l, r_ex)
  return l <= k and k < r_ex
end

M.is_concealing_on_row_range = function(mode, conceallevel, concealcursor, current_row_0b, row_start_0b, row_end_0bex)
  if conceallevel < 1 then
    return false
  elseif not M.in_range(current_row_0b, row_start_0b, row_end_0bex) then
    return true
  else
    return (concealcursor:find(mode) ~= nil)
  end
end

M.table_extend_in_place = function(tbl, tbl_ext)
  for k, v in pairs(tbl_ext) do
    tbl[k] = v
  end
end

M.get_node_position_and_text_length = function(bufid, node)
  local row_start_0b, col_start_0b = node:range()

  -- FIXME parser: multi_definition_suffix, weak_paragraph_delimiter should not span across lines
  -- assert(row_start_0b == row_end_0bin, row_start_0b .. "," .. row_end_0bin)
  local text = vim.treesitter.get_node_text(node, bufid)
  local past_end_offset_1b = text:find("%s") or text:len() + 1
  return row_start_0b, col_start_0b, (past_end_offset_1b - 1)
end

M.get_header_prefix_node = function(header_node)
  local first_child = header_node:child(0)
  assert(first_child:type() == header_node:type() .. "_prefix")
  return first_child
end

M.get_line_length = function(bufid, row_0b)
  return vim.api.nvim_strwidth(vim.api.nvim_buf_get_lines(bufid, row_0b, row_0b + 1, true)[1])
end
M.roman_numerals = {
  { "i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix" },
  { "x", "xx", "xxx", "xl", "l", "lx", "lxx", "lxxx", "xc" },
  { "c", "cc", "ccc", "cd", "d", "dc", "dcc", "dccc", "cm" },
  { "m", "mm", "mmm" },
}
M.set_mark = function(bufid, row_0b, col_0b, text, highlight, ext_opts)
  local ns_icon = M.private.ns_icon
  local opt = {
    virt_text = { { text, highlight } },
    virt_text_pos = "overlay",
    virt_text_win_col = nil,
    hl_group = nil,
    conceal = nil,
    id = nil,
    end_row = row_0b,
    end_col = col_0b,
    hl_eol = nil,
    virt_text_hide = nil,
    hl_mode = "combine",
    virt_lines = nil,
    virt_lines_above = nil,
    virt_lines_leftcol = nil,
    ephemeral = nil,
    right_gravity = nil,
    end_right_gravity = nil,
    priority = nil,
    strict = nil, -- base true
    sign_text = nil,
    sign_hl_group = nil,
    number_hl_group = nil,
    line_hl_group = nil,
    cursorline_hl_group = nil,
    spell = nil,
    ui_watched = nil,
    invalidate = true,
  }

  if ext_opts then
    M.table_extend_in_place(opt, ext_opts)
  end

  vim.api.nvim_buf_set_extmark(bufid, ns_icon, row_0b, col_0b, opt)
end

M.table_get_base_last = function(tbl, index)
  return tbl[index] or tbl[#tbl]
end

M.get_ordered_index = function(bufid, prefix_node)
  -- TODO: calculate levels in one pass, since treesitter API implementation seems to have ridiculously high complexity
  local _, _, level = M.get_node_position_and_text_length(bufid, prefix_node)
  local header_node = prefix_node:parent()
  -- TODO: fix parser: `(ERROR)` on standalone prefix not followed by text, like `- `
  -- assert(header_node:type() .. "_prefix" == prefix_node:type())
  local sibling = header_node:prev_named_sibling()
  local count = 1

  while sibling and (sibling:type() == header_node:type()) do
    local _, _, sibling_level = M.get_node_position_and_text_length(bufid, M.get_header_prefix_node(sibling))
    if sibling_level < level then
      break
    elseif sibling_level == level then
      count = count + 1
    end
    sibling = sibling:prev_named_sibling()
  end

  return count, (sibling or header_node:parent())
end

M.tbl_reverse = function(tbl)
  local result = {}
  for i = 1, #tbl do
    result[i] = tbl[#tbl - i + 1]
  end
  return result
end

M.tostring_lowercase = function(n)
  local t = {}
  while n > 0 do
    t[#t + 1] = string.char(0x61 + (n - 1) % 26)
    n = math.floor((n - 1) / 26)
  end
  return table.concat(t):reverse()
end

M.tostring_roman_lowercase = function(n)
  if n >= 4000 then
    -- too large to render
    return
  end

  local result = {}
  local i = 1
  while n > 0 do
    result[#result + 1] = u.roman_numerals[i][n % 10]
    n = math.floor(n / 10)
    i = i + 1
  end
  return table.concat(M.tbl_reverse(result))
end

M.ordered_icon_table = {
  ["0"] = function(i)
    return tostring(i - 1)
  end,
  ["1"] = function(i)
    return tostring(i)
  end,
  ["a"] = function(i)
    return M.tostring_lowercase(i)
  end,
  ["A"] = function(i)
    return M.tostring_lowercase(i):upper()
  end,
  ["i"] = function(i)
    return M.tostring_roman_lowercase(i)
  end,
  ["I"] = function(i)
    return M.tostring_roman_lowercase(i):upper()
  end,
  ["Ⅰ"] = {
    "Ⅰ",
    "Ⅱ",
    "Ⅲ",
    "Ⅳ",
    "Ⅴ",
    "Ⅵ",
    "Ⅶ",
    "Ⅷ",
    "Ⅸ",
    "Ⅹ",
    "Ⅺ",
    "Ⅻ",
  },
  ["ⅰ"] = {
    "ⅰ",
    "ⅱ",
    "ⅲ",
    "ⅳ",
    "ⅴ",
    "ⅵ",
    "ⅶ",
    "ⅷ",
    "ⅸ",
    "ⅹ",
    "ⅺ",
    "ⅻ",
  },
  ["⒈"] = {
    "⒈",
    "⒉",
    "⒊",
    "⒋",
    "⒌",
    "⒍",
    "⒎",
    "⒏",
    "⒐",
    "⒑",
    "⒒",
    "⒓",
    "⒔",
    "⒕",
    "⒖",
    "⒗",
    "⒘",
    "⒙",
    "⒚",
    "⒛",
  },
  ["⑴"] = {
    "⑴",
    "⑵",
    "⑶",
    "⑷",
    "⑸",
    "⑹",
    "⑺",
    "⑻",
    "⑼",
    "⑽",
    "⑾",
    "⑿",
    "⒀",
    "⒁",
    "⒂",
    "⒃",
    "⒄",
    "⒅",
    "⒆",
    "⒇",
  },
  ["①"] = {
    "①",
    "②",
    "③",
    "④",
    "⑤",
    "⑥",
    "⑦",
    "⑧",
    "⑨",
    "⑩",
    "⑪",
    "⑫",
    "⑬",
    "⑭",
    "⑮",
    "⑯",
    "⑰",
    "⑱",
    "⑲",
    "⑳",
  },
  ["⒜"] = {
    "⒜",
    "⒝",
    "⒞",
    "⒟",
    "⒠",
    "⒡",
    "⒢",
    "⒣",
    "⒤",
    "⒥",
    "⒦",
    "⒧",
    "⒨",
    "⒩",
    "⒪",
    "⒫",
    "⒬",
    "⒭",
    "⒮",
    "⒯",
    "⒰",
    "⒱",
    "⒲",
    "⒳",
    "⒴",
    "⒵",
  },
  ["Ⓐ"] = {
    "Ⓐ",
    "Ⓑ",
    "Ⓒ",
    "Ⓓ",
    "Ⓔ",
    "Ⓕ",
    "Ⓖ",
    "Ⓗ",
    "Ⓘ",
    "Ⓙ",
    "Ⓚ",
    "Ⓛ",
    "Ⓜ",
    "Ⓝ",
    "Ⓞ",
    "Ⓟ",
    "Ⓠ",
    "Ⓡ",
    "Ⓢ",
    "Ⓣ",
    "Ⓤ",
    "Ⓥ",
    "Ⓦ",
    "Ⓧ",
    "Ⓨ",
    "Ⓩ",
  },
  ["ⓐ"] = {
    "ⓐ",
    "ⓑ",
    "ⓒ",
    "ⓓ",
    "ⓔ",
    "ⓕ",
    "ⓖ",
    "ⓗ",
    "ⓘ",
    "ⓙ",
    "ⓚ",
    "ⓛ",
    "ⓜ",
    "ⓝ",
    "ⓞ",
    "ⓟ",
    "ⓠ",
    "ⓡ",
    "ⓢ",
    "ⓣ",
    "ⓤ",
    "ⓥ",
    "ⓦ",
    "ⓧ",
    "ⓨ",
    "ⓩ",
  },
}

M.memoized_ordered_icon_generator = {}

M.format_ordered_icon = function(pattern, index)
  if type(pattern) == "function" then
    return pattern(index)
  end

  local gen = M.memoized_ordered_icon_generator[pattern]
  if gen then
    return gen(index)
  end

  for char_one, number_table in pairs(M.ordered_icon_table) do
    local l, r = pattern:find(char_one:find("%w") and "%f[%w]" .. char_one .. "%f[%W]" or char_one)
    if l then
      gen = function(index_)
        local icon = type(number_table) == "function" and number_table(index_) or number_table[index_]
        return icon and pattern:sub(1, l - 1) .. icon .. pattern:sub(r + 1)
      end
      break
    end
  end

  gen = gen or function(_) end

  M.memoized_ordered_icon_generator[pattern] = gen
  return gen(index)
end

M.superscript_digits = {
  ["0"] = "⁰",
  ["1"] = "¹",
  ["2"] = "²",
  ["3"] = "³",
  ["4"] = "⁴",
  ["5"] = "⁵",
  ["6"] = "⁶",
  ["7"] = "⁷",
  ["8"] = "⁸",
  ["9"] = "⁹",
  ["-"] = "⁻",
}

M.pos_eq = function(pos1, pos2)
  return (pos1.x == pos2.x) and (pos1.y == pos2.y)
end

M.pos_le = function(pos1, pos2)
  return pos1.x < pos2.x or (pos1.x == pos2.x and pos1.y <= pos2.y)
end

-- M.pos_lt(pos1, pos2)
--     return pos1.x < pos2.x or (pos1.x == pos2.x and pos1.y < pos2.y)
-- end

M.remove_extmarks = function(bufid, pos_start_0b_0b, pos_end_0bin_0bex)
  assert(M.pos_le(pos_start_0b_0b, pos_end_0bin_0bex))
  if M.pos_eq(pos_start_0b_0b, pos_end_0bin_0bex) then
    return
  end

  local ns_icon = M.private.ns_icon
  for _, result in
  ipairs(
    vim.api.nvim_buf_get_extmarks(
      bufid,
      ns_icon,
      { pos_start_0b_0b.x, pos_start_0b_0b.y },
      { pos_end_0bin_0bex.x - ((pos_end_0bin_0bex.y == 0) and 1 or 0), pos_end_0bin_0bex.y - 1 },
      {}
    )
  )
  do
    local extmark_id = result[1]
    -- TODO: Optimize
    -- local node_pos_0b_0b = { x = result[2], y = result[3] }
    -- assert(
    --     pos_le(pos_start_0b_0b, node_pos_0b_0b) and pos_le(node_pos_0b_0b, pos_end_0bin_0bex),
    --     ("start=%s, end=%s, node=%s"):format(
    --         vim.inspect(pos_start_0b_0b),
    --         vim.inspect(pos_end_0bin_0bex),
    --         vim.inspect(node_pos_0b_0b)
    --     )
    -- )
    vim.api.nvim_buf_del_extmark(bufid, ns_icon, extmark_id)
  end
end

M.is_inside_example = function(_)
  -- TODO: waiting for parser fix
  return false
end

M.should_skip_prettify = function(mode, current_row_0b, node, config, row_start_0b, row_end_0bex)
  local result
  if config.insert_enabled then
    result = false
  elseif (mode == "i") and M.in_range(current_row_0b, row_start_0b, row_end_0bex) then
    result = true
  elseif M.is_inside_example(node) then
    result = true
  else
    result = false
  end
  return result
end

M.query_get_nodes = function(query, document_root, bufid, row_start_0b, row_end_0bex)
  local result = {}
  local concealed_node_ids = {}
  for id, node in query:iter_captures(document_root, bufid, row_start_0b, row_end_0bex) do
    if node:missing() then
      goto continue
    end
    if query.captures[id] == "icon-concealed" then
      concealed_node_ids[node:id()] = true
    end
    table.insert(result, node)
    ::continue::
  end
  return result, concealed_node_ids
end

M.check_min = function(xy, x_new, y_new)
  if (x_new < xy.x) or (x_new == xy.x and y_new < xy.y) then
    xy.x = x_new
    xy.y = y_new
  end
end

M.check_max = function(xy, x_new, y_new)
  if (x_new > xy.x) or (x_new == xy.x and y_new > xy.y) then
    xy.x = x_new
    xy.y = y_new
  end
end

M.add_prettify_flag_line = function(bufid, row)
  local ns_prettify_flag = M.private.ns_prettify_flag
  vim.api.nvim_buf_set_extmark(bufid, ns_prettify_flag, row, 0, {})
end

M.add_prettify_flag_range = function(bufid, row_start_0b, row_end_0bex)
  for row = row_start_0b, row_end_0bex - 1 do
    M.add_prettify_flag_line(bufid, row)
  end
end

M.remove_prettify_flag_on_line = function(bufid, row_0b)
  -- TODO: optimize
  local ns_prettify_flag = M.private.ns_prettify_flag
  vim.api.nvim_buf_clear_namespace(bufid, ns_prettify_flag, row_0b, row_0b + 1)
end

M.remove_prettify_flag_range = function(bufid, row_start_0b, row_end_0bex)
  -- TODO: optimize
  local ns_prettify_flag = M.private.ns_prettify_flag
  vim.api.nvim_buf_clear_namespace(bufid, ns_prettify_flag, row_start_0b, row_end_0bex)
end

M.remove_prettify_flag_all = function(bufid)
  M.remove_prettify_flag_range(bufid, 0, -1)
end

M.get_visible_line_range = function(winid)
  local row_start_1b = vim.fn.line("w0", winid)
  local row_end_1b = vim.fn.line("w$", winid)
  return (row_start_1b - 1), row_end_1b
end

M.get_parsed_query_lazy = function()
  if M.private.prettify_query then
    return M.private.prettify_query
  end

  local keys = { "config", "icons" }
  M.traverse_config = function(config, f)
    if config == false then
      return
    end
    if config.nodes then
      f(config)
      return
    end
    if type(config) ~= "table" then
      log.warn(("unsupported icon config: %s = %s"):format(table.concat(keys, "."), config))
      return
    end
    local key_pos = #keys + 1
    for key, sub_config in pairs(config) do
      keys[key_pos] = key
      M.traverse_config(sub_config, f)
      keys[key_pos] = nil
    end
  end

  local config_by_node_name = {}
  local queries = { "[" }

  M.traverse_config(M.config.public.icons, function(config)
    for _, node_type in ipairs(config.nodes) do
      table.insert(queries, ("(%s)@icon"):format(node_type))
      config_by_node_name[node_type] = config
    end
    for _, node_type in ipairs(config.nodes.concealed or {}) do
      table.insert(queries, ("(%s)@icon-concealed"):format(node_type))
      config_by_node_name[node_type] = config
    end
  end)

  table.insert(queries, "]")
  local query_combined = table.concat(queries, " ")
  M.private.prettify_query = utils.ts_parse_query("dorm", query_combined)
  assert(M.private.prettify_query)
  M.private.config_by_node_name = config_by_node_name
  return M.private.prettify_query
end

M.prettify_range = function(bufid, row_start_0b, row_end_0bex)
  -- in case there's undo/removal garbage
  -- TODO: optimize
  row_end_0bex = math.min(row_end_0bex + 1, vim.api.nvim_buf_line_count(bufid))

  local treesitter_M = M.required["treesitter"]
  local document_root = treesitter_M.get_document_root(bufid)
  assert(document_root)

  local nodes, concealed_node_ids =
      M.query_get_nodes(M.get_parsed_query_lazy(), document_root, bufid, row_start_0b, row_end_0bex)

  local winid = vim.fn.bufwinid(bufid)
  assert(winid > 0)
  local current_row_0b = vim.api.nvim_win_get_cursor(winid)[1] - 1
  local current_mode = vim.api.nvim_get_mode().mode
  local conceallevel = vim.wo[winid].conceallevel
  local concealcursor = vim.wo[winid].concealcursor

  assert(document_root)

  for _, node in ipairs(nodes) do
    local node_row_start_0b, node_col_start_0b, node_row_end_0bin, node_col_end_0bex = node:range()
    local node_row_end_0bex = node_row_end_0bin + 1
    local config = M.private.config_by_node_name[node:type()]

    if config.clear then
      config:clear(bufid, node)
    else
      local pos_start_0b_0b, pos_end_0bin_0bex =
          { x = node_row_start_0b, y = node_col_start_0b }, { x = node_row_end_0bin, y = node_col_end_0bex }

      M.check_min(pos_start_0b_0b, node:start())
      M.check_max(pos_end_0bin_0bex, node:end_())

      M.remove_extmarks(bufid, pos_start_0b_0b, pos_end_0bin_0bex)
    end

    M.remove_prettify_flag_range(bufid, node_row_start_0b, node_row_end_0bex)
    M.add_prettify_flag_range(bufid, node_row_start_0b, node_row_end_0bex)

    if M.should_skip_prettify(current_mode, current_row_0b, node, config, node_row_start_0b, node_row_end_0bex) then
      goto continue
    end

    local has_conceal = (
      concealed_node_ids[node:id()]
      and (not config.check_conceal or config.check_conceal(node))
      and M.is_concealing_on_row_range(
        current_mode,
        conceallevel,
        concealcursor,
        current_row_0b,
        node_row_start_0b,
        node_row_end_0bex
      )
    )

    if has_conceal then
      if config.render_concealed then
        config:render_concealed(bufid, node)
      end
    else
      config:render(bufid, node)
    end

    ::continue::
  end
end

M.render_window_buffer = function(bufid)
  local ns_prettify_flag = M.private.ns_prettify_flag
  local winid = vim.fn.bufwinid(bufid)
  local row_start_0b, row_end_0bex = M.get_visible_line_range(winid)
  local prettify_flags_0b = vim.api.nvim_buf_get_extmarks(
    bufid,
    ns_prettify_flag,
    { row_start_0b, 0 },
    { row_end_0bex - 1, -1 },
    {}
  )
  local row_nomark_start_0b, row_nomark_end_0bin
  local i_flag = 1
  for i = row_start_0b, row_end_0bex - 1 do
    while i_flag <= #prettify_flags_0b and i > prettify_flags_0b[i_flag][2] do
      i_flag = i_flag + 1
    end

    if i_flag <= #prettify_flags_0b and i == prettify_flags_0b[i_flag][2] then
      i_flag = i_flag + 1
    else
      assert(i < (prettify_flags_0b[i_flag] and prettify_flags_0b[i_flag][2] or row_end_0bex))
      row_nomark_start_0b = row_nomark_start_0b or i
      row_nomark_end_0bin = i
    end
  end

  assert((row_nomark_start_0b == nil) == (row_nomark_end_0bin == nil))
  if row_nomark_start_0b then
    M.prettify_range(bufid, row_nomark_start_0b, row_nomark_end_0bin + 1)
  end
end

M.render_all_scheduled_and_done = function()
  for bufid, _ in pairs(M.private.rerendering_scheduled_bufids) do
    if vim.fn.bufwinid(bufid) >= 0 then
      M.render_window_buffer(bufid)
    end
  end
  M.private.rerendering_scheduled_bufids = {}
end

M.schedule_rendering = function(bufid)
  local not_scheduled = vim.tbl_isempty(M.private.rerendering_scheduled_bufids)
  M.private.rerendering_scheduled_bufids[bufid] = true
  if not_scheduled then
    vim.schedule(M.render_all_scheduled_and_done)
  end
end

M.mark_line_changed = function(bufid, row_0b)
  M.remove_prettify_flag_on_line(bufid, row_0b)
  M.schedule_rendering(bufid)
end

M.mark_line_range_changed = function(bufid, row_start_0b, row_end_0bex)
  M.remove_prettify_flag_range(bufid, row_start_0b, row_end_0bex)
  M.schedule_rendering(bufid)
end

M.mark_all_lines_changed = function(bufid)
  if not M.private.enabled then
    return
  end

  M.remove_prettify_flag_all(bufid)
  M.schedule_rendering(bufid)
end

M.clear_all_extmarks = function(bufid)
  local ns_icon = M.private.ns_icon
  local ns_prettify_flag = M.private.ns_prettify_flag
  vim.api.nvim_buf_clear_namespace(bufid, ns_icon, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufid, ns_prettify_flag, 0, -1)
end

M.get_table_base_empty = function(tbl, key)
  if not tbl[key] then
    tbl[key] = {}
  end
  return tbl[key]
end

M.update_cursor = function(event)
  local cursor_record = M.get_table_base_empty(M.private.cursor_record, event.buffer)
  cursor_record.row_0b = event.cursor_position[1] - 1
  cursor_record.col_0b = event.cursor_position[2]
  cursor_record.line_content = event.line_content
end

M.handle_init_event = function(event)
  assert(vim.api.nvim_win_is_valid(event.window))
  M.update_cursor(event)

  M.on_line_callback(
    tag,
    bufid,
    _changedtick, ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
    row_start_0b,
    _row_end_0bex, ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
    row_updated_0bex,
    _n_byte_prev ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
  )
  assert(tag == "lines")

  if not M.private.enabled then
    return
  end

  M.mark_line_range_changed(bufid, row_start_0b, row_updated_0bex)
end

local attach_succeeded = vim.api.nvim_buf_attach(event.buffer, true, { on_lines = M.on_line_callback })
assert(attach_succeeded)
local language_tree = vim.treesitter.get_parser(event.buffer, "markdown")

local bufid = event.buffer
-- used for detecting non-local (multiline) changes, like spoiler / code block
-- TODO: exemption in certain cases, for example when changing only heading followed by pure texts,
-- in which case all its descendents would be unnecessarily re-concealed.
M.on_changedtree_callback = function(ranges)
  -- TODO: abandon if too large
  for i = 1, #ranges do
    local range = ranges[i]
    local row_start_0b = range[1]
    local row_end_0bex = range[3] + 1
    M.remove_prettify_flag_range(bufid, row_start_0b, row_end_0bex)
  end
end

language_tree:register_cbs({ on_changedtree = M.on_changedtree_callback })
mark_all_lines_changed(event.buffer)

if
    M.config.public.folds
    and vim.api.nvim_win_is_valid(event.window)
    and vim.api.nvim_buf_is_valid(event.buffer)
then
  vim.api.nvim_buf_call(event.buffer, function()
    -- NOTE(vhyrro): `vim.wo` only supports `wo[winid][0]`,
    -- hence the `buf_call` here.
    local wo = vim.wo[event.window][0]
    wo.foldmethod = "expr"
    wo.foldexpr = vim.treesitter.foldexpr and "v:lua.vim.treesitter.foldexpr()" or "nvim_treesitter#foldexpr()"
    wo.foldtext = ""

    local init_open_folds = M.config.public.init_open_folds
    M.open_folds = function()
      vim.cmd("normal! zR")
    end

    if init_open_folds == "always" then
      M.open_folds()
    elseif init_open_folds == "never" then   -- luacheck:ignore 542
      -- do nothing
    else
      if init_open_folds ~= "auto" then
        log.warn('"init_open_folds" must be "auto", "always", or "never"')
      end

      if wo.foldlevel == 0 then
        M.open_folds()
      end
    end
  end)
end

M.handle_insert_toggle = function(event)
  M.mark_line_changed(event.buffer, event.cursor_position[1] - 1)
end

M.handle_insertenter = function(event)
  M.handle_insert_toggle(event)
end

M.handle_insertleave = function(event)
  M.handle_insert_toggle(event)
end

M.handle_toggle_prettifier = function(event)
  -- FIXME: M.private.enabled should be a map from bufid to boolean
  M.private.enabled = not M.private.enabled
  if M.private.enabled then
    M.mark_all_lines_changed(event.buffer)
  else
    M.private.rerendering_scheduled_bufids[event.buffer] = nil
    M.clear_all_extmarks(event.buffer)
  end
end

M.is_same_line_movement = function(event)
  -- some operations like dd / u cannot yet be listened reliably
  -- below is our best approximation
  local cursor_record = M.private.cursor_record
  return (
    cursor_record
    and cursor_record.row_0b == event.cursor_position[1] - 1
    and cursor_record.col_0b ~= event.cursor_position[2]
    and cursor_record.line_content == event.line_content
  )
end

M.handle_cursor_moved = function(event)
  -- reveal/conceal when conceallevel>0
  -- also triggered when dd / u
  if not M.is_same_line_movement(event) then
    local cursor_record = M.private.cursor_record[event.buffer]
    if cursor_record then
      -- leaving previous line, conceal it if necessary
      M.mark_line_changed(event.buffer, cursor_record.row_0b)
    end
    -- entering current line, conceal it if necessary
    local current_row_0b = event.cursor_position[1] - 1
    M.mark_line_changed(event.buffer, current_row_0b)
  end
  M.update_cursor(event)
end

M.handle_cursor_moved_i = function(event)
  return M.handle_cursor_moved(event)
end

M.handle_winscrolled = function(event)
  M.schedule_rendering(event.buffer)
end

M.handle_filetype = function(event)
  M.handle_init_event(event)
end

local event_handlers = {
  ["cmd.events.base.icon.toggle"] = M.handle_toggle_prettifier,
  -- ["autocmd.events.bufnewfile"] = M.handle_init_event,
  ["autocmd.events.filetype"] = M.handle_filetype,
  ["autocmd.events.bufreadpost"] = M.handle_init_event,
  ["autocmd.events.insertenter"] = M.handle_insertenter,
  ["autocmd.events.insertleave"] = M.handle_insertleave,
  ["autocmd.events.cursormoved"] = M.handle_cursor_moved,
  ["autocmd.events.cursormovedi"] = M.handle_cursor_moved_i,
  ["autocmd.events.winscrolled"] = M.handle_winscrolled,
}

M.on_event = function(event)
  if event.referrer == "autocmd" and vim.bo[event.buffer].ft ~= "dorm" then
    return
  end

  if (not M.private.enabled) and (event.type ~= "cmd.events.base.icon.toggle") then
    return
  end
  return event_handlers[event.type](event)
end

M.load = function()
  local preset =
      M.imported[M.name .. "." .. M.config.public.preset].config.private
      ["preset_" .. M.config.public.preset]
  if not preset then
    log.error(
      ("Unable to load icon preset '%s' - such a preset does not exist"):format(M.config.public.preset)
    )
    return
  end
end

return M
