---@type down.Mod
local M = require "down.mod".create("data.store", {
})

---@class down.mod.data.store.Store
M.Store = {
  title = "",
  about = "",
  status = 0,
  due = "",
  created = "",
  uri = "",
  pos = {
    line = -1,
    char = -1,
  }
}
---@class down.mod.data.store.Data
M.data = {

}

---@class table<down.mod.data.store.Store>
M.data.stores = {

}

---@class down.mod.data.store.Config
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
