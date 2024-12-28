---@author clpi
---@file down.lua 0.1.0
---@license MIT
---@package down.lua
---@brief neovim note-taking plugin with the
---@brief comfort of mmarkdown and the power of org

---@class down.Down
Down = {
  config = require('down.config'),
  mod = require('down.mod'),
  event = require('down.event'),
  util = require('down.util'),
}

Down.default = {
  -- ['data.log'] = {},
  ['lsp'] = {},
  ['data.link'] = {},
  -- ['cmd.back'] = {},
  -- ['data.history'] = {},
  ['tool.telescope'] = {},
}

--- Load the user configuration, and load into config
--- defined modules specifieed and workspaces
--- @param user down.config.User user config to load
--- @param ... any The arguments to pass into an optional user hook
function Down.setup(user, ...)
  if Down.config.started or not user or vim.tbl_isempty(user) then
    return false
  end
  user = Down.util.extend(user, Down.default)
  Down.config.user = Down.util.extend(Down.config.user, user)
  if Down.config.user.hook then
    Down.config.user.hook(...)
  end
  Down.mod.load_mod('workspace', Down.config.user.workspace or {})
  for name, usermod in pairs(Down.config.user) do
    if type(usermod) == 'table' then
      if name == 'lsp' and Down.config.dev == false then
        goto continue
      elseif name == 'workspaces' then
        goto continue
      elseif name == 'workspace' then
        goto continue
      elseif Down.mod.load_mod(name, usermod) == nil then
      end
    else
      Down.config[name] = usermod
    end
    ::continue::
  end
  Down.config.mod = Down.mod.mods
  for _, l in pairs(Down.mod.mods) do
    l.post_load()
  end
  Down.config.post_load()
  Down.broadcast('started')
end

---@param e string
---@param ... any
function Down.broadcast(e, ...)
  Down.mod.broadcast({ ---@type down.Event
    type = e, ---@diagnostic disable-line
    split = {
      e,
    },

    file = vim.fn.expand('%:p'),
    dir = vim.fn.getcwd(),
    topic = e,
    ref = 'Down:broadcast',
    broadcast = true,
    line = vim.api.nvim_get_current_line(),
    position = vim.api.nvim_win_get_position(0),
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
    mode = vim.fn.mode(),
  })
end

--- Test all modules loaded
function Down.test()
  for m, d in pairs(Down.mod.mods) do
    print('Testing mod: ' .. m)
    d.test()
  end
end

return setmetatable(Down, {
  __call = function(down, user, ...)
    Down.setup(user, ...)
  end,
  __index = function(self, key)
    return Down.mod.mods[key]
  end,
  __newindex = function(self, key, val)
    Down.mod.mods[key] = val
  end,
})
