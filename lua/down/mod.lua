local uv, lu, fn = vim.loop or vim.uv, vim.lsp.util, vim.fn
local util = require 'down.util'
local utils = require 'down.util'
local cb = require('down.util.event.callback')
local config = require('down.config')
local log = require('down.util.log')

--- @!TODO : Change to body access where appropriate and now available to avoid complex config for end user
---   1. Firsr try with  Ms, then workspace
---
--- @TODO: Merge Module.data with Module, Module.config as subfield for all modules
---        which have class then of down.mod.[Mod] as M

---@class down.mod.base.Base: down.Mod
local Mod = {
  count = 0,
  mods = {},
  ---@class down.mod.base.Config
  config = {},
  --- @class down.mod.base.Data
  --- @field mods { [string]: down.Mod }
  --- @field count integer
  default = {
    ---@type fun():down.mod.Setup
    setup = function()
      return {
        loaded = true,
        replaces = {},
        merge = false,
        requires = {},
        wants = {},
      }
    end,
    ---@type fun(r: string, e:string, b: string): down.Event
    event = function(r, e, b)
      return {
        payload = b,
        topic = e,
        type = e,
        split = {},
        body = b,
        ref = r,
        broadcast = true,
        position = {},
        file = '',
        dir = '',
        line = vim.api.nvim_get_current_line(),
        buf = vim.api.nvim_get_current_buf(),
        win = vim.api.nvim_get_current_win(),
        mode = vim.fn.mode(),
      }
    end,
  },
}

---@return down.Mod
Mod.default.mod = function(n)
  return {
    setup = Mod.default.setup,
    cmds = function() end,
    load = function()
      -- print 'default load n'
    end,
    post_load = function()
      -- print('postload' .. n)
    end,
    maps = nil,
    on = function(e)
      -- print('load' .. e)
    end,
    name = n,
    namespace = 'down.mod.' .. n,
    path = 'mod.' .. n,
    version = '0.1.2-alpha',
    data = {},
    config = {},
    events = {
      subscribed = { -- The events that the init is subscribed to
      },
      defined = {    -- The events that the init itself has defined
      },
    },
    required = {},
    import = {},
    tests = {},
  }
end

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
  if nm then
    n.name = nm
    n.namespace = 'down.mod.' .. nm
    if n.namespace then
      vim.api.nvim_create_namespace(n.namespace)
    end
  end
  return n
end

---@param m down.Mod
Mod.pre_run = function(m)
  m.setup = function()
    return { loaded = true }
  end
  if m.cmds then
    m.cmds()
  end
  if m.maps then
    m.maps()
  end
end

---@return nil
Mod.delete = function(mod)
  Mod.mods[mod] = nil
  return nil
end
--- @param m down.Mod The actual init to load.
--- @return down.Mod|nil # Whether the init successfully loaded.
Mod.load_mod_from_table = function(m, cfg)
  if Mod.mods[m.name] ~= nil then
    return Mod.mods[m.name]
  end
  local mod_load = m.setup and m.setup() or Mod.default.setup()
  -- if mod_load.loaded == false then
  --   return nil
  -- end
  ---@type down.Mod
  local mod_to_replace
  if mod_load.replaces and mod_load.replaces ~= '' then
    mod_to_replace = vim.deepcopy(Mod.mods[mod_load.replaces])
  end
  Mod.mods[m.name] = m

  if mod_load.wants and not vim.tbl_isempty(mod_load.wants) then
    for _, req in ipairs(mod_load.wants) do
      if not Mod.is_loaded(req) then
        if config.user[req] then
          if not Mod.load_mod(req) then
            return Mod.delete(m.name)
          end
        else
          return Mod.delete(m.name)
        end
      end
      m.required[req] = Mod.mods[req].data
    end
  end
  if mod_load.requires and vim.tbl_count(mod_load.requires) then
    for _, req in pairs(mod_load.requires) do
      if not Mod.is_loaded(req) then
        if not Mod.load_mod(req) then
          return Mod.delete(m.name)
        end
      else
        log.trace('already loaded ', m.name)
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
  Mod.count = Mod.count + 1
  Mod.mod_load(m)
  return Mod.mods[m.name]
end

--- @param modn string A path to a init on disk. A path in down is '.', not '/'.
--- @param cfg table? A config that reflects the structure of `down.config.user.setup["init.name"].config`.
--- @return down.Mod|nil # Whether the init was successfully loaded.
function Mod.load_mod(modn, cfg)
  if Mod.mods[modn] and cfg == nil then
    -- if modn == 'workspace' then
    -- for w, ws in pairs(Mod.mods[modn].config.workspaces) do
    -- end
    -- Mod.mods[modn].config = util.extend(cfg or {}, Mod.mods[modn].config)
    -- return Mod.mods[modn]
    -- end
    return Mod.mods[modn]
  elseif Mod.mods[modn] and cfg ~= nil then
    Mod.mods[modn].config = util.extend(cfg or {}, Mod.mods[modn].config)
    return Mod.mods[modn]
  end
  --   return Mod.mods[modn]
  -- elseif cfg ~= nil and Mod.mods[modn] then
  --   return Mod.mods[modn]
  -- end
  local modl = require('down.mod.' .. modn)
  if not modl then
    print('Mod.load_mod: could not load mod ' .. modn)
    return nil
  end
  if modl == true then
    log.error('did not return valid mod: ' .. modn)
    return nil
  end
  if cfg and not vim.tbl_isempty(cfg) then
    modl.config = util.extend(modl.config, cfg)
  end

  --   modl.config.workspaces = cfg.workspaces
  --   for w, ws in pairs(modl.config.workspaces) do
  --     print('workspace', w, ws)
  --   end
  -- end
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
    log.trace('Attempt to get init config with name', modn, 'failed - init is not loaded.')
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
function Mod.await(modn, callback)
  if Mod.is_loaded(modn) then
    callback(assert(Mod.get_mod(modn)))
    return
  end

  cb.on('mod_loaded', function(_, m)
    callback(m.data)
  end, function(event)
    return event.body.name == modn
  end)
