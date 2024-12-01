local M = Mod.create("ui.win")

M.setup = function()
  return {
    success = true,
    requires = {
      -- 'ui'
    }
  }
end
M.public = {

  sel = function()
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    local win_height = math.ceil(height * 0.8 - 4)
    local win_width = math.ceil(width * 0.8)

    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    local opts = {
      relative = "editor",
      width = win_width,
      height = win_height,
      row = row,
      col = col,
      border = "rounded",
      title = "Hi",
      -- title = "Cancel capture: " k.. keymaps.capture_cancel .. ", Save capture: " .. keymaps.capture_save,
      title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, opts)
    return { buf, win }
  end,
  win = function(bufnr)
    vim.api.nvim_open_win(bufnr, false, {
      relative = "win",
      width = vim.api.nvim_win_get_width(0) - 0,
      height = 100,
      row = 0,
      col = 0,
      focusable = false,
      style = "minimal",
      noautocmd = true,
    })
  end,
  create_new = function()
    local content = [[
  # Hello World

  ![This is a remote image](https://gist.ro/s/remote.png)
  ]]
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, vim.split(content, "\n"))
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "number", false)
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    local win_height = math.ceil(height * 0.8 - 4)
    local win_width = math.ceil(width * 0.8)

    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    local opts = {
      relative = "editor",
      width = win_width,
      height = win_height,
      row = row,
      col = col,
      border = "rounded",
      title = "Hi",
      -- title = "Cancel capture: " k.. keymaps.capture_cancel .. ", Save capture: " .. keymaps.capture_save,
      title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, opts)
    return { buf, win }
  end
}
return M
