---@type down.Mod
local M = require "down.mod".new("task.agenda", {
})

---@class down.data.task.agenda.Agenda
M.Agenda = {

  ---@type lsp.URI
  uri = "",

  ---@type down.Store
  store = {},

  ---@type down.Store
  tasks = {}
}
---@class down.mod.data.task.agenda.Data
M.data = {

}

---@class table<down.mod.data.task.agenda.Agenda>
M.data.agendas = {

}

---@class down.mod.data.task.agenda.Config
M.config = {


  ---@type lsp.URI
  uri = "",

  ---@type down.Store
  store = "data/agendas"

}

---@return down.mod.Setup
M.setup = function()
  ---@type down.mod.Setup
  return {
    dependencies = {

    },
    loaded = true,
  }
end

M.load = function()

end


return M