end

--- @param type string The full path of a init event
--- @return string[]?
function Mod.split_event_type(type)
  local start_str, end_str = type:find('%.events%.')

  local split_event_type = { type:sub(0, start_str - 1), type:sub(end_str + 1) }

  if #split_event_type ~= 2 then
    log.warn('Invalid type name:', type)
    return
  end

  return split_event_type
end

--- Returns an event template defined in `init.events`.
--- @param m down.Mod A reference to the init invoking the function
--- @param type string A full path to a valid event type (e.g. `init.events.some_event`)
--- @return down.Event?
function Mod.get_event_template(m, type)
  if not Mod.is_loaded(m.name) then
    log.info('Unable to get event of type' .. type .. 'with init' .. m.name)
    return
  end

  local split = Mod.split_event_type(type)

  if not split then
    log.warn('Unable to get event template for event' .. type .. 'and init' .. m.name)
    return
  end

  log.trace('Returning' .. split[2] .. 'for init' .. split[1])
  return Mod.mods[m.name].events[split[2]]
end

--- Creates a deep copy of the `mod.base_event` event and returns it with a custom type and referrer.
--- @param m down.Mod A reference to the init invoking the function.
--- @param name string A relative path to a valid event template.
--- @return down.Event
function Mod.define_event(m, name)
  if name then
    m.type = m.name .. '.events.' .. name
  end
  m.ref = m.name
  return m
end

--- Returns a copy of the event template provided by a init.
--- @param init down A reference to the init invoking the function
--- @param type string A full path to a valid .vent type (e.g. `init.events.some_event`)
--- @param body table|any? The body of the event, can be anything from a string to a table to whatever you please.
--- @param ev? table The original event data.
--- @return down.Event? # New event.
function Mod.new_event(m, type, body, ev)
  -- Get the init that contains the event
  local modn = Mod.split_event_type(type)[1]

  -- Retrieve the template from init.events
  local event_template = Mod.get_event_template(Mod.mods[modn] or { name = '' }, type)

  if not event_template then
    log.warn('Unable to create event of type' .. type .. '. Returning nil...')
    return
  end

  -- Make a deep copy here - we don't want to override the actual base table!
  local mn = vim.deepcopy(event_template)

  mn.type = type
  mn.body = body
  mn.ref = m.name

  -- Override all the important values
  mn.split = assert(Mod.split_event_type(type))
  mn.file = vim.fn.expand('%:t') --[[@as string]]
  mn.dir = vim.fn.expand('%:p:h') --[[@as string]]
  local bufid = ev and ev.buf or vim.api.nvim_get_current_buf()
  local winid = assert(vim.fn.bufwinid(bufid))
  if winid == -1 then
    winid = vim.api.nvim_get_current_win()
  end
  mn.position = vim.api.nvim_win_get_cursor(winid)
  local row_1b = mn.position[1]
  mn.line = vim.api.nvim_buf_get_lines(bufid, row_1b - 1, row_1b, true)[1]
  mn.ref = m.name
  mn.broadcast = true
  mn.buf = bufid
  mn.win = winid
  mn.mode = vim.api.nvim_get_mode()
  return mn
end

--- Sends an event to all subscribed mod. The event contains the filename, filehead, cursor position and line body as a bonus.
--- @param event down.Event An event, usually created by `mod.new_event()`.
--- @param callback function? A callback to be invoked after all events have been asynchronously broadcast
function Mod.broadcast(event, callback)
  -- Broadcast the event to all mod
  if not event.split then
    log.error('Unable to broadcast event of type' .. event.type .. '- invalid event name')
    return
  end

  cb.handle(event)

  for _, cm in pairs(Mod.mods) do
    if cm.subscribed and cm.subscribed[event.split[1]] then
      local evt = cm.subscribed[event.split[1]][event.split[2]]
      if evt ~= nil and evt == true then
        cm.on(event)
      end
    end
  end
  -- TODO: deprecate
  if callback then
    callback()
  end
end

--- @param recv string The name of a loaded init that will be the recipient of the event.
--- @param ev down.Event An event, usually created by `mod.new_event()`.
--- @return nil
function Mod.send_event(recv, ev)
  if not Mod.is_loaded(recv) then
    log.warn('Unable to send event to init' .. recv .. '- the init is not loaded.')
    return
  end
  ev.broadcast = false
  cb.handle(ev)
  local modl = Mod.mods[recv]
  if modl.subscribed and modl.subscribed[ev.split[1]] then
    local evt = modl.subscribed[ev.split[1]][ev.split[2]]
    if evt ~= nil and evt == true then
      modl.on(ev)
    end
  end
end

---@param m down.Mod
function Mod.mod_load(m)
  if m.cmds then
    m.cmds()
  end
  if m.maps then
    m.maps()
  end
  if m.load then
    m.load()
  end
end

Mod.default.mods = {
  'tool.telescope',
  'lsp',
  'note',
  -- 'workspace',
  'data.log',
  'data.template',
}

Mod.get = function(m)
  local path = 'down.mod.' .. m
  local ok, pc = require(path)
  if ok then
    return pc
  else
    print('U.load_mod: could not load mod ' .. path)
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
