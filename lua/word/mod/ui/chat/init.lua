local C = require("word.mod").create("ui.chat")

C.setup = function()
  return {
    loaded = true,
    requires = {},
  }
end

---@class word.ui.chat.Config
C.config.public = {}

---@class word.ui.chat.Data
C.data = {}

return C
