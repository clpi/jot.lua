local C = require("down.mod").create("data.clipboard")

C.setup = function()
  return {
    loaded = true,
  }
end

---@class down.data.clipboard.Data
C.config = {}

---@class down.data.clipboard.Data
C.data = {}


return C
