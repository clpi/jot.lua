local Event = require 'down.event'
local util = require 'down.util'
local log = require('down.util.log')

--- @!TODO : Change to body access where appropriate and now available to avoid complex config for end user
---   1. Firsr try with  Ms, then workspace
---
--- @TODO: Merge Module.data with Module, Module.config as subfield for all modules
---        which have class then of down.mod.[Mod] as M
---
---
--- TODO: Make Mod.subscribed be [string]: function() instead of [string]: boolean
---       and eliminate Mod.handler(e)

---@class down.Mod
local Mod = {
  setup = function()
    return {
      loaded = true,
      replaces = {},
      merge = false,
      requires = {},
    }
  end,
  load = function()
    -- print 'default load n'
  end,
  post_load = function()
    -- print('postload' .. n)
  end,
  opts = {},
  maps = {},
  commands = {},
  handle = function(e)
    -- print('load' .. e)
  end,
  name = '',
  namespace = '',
  data = {},
  config = {},
  events = {},
  subscribed = {},
  required = {},
  import = {},
  tests = {},
}

---@type metatable
Mod.data.metatable = {
  __index = function(self, k)
    return self.required[k]
  end,
  __newindex = function(self, k, v)
    self.data[k] = v
  end,
  __eq = function(m1, m2)
    return m1.name == m2.name
  end,
  __call = function(self, fun, ...)
    return self.data[fun](...)
  end,
}

Mod.mods = {}

Mod.default = {
  mods = {
    'tool.telescope',
    'lsp',
    'note',
    'workspace',
    'data.log',
    'template',
  },
  ---@type fun():down.mod.Setup
  setup = function()
    return {
      loaded = true,
      replaces = {},
      merge = false,
      requires = {},
    }
  end,
  ---@return down.Mod
  mod = function(n)
    ---@type down.Mod
    return setmetatable({
      setup = Mod.setup,
      commands = {},
      load = function()
        -- print 'default load n'
      end,
      post_load = function()
        -- print('postload' .. n)
      end,
      opts = {},
      maps = {},
      handle = function(e)
        -- print('load' .. e)
      end,
      name = n,
      namespace = vim.api.nvim_create_namespace('down.mod.' .. n),
      data = {},
      config = {},
      events = {},
      subscribed = {},
      required = {},
      import = {},
      tests = {},
    }, Mod.data.metatable)
  end,
}

--- @param nm string
--- @param im? string[]
Mod.new = function(nm, im)
  local n = Mod.default.mod(nm)
  if im then
    for _, imp in ipairs(im) do
      local fp = table.concat({ nm, imp }, '.')
      if not Mod.load_mod(fp) then
        log.error("Unable to load import '" .. fp .. "'! An error  (see traceback below):")
        assert(false)
      end
      n.import[fp] = Mod.mods[fp]
    end
  end
  return n
end

--- @param mod string
---@return nil
Mod.delete = function(mod)
  Mod.mods[mod] = nil
  return nil
end

--- @param m down.Mod.Mod The actual init to load.
--- @return down.Mod|nil # Whether the init successfully loaded.
Mod.load_mod_from_table = function(m, cfg)
  if Mod.mods[m.name] ~= nil then
    return Mod.mods[m.name]
  end
  local mod_load = m.setup and m.setup() or Mod.default.setup()
  ---@type down.Mod
  local mod_to_replace
  if mod_load.replaces and mod_load.replaces ~= '' then
    mod_to_replace = vim.deepcopy(Mod.mods[mod_load.replaces])
  end
  Mod.mods[m.name] = m
  if mod_load.requires and vim.tbl_count(mod_load.requires) then
    for _, req in pairs(mod_load.requires) do
      if not Mod.is_loaded(req) then
        if not Mod.load_mod(req) then
          return Mod.delete(m.name)
        end
      else
        log.trace('already loaded ' .. m.name)
      end
      m.required[req] = Mod.mods[req].data
    end
  end
  if mod_to_replace then
    m.name = mod_to_replace.name
    if mod_to_replace.replaced then
      return Mod.delete(m.name)
    end
    if mod_load.merge then
      m = vim.tbl_deep_extend('force', m, mod_to_replace)
    end
    m.replaced = true
  end
  Mod.mod_load(m)
  return Mod.mods[m.name]
end

--- @param modn string
--- @return down.config.Mod?
function Mod.check_mod(modn)
  local modl = require('down.mod.' .. modn)
  if not modl then
    log.error('Mod.load_mod: could not load mod ' .. modn)
    return nil
  end
  if modl == true then
    log.error('did not return valid mod: ' .. modn)
    return nil
  end
  return modl
end

--- @param modn string A path to a init on disk. A path in down is '.', not '/'.
--- @param cfg table? A config that reflects the structure of `down.config.user.setup["init.name"].config`.
--- @return down.Mod|nil # Whether the init was successfully loaded.
function Mod.load_mod(modn, cfg)
  if Mod.mods[modn] then
    if cfg ~= nil then
      Mod.mods[modn].config = util.extend(cfg or {}, Mod.mods[modn].config)
    end
    return Mod.mods[modn]
  end
  local modl = Mod.check_mod(modn)
  if not modl then
    return nil
  end
  if cfg and not vim.tbl_isempty(cfg) then
    modl.config = util.extend(modl.config, cfg)
  end
  return Mod.load_mod_from_table(modl)
end

