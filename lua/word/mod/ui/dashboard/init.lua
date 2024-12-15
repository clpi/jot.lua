local D = require("word.mod").create("ui.dashboard")

D.setup = function()
  return {
    loaded = true,
    requires = {},
  }
end

---@class word.ui.dashboard.Config
D.config.public = {}

---@class word.ui.dashboard.Data
D.data = {}

return D
