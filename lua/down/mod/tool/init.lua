---TODO: imelement
local E = require('down.mod').create('tool')

--TODO: implement config to initialize sub tools depending on user config

---@class down.tool.Config
E.config = {
  ---@brief List of tools to disable (relative to the tool dir)
  disabled = {

  },
  ---@brief List of tools to enable (relative to the tool dir)
  enabled = {
    "telescope",
    "treesitter",
  }
}

---@class down.tool.Data
E.data = {

}

---@param ext string
---@return string
E.data.get = function(ext)
end

---TODO: implement
---Returns either a table of the loaded dependencies or nil of one is unsuccessful
---@return table<string, any>|nil: the loaded dependency package
---@param ext string: the tool module to check
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

--- Generic setup function for tool submodules
--- @param ext string: the tool to setup
--- @param req table<string>: the modules required by the tool module
--- @return down.mod.Setup
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
