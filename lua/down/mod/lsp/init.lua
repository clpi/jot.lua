local mod = require 'down.mod'
local log = require 'down.util.log'
local settings = require('down.mod.lsp.settings')

---@class down.mod.Lsp: down.Mod
local Lsp = mod.new 'lsp'

---@return down.mod.Setup
Lsp.setup = function()
  ---@type down.mod.Setup
  return {
    loaded = true,
    dependencies = {
      'cmd',
      'workspace',
    },
  }
end

Lsp.commands = {
  lsp = {
    name = 'lsp',
    condition = 'markdown',
    callback = function(e)
      log.trace 'lsp'
    end,
    subcommands = {
      restart = {
        args = 0,
        name = 'lsp.restart',
        condition = 'markdown',
        callback = function(e)
          log.trace 'lsp.restart'
        end,
      },
      start = {
        args = 0,
        name = 'lsp.start',
        condition = 'markdown',
        callback = function(e)
          log.trace 'lsp.start'
        end,
      },
      status = {
        args = 0,
        name = 'lsp.status',
        condition = 'markdown',
        callback = function(e)
          log.trace 'lsp.status'
        end,
      },
      stop = {
        args = 0,
        name = 'lsp.stop',
        condition = 'markdown',
        callback = function(e)
          log.trace 'lsp.stop'
        end,
      },
    },
  },
  actions = {
    args = 1,
    name = 'actions',
    condition = 'markdown',
    callback = function(e)
      log.trace 'actions'
    end,
    subcommands = {
      workspace = {
        args = 1,
        name = 'actions.workspace',
        condition = 'markdown',
        callback = function(e)
          log.trace 'actions.workspce'
        end,
      },
    },
  },
  rename = {
    args = 1,
    max_args = 1,
    name = 'rename',
    condition = 'markdown',
    subcommands = {
      workspace = {
        args = 0,
        name = 'rename.workspace',
        condition = 'markdown',
        callback = function(e)
          log.trace 'rename.workspace'
        end,
      },
      dir = {
        args = 0,
        name = 'rename.dir',
        condition = 'markdown',
        callback = function(e)
          log.trace 'rename.dir'
        end,
      },
      section = {
        args = 0,
        name = 'rename.section',
        condition = 'markdown',
        callback = function(e)
          log.trace 'rename.section'
        end,
      },
      file = {
        args = 0,
        name = 'rename.file',
        condition = 'markdown',
        callback = function(e)
          log.trace 'rename.file'
        end,
      },
    },
  },
}

Lsp.load = function()
  local autocmd = Lsp.data.ft 'markdown'
end

---@class (exact) down.mod.lsp.Config
Lsp.data = {}

---@class down.mod.lsp.Config
Lsp.config = {
  name = 'downls',
  cmd = { 'down', 'lsp', '--stdio' },
  root_dir = vim.fn.getcwd(),
  settings = settings,
}

function Lsp.data.run()
  local ft = vim.bo.filetype
  local ext = vim.fn.expand '%:e'
  if ext == 'md' or ext == 'dn' or ext == 'dd' or ext == 'down' or ext == 'downrc' then
    vim.lsp.start(Lsp.config)
  end
end

function Lsp.data.augroup()
  return vim.api.nvim_create_augroup('down.lsp', {
    clear = true,
  })
end

function Lsp.data.serve()
  vim.lsp.start {
    name = 'downls',
    cmd = { 'down', 'lsp' },
    root_dir = vim.fn.getcwd(),
    settings = Lsp.config.settings,
  }
end

Lsp.data.autocmd = function(ft)
  return vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
    pattern = ft or '*',
    callback = Lsp.data.serve,
    desc = 'Run downls',
  })
end

Lsp.data.ft = function(ft)
  return vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = ft or '*',
    callback = Lsp.data.serve,
    desc = 'Run downls',
  })
end

-- ---@param e down.Event
-- Lsp.handle = {
--   cmd = {
--     ['rename'] = function(e) end,
--     ['action'] = function(e) end,
--     ['lsp'] = function(e) end,
--   },
-- }

return Lsp
