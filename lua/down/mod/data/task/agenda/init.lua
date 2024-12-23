---@class down.Mod
local M = require "down.mod".create("data.task.agenda", {
})

---@class down.data.task.agenda.Agenda
M.Agenda = {

  uri = "",

  store = "",

  tasks = {

  }
}
---@class down.data.task.agenda.Data
M.data = {

}

---@class table<down.data.task.agenda.Agenda>
M.data.agendas = {

}

---@class down.data.task.agenda.Config
M.config = {


  uri = "",

  store = "data/agendas"

}

---@return down.mod.Setup
M.setup = function()
  ---@type down.mod.Setup
  return {
    requires = {

    },
    loaded = true,
  }
end


return M
