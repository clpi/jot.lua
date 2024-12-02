---@type word.mod
local M = require("word.mod").create("mod")


M.setup = function()
  return {
    loaded = true,
  }
end


M.config.public = {

}

---@class module
M.data = {

  data = {}
}

return M
