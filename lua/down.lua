---@author clpi
---@file down.lua 0.1.0
---@license MIT
---@package down.lua
---@mle "down"
---@version JIT
---@brief neovim note-taking plugin with the
---@brief comfort of mmarkdown and the power of org

---@class down.Down
local Down = {
  config = require('down.config'),
  mod = require('down.mod'),
  event = require('down.event'),
  util = require('down.util'),
}

--- Load the user configuration, and load into config
--- defined modules specifieed and workspaces
--- @param user down.config.User user config to load
--- @param ... any The arguments to pass into an optional user hook
function Down.setup(user, ...)
  Down.config.setup(user, ...)
  for name, usermod in pairs(Down.config.user) do
    if type(usermod) == 'table' then
      if name == 'workspaces' then
      elseif not Down.mod.load_mod(name, usermod) then
        if Down.config.dev then
          print('error loading ', name)
        end
        Down.mod.delete(name)
      end
    end
  end
  for _, l in pairs(Down.mod.data.mods) do
    l.post_load()
  end
  Down.broadcast('started')
end

---@param e string
function Down.broadcast(e, ...)
  Down.mod.broadcast({ ---@type down.Event
    type = e, ---@diagnostic disable-line
    split = {
      e,
    },

    file = vim.fn.expand('%:p'),
    dir = vim.fn.getcwd(),
    ref = 'Down:broadcast',
    topic = e,
    broadcast = true,
    line = vim.api.nvim_get_current_line(),
    position = vim.api.nvim_win_get_position(0),
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
    mode = vim.fn.mode(),
  })
end

return setmetatable(Down, {
  __call = function(down, user, ...)
    Down.setup(user, ...)
  end,
})
