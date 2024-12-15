local U = {}

function U.in_range(k, l, r_ex)
  return l <= k and k < r_ex
end

function U.is_concealing_on_row_range(
  mode,
  conceallevel,
  concealcursor,
  current_row_0b,
  row_start_0b,
  row_end_0bex
)
  if conceallevel < 1 then
    return false
  elseif not U.in_range(current_row_0b, row_start_0b, row_end_0bex) then
    return true
  else
    return (concealcursor:find(mode) ~= nil)
  end
end

function U.table_extend_in_place(tbl, tbl_ext)
  for k, v in pairs(tbl_ext) do
    tbl[k] = v
  end
end

function U.get_node_position_and_text_length(bufid, node)
  local row_start_0b, col_start_0b = node:range()

  -- FIXME parser: multi_definition_suffix, weak_paragraph_delimiter should not span across lines
  -- assert(row_start_0b == row_end_0bin, row_start_0b..","..row_end_0bin)
  local text = vim.treesitter.get_node_text(node, bufid)
  local past_end_offset_1b = text:find("%s") or text:len() + 1
  return row_start_0b, col_start_0b, (past_end_offset_1b - 1)
end

function U.get_header_prefix_node(header_node)
  local first_child = header_node:child(0)
  -- assert(first_child:type() == header_node:type() .. "_prefix")
  return first_child
end

function U.get_line_length(bufid, row_0b)
  return vim.api.nvim_strwidth(
    vim.api.nvim_buf_get_lines(bufid, row_0b, row_0b + 1, true)[1]
  )
end

return U
