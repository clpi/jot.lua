local down = require("down")

local S = require("down.mod").new("ui.sidebar")

S.setup = function()
  return {
    loaded = true,
  }
end

---@class down.ui.sidebar.Config
S.config = {}

---@class down.ui.sidebar.Data
S.data = {}

return S
