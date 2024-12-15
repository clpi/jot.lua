local C = require("word.mod").create("data.clipboard")

C.setup = function()
  return {
    loaded = true,
  }
end

---@class word.data.clipboard.Data
C.config.public = {}

---@class word.data.clipboard.Data
C.data = {}

return C
