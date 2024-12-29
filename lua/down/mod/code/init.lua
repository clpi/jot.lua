local mod = require('down.mod')

--- @class down.mod.Code: down.Mod
local Code = mod.new('code')

--- @class down.mod.code.Config
---   @field languages string[]
Code.config = {
  --- What languages to support
  languages = {},
}

--- @class down.mod.code.Data
Code.data = {}

Code.setup = function()
  return {
    loaded = true,
    requires = {},
  }
end

return Code
