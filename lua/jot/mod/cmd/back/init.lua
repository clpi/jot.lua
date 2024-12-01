--[[
    file: cmd-return
    title: Provides the `:jot return` Command
    summary: Return to last location before entering jot.
    internal: true
    ---
When executed (`:jot return`), all currently open `.jot` files are deleted from
the buffer list, and the current workspace is set to "config".
--]]

local jot = require("jot")
local mod = jot.mod

local init = mod.create("cmd.back")

init.setup = function()
  return { success = true, requires = { "cmd" } }
end

init.public = {
  commands = {
    back = {
      args = 0,
      name = "back",
    },
  },
}

init.on_event = function(event)
  if event.type == "cmd.events.back" then
    -- Get all the buffers
    local buffers = vim.api.nvim_list_bufs()

    local to_delete = {}
    for buffer in vim.iter(buffers):rev() do
      if vim.fn.buflisted(buffer) == 1 then
        -- If the listed buffer we're working with has a .jot extension then remove it (not forcibly)
        if not vim.endswith(vim.api.nvim_buf_get_name(buffer), ".md") then
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

init.events.subscribed = {
  cmd = {
    ["back"] = true,
  },
}

return init
