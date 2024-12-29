
---@enum down.task.Status
local Status = {
  "done",
  "in_progress",
  "cancelled",
  "postponed",
}


local Task = {
  ---@type down.Task.Status
  status = "",
}

return Task
