---@type down.Mod
local M = require "down.mod".new("data.task", {
  "agenda"
})

---@class down.mod.data.task.Task
M.Task = {
  title = "",
  about = "",
  status = 0,
  due = "",
  created = "",
  uri = "",
  ---@type down.Position
  pos = {
    line = -1,
    char = -1,
  }
}
---@class down.mod.data.task.Data
M.data = {

}

---@class table<integer, down.mod.data.task.Task>
M.data.tasks = {

}

---@class down.mod.data.task.Config
M.config = {
  store = {
    root = "data/task",
    agenda = "data/task/agenda",
  }
}

M.load = function()
end

---@return down.mod.Setup
M.setup = function()
  ---@type down.mod.Setup
  return {
    requires = {
      "workspace",
      "ui.calendar",
      "data.store",
      "data.task.agenda",
    },
    loaded = true,
  }
end


return M
