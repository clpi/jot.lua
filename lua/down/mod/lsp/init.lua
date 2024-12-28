local mod = require 'down.mod'
local settings = require('down.mod.lsp.settings')

---@class down.mod.Lsp: down.Mod
local Lsp = require('down.mod').new('lsp', {})

---@return down.mod.Setup
Lsp.setup = function()
  ---@type down.mod.Setup
  return {
    loaded = true,
    requires = {
      'cmd',
      'workspace',
    },
  }
end

Lsp.load = function()
  -- local autocmd = Lsp.data.ft('*.{md,dn,dd}')
  local autocmd = Lsp.data.ft('markdown')
  local autocmd = Lsp.data.ft('docdown')
  local autocmd = Lsp.data.ft('down')
  -- local autocmd = Lsp.data.ft('*.dd')
  -- local autocmd = Lsp.data.ft('*.dn')
  Lsp.required['cmd'].add_commands_from_table({
    actions = {
      args = 1,
      name = 'actions',
      condition = "markdown",
      subcommands = {
        workspace = {
          args = 1,
          name = 'actions.workspace',
        },
      },
    },
    rename = {
      args = 1,
      max_args = 1,
      name = 'rename',
      condition = "markdown",
      subcommands = {
        workspace = {
          args = 0,
          name = 'rename.workspace',
        },
        dir = {
          args = 0,
          name = 'rename.dir',
        },
        file = {
          args = 0,
          name = 'rename.file',
        },
      },
    },
  })
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
  local ext = vim.fn.expand('%:e')
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
  vim.lsp.start({
    name = 'downls',
    cmd = { 'down', 'lsp' },
    root_dir = vim.fn.getcwd(),
    settings = Lsp.config.settings,
  })
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

---@param e down.Event
Lsp.handle = function(e)
  print(e)
  local es = e.split
end

return Lsp
