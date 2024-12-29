local down = require('down')
local map = require('down.util.maps')
local mod = require 'down.mod'

---@class down.mod.cmd.Mod: down.Mod
local M = mod.new('cmd.mod')

---@class down.mod.cmd.mod.Data
M.data = {

  -- The table containing all the functions. This can get a tad complex so I recommend you read the wiki entry
}
M.commands = {
  mod = {
    name = 'mod',
    args = 1,
    subcommands = {
      new = {
        args = 1,
        name = 'mod.new',
      },
      load = {
        name = 'mod.load',
        args = 1,
      },
      unload = {
        name = 'mod.unload',
        args = 1,
      },
      list = {
        args = 0,
        name = 'mod.list',
      },
    },
  },
}
M.maps = {
  { 'n', ',dml', '<CMD>Down mod list<CR>', 'List mods' },
  { 'n', ',dmL', '<CMD>Down mod load<CR>', 'Load mod' },
  { 'n', ',dmu', '<CMD>Down mod unload<CR>', 'Unload mod' },
}
M.setup = function()
  return { loaded = true, requires = { 'cmd' } }
end
---@type down.mod.Handler
M.handle = function(event)
  if event.type == 'cmd.events.mod.setup' then
    local ok = pcall(mod.load_mod, event.body[1])

    if not ok then
      vim.notify(
        string.format('init `%s` does not exist!', event.body[1]),
        vim.log.levels.ERROR,
        {}
      )
    end
  end

  if event.type == 'cmd.events.mod.unload' then
  end

  if event.type == 'cmd.events.mod.list' then
    local Popup = require('nui.popup')

    local mods_popup = Popup({
      position = '50%',
      size = { width = '50%', height = '80%' },
      enter = true,
      buf_options = {
        filetype = 'markdown',
        modifiable = true,
        readonly = false,
      },
      win_options = {
        conceallevel = 3,
        concealcursor = 'nvic',
      },
    })

    mods_popup:on('VimResized', function()
      mods_popup:update_layout()
    end)

    local function close()
      mods_popup:unmount()
    end

    mods_popup:map('n', '<Esc>', close, {})
    mods_popup:map('n', 'q', close, {})

    local lines = {}

    for name, _ in pairs(mod.mods) do
      table.insert(lines, '1. `' .. name .. '`')
    end

    vim.api.nvim_buf_set_lines(mods_popup.bufnr, 0, -1, true, lines)

    vim.bo[mods_popup.bufnr].modifiable = false

    mods_popup:mount()
  end
end
---@class down.mod.cmd.mod.Subscribed: down.mod.Subscribed
M.subscribed = {
  cmd = {
    ['mod'] = true,
    ['mod.new'] = true,
    ['mod.setup'] = true,
    ['mod.list'] = true,
    ['mod.load'] = true,
    ['mod.unload'] = true,
  },
}
return M
