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
  Down.config.setup(Down.config, user, Down.default)
  Down.start(Down)
end

function Down:start()
  self.mod.load_mod('workspace', self.config.user.workspace or {})
  for name, usermod in pairs(self.config.user) do
    if type(usermod) == 'table' then
      if name == 'lsp' and self.config.dev == false then
        goto continue
      elseif name == 'workspaces' then
        goto continue
      elseif name == 'workspace' then
        goto continue
      elseif self.mod.load_mod(name, usermod) == nil then
      end
    else
      self.config[name] = usermod
    end
    ::continue::
  end
  self.config.mod = self.mod.mods
  self.config:post_load()
  self:post_load()
  self:broadcast('started')
end

function Down:post_load()
  for _, l in pairs(self.mod.mods) do
    -- l.maps()
    -- l.cmds()
    -- l.opts()
    l.post_load()
  end
end

---@param e string
---@param ... any
function Down:broadcast(e, ...)
  self.mod.broadcast({ ---@type down.Event
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
  -- __call = function(down, user, ...)
  --   Down.setup(user, ...)
  -- end,
  -- __index = function(self, key)
  --   return Down.mod.mods[key]
  -- end,
  -- __newindex = function(self, key, val)
  --   Down.mod.mods[key] = val
  -- end,
})
