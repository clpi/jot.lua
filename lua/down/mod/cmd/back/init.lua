local down = require('down')
local mod = down.mod

local M = mod.create('cmd.back')

M.setup = function()
  return { loaded = true, requires = {} }
end

---@class down.cmd.back.Data
M.data = {
  commands = {
    back = {
      args = 0,
      name = 'back',
    },
  },
}

M.on = function(event)
  if event.type == 'cmd.events.back' then
    -- Get all the buffers
    local buffers = vim.api.nvim_list_bufs()

    local to_delete = {}
    for buffer in vim.iter(buffers):rev() do
      if vim.fn.buflisted(buffer) == 1 then
        -- If the listed buffer we're working with has a .down extension then remove it (not forcibly)
        if not vim.endswith(vim.api.nvim_buf_get_name(buffer), '.md') then
          vim.api.nvim_win_set_buf(0, buffer)
          break
        else
          table.insert(to_delete, buffer)
        end
      end
    end

    for _, buffer in ipairs(to_delete) do
      vim.api.nvim_buf_delete(buffer, {})
    end
  end
end

M.subscribed = {
  cmd = {
    ['back'] = true,
  },
}

return M
