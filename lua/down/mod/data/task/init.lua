---@class down.Mod
local M = require "down.mod".create("data.task", {
  "agenda"
})

---@class down.data.task.Task
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
---@class down.data.task.Data
M.data = {

}

---@class table<down.data.task.Task>
M.data.tasks = {

}

---@class down.data.task.Config
M.config = {
  store = {
    root = "data/task",
    agenda = "data/task/agenda",
  }
}

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
