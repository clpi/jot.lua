local utilok, util = pcall(require, "trouble.util")

out = {}


return function(win, buf, cb, options)
  out = {}

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)

  for row, line in ipairs(lines) do
    local match = line:match("^%s*%*+%s+")
    if match then
      local row = row - 1
      local col = match:len()
      local pitem = {
        row = row,
        col = col,
        message = line,
        severity = 0,
        range = {
          start = { line = row, character = col },
          ["end"] = { line = row, character = -1 },
        },
      }
      table.insert(out, util.process_item(pitem, buf))
    end
  end
  cb(out)
end
