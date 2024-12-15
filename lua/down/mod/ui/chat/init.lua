local C = require("down.mod").create("ui.chat")

C.setup = function()
  return {
    loaded = true,
    requires = {},
  }
end

---@class down.ui.chat.Config
C.config = {}

---@class down.ui.chat.Data
C.data = {}

return C