--- Has the same principle of operation as load_mod_from_table(), except it then sets up the parent init's "required" table, allowing the parent to access the child as if it were a dependency.
--- @param md down.Mod A valid table as returned by mod.new()
--- @param parent_mod string|down.Mod If a string, then the parent is searched for in the loaded mod. If a table, then the init is treated as a valid init as returned by mod.new()
function Mod.load_mod_as_dependency_from_table(md, parent_mod)
  if Mod.load_mod_from_table(md) then
    if type(parent_mod) == 'string' then
      Mod.mods[parent_mod].required[md.name] = md.data
    elseif type(parent_mod) == 'table' then
      parent_mod.required[md.name] = md.data
    end
  end
end

--- Normally loads a init, but then sets up the parent init's "required" table, allowing the parent init to access the child as if it were a dependency.
--- @param modn string A path to a init on disk. A path  in down is '.', not '/'
--- @param parent_mod string The name of the parent init. This is the init which the dependency will be attached to.
--- @param cfg? table A config that reflects the structure of down.config.user.setup["init.name"].config
function Mod.load_mod_as_dependency(modn, parent_mod, cfg)
  if Mod.load_mod(modn, cfg) and Mod.is_loaded(parent_mod) then
    Mod.mods[parent_mod].required[modn] = Mod.mod_config(modn)
  end
end

--- Returns the init.config table if the init is loaded
--- @param modn string The name of the init to retrieve (init must be loaded)
--- @return table?
function Mod.mod_config(modn)
  if not Mod.is_loaded(modn) then
    log.trace('Attempt to get init config with name' .. modn .. 'failed - init is not loaded.')
    return
  end
  return Mod.mods[modn].config
end

--- Retrieves the public API exposed by the init.
--- @generic T
--- @param modn `T` The name of the init to retrieve.
--- @return T?
function Mod.get_mod(modn)
  if not Mod.is_loaded(modn) then
    log.trace('Attempt to get init with name' .. modn .. 'failed - init is not loaded.')
    return
  end
  return Mod.mods[modn].data
end

--- Returns true if init with name modn is loaded, false otherwise
--- @param modn string The name of an arbitrary init
--- @return down.Mod|nil
function Mod.is_loaded(modn)
  if Mod.mods[modn] ~= nil then
    return Mod.mods[modn]
  end
  return nil
end

--- Executes `callback` once `init` is a valid and loaded init, else the callback gets instantly executed.
--- @param modn string The name of the init to listen for.
--- @param callback fun(mod_public_table: table)
function Mod.await(modn, cb)
  if Mod.is_loaded(modn) then
    cb(assert(Mod.get_mod(modn)))
    return
  end

  Event.callback('mod_loaded', function(_, m)
    cb(m.data)
  end, function(event)
    return event.body.name == modn
  end)
end

---@param m down.Mod
function Mod.load_opts(m)
  if m.opts then
    for i, k in ipairs(m.opts) do
    end
  end
end

---@param m down.Mod
function Mod.load_maps(m)
  if m.maps then
    if type(m.maps) == 'function' then
      return
    elseif type(m.maps) == 'table' then
      for i, k in ipairs(m.maps) do
        vim.keymap.set(
          k[1] or 'n',
          k[2],
          k[3],
          { desc = k[4], noremap = true, nowait = true, silent = true }
        )
      end
    end
  end
end

---@param m down.Mod
function Mod.mod_load(m)
  Mod.load_maps(m)
  Mod.load_opts(m)
  if m.load then
    m.load()
  end
end

Mod.get = function(m)
  local ok, pc = pcall(require, 'down.mod.' .. m)
  if ok then
    return pc
  else
    log.error('U.load_mod: could not load mod ' .. 'down.mod.' .. m)
    return nil
  end
end
--- @param ms? table<any, string> list of modules to load
--- @return table<integer, down.Mod>
Mod.modules = function(ms)
  local modmap = {}
  for _, module in ipairs(ms or Mod.default.mods) do
    modmap[module] = Mod.get(module)
  end
  return modmap
end

---@param m down.Mod
Mod.test = function(m)
  if m.tests then
    for tn, test in m.tests do
      log.info('Running test ', tn, ' for ', m.name, ':')
      test(m)
    end
  end
end

Mod.handle_event = function(e)
  for m, mod in pairs(Mod.mods) do
    if mod.subscribed[e.type] then
      mod.subscribed[e.type]()
    end
  end
end

--- @param m down.Mod.Mod
--- @param name string
--- @param body table
--- @param ev? table
--- @return down.Event?
function Mod.new_event(m, type, body, ev)
  return Event.new(m, type, body, ev)
end

---@type fun(module: down.Mod.Mod, name: string): down.Event
---@return down.Event
function Mod.define_event(module, name)
  return Event.define(module, name)
end

function Mod.broadcast(e)
  Event.broadcast_to(e, Mod.mods)
end

return setmetatable(Mod, {
  ---@param self down.mod.base.Base
  ---@param modname string
  __call = function(self, modname, ...)
    return self.new(modname, ...)
  end,
  -- --- @param self down.mod.base.Base
  -- --- @param modname string A path to a init on disk. A path in down is '.', not '/'.
  -- --- @param modcfg table? A config that reflects the structure of `down.config.user.setup["init.name"].config`.
  -- --- @return boolean # Whether the init was successfully loaded.
  -- __index = function(self, modname)
  --   return self.load_mod(modname)
  -- end,
  -- --- @param self down.Mod
  -- --- @param modn string A path to a init on disk. A path in down is '.', not '/'.
  -- --- @param cfg table? A config that reflects the structure of `down.config.user.setup["init.name"].config`.
  -- --- @return boolean # Whether the init was successfully loaded.
  -- __newindex = function(self, modn, value)
  --   return self.load_mod(modn, value)
  -- end,
})
