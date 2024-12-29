---@type down.Mod
local M = require 'down.mod'.new('task', {
  'agenda',
})

---@class down.mod.data.task.Task
M.Task = {
  title = '',
  about = '',
  status = 0,
  due = '',
  created = '',
  uri = '',
  ---@type down.Position
  pos = {
    line = -1,
    char = -1,
  },
}
---@class down.mod.data.task.Data
M.data = {}

---@class table<integer, down.mod.data.task.Task>
M.data.tasks = {}

---@class down.mod.data.task.Config
M.config = {
  store = {
    root = 'data/task',
    agenda = 'data/task/agenda',
  },
}

M.commands = {
  task = {
    name = 'task',
    args = 0,
    max_args = 1,
    subcommands = {
      list = {
        args = 0,
        max_args = 1,
        name = 'task.list',
        subcommands = {
          today = {
            name = 'task.list.today',
            args = 0,
            max_args = 1,
          },
          recurring = {
            name = 'task.list.recurring',
            args = 0,
            max_args = 1,
          },
          todo = {
            name = 'task.list.todo',
            args = 0,
            max_args = 1,
          },
          done = {
            name = 'task.list.done',
            args = 0,
            max_args = 1,
          },
        },
      },
      add = {
        name = 'task.add',
        args = 1,
        min_args = 0,
        max_args = 2,
      },
    },
  },
}

M.load = function() end

---@return down.mod.Setup
M.setup = function()
  ---@type down.mod.Setup
  return {
    requires = {
      'workspace',
      'cmd',
      'ui.calendar',
      'data.store',
      'data.task.agenda',
    },
    loaded = true,
  }
end

return M
