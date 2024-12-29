local P = require 'down.mod'.create('parse')

P.setup = function()
  return {
    loaded = true,
    requires = {
      'tool.treesitter'
    }
  }
end

P.load = function()
end

---@class down.mod.parse.Config
P.config = {

}

---@class down.mod.parse.Data
P.data = {

}

return P
