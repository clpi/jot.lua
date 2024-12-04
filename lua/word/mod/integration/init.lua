---TODO: imelement
local E = require('word.mod').create('integration')

--TODO: implement config to initialize sub integrations depending on user config

---@class word.integration.Config
E.config.public = {
  ---@brief List of integrations to disable (relative to the integration dir)
  disabled = {

  },
  ---@brief List of integrations to enable (relative to the integration dir)
  enabled = {
    "telescope",
    "treesitter",
  }
}

---@class word.integration.Data
E.data = {

}

---@param ext string
---@return string
E.data.get = function(ext)
end

---TODO: implement
---Returns either a table of the loaded dependencies or nil of one is unsuccessful
---@return table<string, any>|nil: the loaded dependency package
---@param ext string: the integration module to check
E.data.deps = function(ext)
  return nil
end
E.data.enabled = {
}

---@return boolean, nil|nil
---@param ext string
E.data.has = function(ext)
  return pcall(require, ext)
end

--- Generic setup function for integration submodules
--- @param ext string: the integration to setup
--- @param req table<string>: the modules required by the integration module
--- @return word.mod.Setup
E.data.setup = function(ext, req)
  local ok, e = E.data.has(ext)
  if ok then return {
    requies = req,
    loaded = true
  }
  else return {
    loaded = false
  }
  end
end

E.setup = function()
  local enabled = {

  }
  return {
    loaded = true,
    requires = enabled
  }
end

return E
