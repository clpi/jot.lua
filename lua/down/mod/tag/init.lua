local mod = require('down.mod')
local Tag = require('down.mod.data.tag.tag')
local M = require('down.mod').new('tag')

M.commands = {
  tag = {
    name = 'tag',
    condition = 'markdown',
    args = 0,
    max_args = 1,
    callback = function(e)
      log.trace 'tag.commands.tag: cb '
    end,
    subcommands = {
      delete = {
        name = 'data.tag.delete',
        condition = 'markdown',
        args = 0,
        max_args = 1,
        callback = function(e)
          log.trace 'tag.commands.tag.delete: cb '
        end,
      },
      new = {
        args = 0,
        max_args = 1,
        condition = 'markdown',
        callback = function(e)
          log.trace 'tag.commands.tag.new: cb '
        end,
        name = 'data.tag.new',
      },
      list = {
        name = 'data.tag.list',
        args = 0,
        max_args = 1,
        condition = 'markdown',
        callback = function(e)
          log.trace 'tag.commands.tag.list: cb '
        end,
      },
    },
  },
}
---@return down.mod.Setup
M.setup = function()
  return {
    loaded = true,
    dependencies = { 'workspace', 'cmd' },
  }
end

---@class down.mod.data.tag.Data
M.data = {
  tags = {
    global = {},
    workspace = {},
    document = {},
  },
}

--- Parse a single line for tag instances
--- @param ln string
--- @return string[]
M.data.parse_ln = function(ln)
  local tags = {}
  for tag in ln:gmatch '#%S+' do
    tags:insert(tag)
  end
  return tags
end

M.data.parse = function(text)
  M.data.tags.document = {}
  for ln in text:gmatch '[^\n]+' do
    vim.tbl_deep_extend('force', M.data.tags.document, M.data.parse_ln(ln))
  end
  return M.data.tags.document
end

---@class down.mod.data.tag.Config
M.config = {}

-- ---@class down.mod.data.tag.Subscribed
-- M.handle = {
--   cmd = {
--     ['data.tag.delete'] = function(e) end,
--     ['data.tag.new'] = function(e) end,
--     ['data.tag.list'] = function(e) end,
--   },
-- }

return M
