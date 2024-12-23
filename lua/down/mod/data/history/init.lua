---@class down.Mod
local M = require "down.mod".create("data.history", {

})

---@alias down.data.history.Store down.Store Store
---@type down.data.history.Store Store
M.Data.store = {

}
---@class down.data.history.Data
M.data = {

}

---@class table<down.data.history.Store>
M.data.stores = {

}

---@class down.data.history.Config
M.config = {

  store = "data/stores"

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
