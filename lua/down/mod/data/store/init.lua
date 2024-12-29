local mod = require 'down.mod'

---@class down.mod.data.Store: down.Mod
local Store = mod.new('data.store')

Store.setup = function()
  return {
    loaded = true,
    requires = {
      'data',
    }
  }
end

--- @class down.mod.data.store.Config
Store.config = {

}

--- @class down.mod.data.store.Data
Store.data = {

}

return Store
