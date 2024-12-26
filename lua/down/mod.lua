local uv, lu, fn = vim.loop or vim.uv, vim.lsp.util, vim.fn
local cb = require('down.util.event.callback')
local config = require('down.config')
local log = require('down.util.log')
local utils = require('down.util')

--- @!TODO : Change to body access where appropriate and now available to avoid complex config for end user
---   1. Firsr try with  Ms, then workspace
---
--- @TODO: Merge Module.data with Module, Module.config as subfield for all modules
---        which have class then of down.mod.[Mod] as M

---@class down.mod.base.Base: down.Mod
local Mod = {
  ---@class down.mod.base.Config
  config = {},
  --- @class down.mod.base.Data
  --- @field mods { [string]: down.Mod }
  --- @field count integer
  data = {
    count = 0,
    --- @type { [string]: down.Mod }
    mods = {},
  },
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
    ---@type down.Event
    event = function(r, e, b)
      return {
        payload = b,
        topic = e,
        type = e,
        split = {},
        content = b,
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
    cmds = nil,
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
      defined = { -- The events that the init itself has defined
      },
    },
    required = {},
    import = {},
    tests = {},
  }
end

--- @param nm string
--- @param im? string[]
Mod.create = function(nm, im)
  local n = Mod.default.mod(nm)
  if im then
    for _, imp in ipairs(im) do
      local fp = table.concat({ nm, imp }, '.')
      if not Mod.load_mod(fp) then
        log.error("Unable to load import '" .. fp .. "'! An error  (see traceback below):")
        assert(false)
      end
      n.import[fp] = Mod.data.mods[fp]
    end
  end
  if nm then
    n.name = nm
    n.path = 'mod.' .. nm
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

--- @param ... string list of modules to load
Mod.modules = function(...)
  local modules = { ... }
  for _, module in ipairs(modules) do
    local ml = Mod.load_mod(module)
    if not ml then
      print('error loading ', module)
    end
  end
end

Mod.delete = function(mod)
  Mod.data.mods[mod] = nil
  return false
end

--- @param m down.Mod The actual init to load.
--- @return boolean # Whether the init successfully loaded.
Mod.load_mod_from_table = function(m)
  if config.dev then
    -- print('Mod.load_mod_from_table', m.name)
  end
  if Mod.data.mods[m.name] then
    return true
  end
  local mod_load = m.setup and m.setup() or Mod.default.setup()
  if mod_load.loaded == false then
    return false
  end
  ---@type down.Mod
  local mod_to_replace
  if mod_load.replaces and mod_load.replaces ~= '' then
    mod_to_replace = vim.deepcopy(Mod.data.mods[mod_load.replaces])
  end
  Mod.data.mods[m.name] = m

  if mod_load.wants and not vim.tbl_isempty(mod_load.wants) then
    for _, req in ipairs(mod_load.wants) do
      if not Mod.is_mod_loaded(req) then
        if config.user[req] then
          if not Mod.load_mod(req) then
            return Mod.delete(m.name)
          end
        else
          return Mod.delete(m.name)
        end
      end
      m.required[req] = Mod.data.mods[req].data
    end
  end
  if mod_load.requires and vim.tbl_count(mod_load.requires) then
    for _, req in pairs(mod_load.requires) do
      if not Mod.is_mod_loaded(req) then
        if not Mod.load_mod(req) then
          return Mod.delete(m.name)
        end
      else
        log.trace('already loaded ', m.name)
      end
      m.required[req] = Mod.data.mods[req].data
    end
  end
  if mod_to_replace then
    m.name = mod_to_replace.name
    if mod_to_replace.replaced then
      Mod.data.mods[m.name] = nil
      return false
    end
    if mod_load.merge then
      m = vim.tbl_deep_extend('force', m, {
        data = mod_to_replace.data,
        config = mod_to_replace.config,
        -- events = mod_to_replace.events,
        -- subscribed = mod_to_replace.subscribed,
        -- cmds = mod_to_replace.cmds,
        -- maps = mod_to_replace.maps,
      })
    end
    m.replaced = true
  end
  Mod.data.count = Mod.data.count + 1
  -- if m.load then m.load() end
  Mod.check(m)
  return true
end

--- @param modn string A path to a init on disk. A path in down is '.', not '/'.
--- @param cfg table? A config that reflects the structure of `down.config.user.setup["init.name"].config`.
--- @return boolean # Whether the init was successfully loaded.
function Mod.load_mod(modn, cfg)
  if Mod.is_mod_loaded(modn) then
    return true
  end
  local modl_ok, modl = pcall(require, 'down.mod.' .. modn)
  if not modl_ok then
    print('could not load mod ' .. modn)
    return false
  end

  if modl == true then
    print('did not return valid mod: ' .. modn)
    return false
  end
  if cfg and not vim.tbl_isempty(cfg) then
    modl.config = utils.extend(modl.config, cfg)
  else
    modl.config = utils.extend(modl.config, cfg or {})
  end
  return Mod.load_mod_from_table(modl)
end

--- Has the same principle of operation as load_mod_from_table(), except it then sets up the parent init's "required" table, allowing the parent to access the child as if it were a dependency.
--- @param md down.Mod A valid table as returned by mod.create()
--- @param parent_mod string|down.Mod If a string, then the parent is searched for in the loaded mod. If a table, then the init is treated as a valid init as returned by mod.create()
function Mod.load_mod_as_dependency_from_table(md, parent_mod)
  if Mod.load_mod_from_table(md) then
    if type(parent_mod) == 'string' then
      Mod.data.mods[parent_mod].required[md.name] = md.data
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
  if Mod.load_mod(modn, cfg) and Mod.is_mod_loaded(parent_mod) then
    Mod.data.mods[parent_mod].required[modn] = Mod.mod_config(modn)
  end
end

--- Retrieves the public API exposed by the init.
--- @generic T
--- @param modn `T` The name of the init to retrieve.
--- @return T?
function Mod.get_mod(modn)
  if not Mod.is_mod_loaded(modn) then
    log.trace('Attempt to get init with name' .. modn .. 'failed - init is not loaded.')
    return
  end

  return Mod.data.mods[modn].data
end

--- Returns the init.config table if the init is loaded
--- @param modn string The name of the init to retrieve (init must be loaded)
--- @return table?
function Mod.data_config(modn)
  if not Mod.is_mod_loaded(modn) then
    log.trace('Attempt to get init config with name' .. modn .. 'failed - init is not loaded.')
    return
  end
  return Mod.data.mods[modn].config
end

--- Returns true if init with name modn is loaded, false otherwise
--- @param modn string The name of an arbitrary init
--- @return boolean
function Mod.is_mod_loaded(modn)
  return Mod.data.mods[modn] ~= nil
end

--- Reads the init's data table and looks for a version variable, then converts it from a string into a table, like so: `{ major = <number>, minor = <number>, patch = <number> }`.
--- @param modn string The name of a valid, loaded init.
--- @return table? parsed_version
function Mod.get_mod_version(modn)
  if not Mod.is_mod_loaded(modn) then
    log.trace('Attempt to get init version with name' .. modn .. 'failed - init is not loaded.')
    return
  end

  -- Grab the version of the init
  local version = Mod.get_mod(modn).version

  -- If it can't be found then error out
  if not version then
    log.trace(
      'Attempt to get init version with name' .. modn .. 'failed - version variable not present.'
    )
    return
  end

  return utils.parse_version_string(version)
end

--- Executes `callback` once `init` is a valid and loaded init, else the callback gets instantly executed.
--- @param modn string The name of the init to listen for.
--- @param callback fun(mod_public_table: table)
function Mod.await(modn, callback)
  if Mod.is_mod_loaded(modn) then
    callback(assert(Mod.get_mod(modn)))
    return
  end

  cb.on('mod_loaded', function(_, m)
    callback(m.data)
  end, function(event)
    return event.content.name == modn
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
  if not Mod.is_mod_loaded(m.name) then
    log.info('Unable to get event of type' .. type .. 'with init' .. m.name)
    return
  end

  local split_type = Mod.split_event_type(type)

  if not split_type then
    log.warn('Unable to get event template for event' .. type .. 'and init' .. m.name)
    return
  end

  log.trace('Returning' .. split_type[2] .. 'for init' .. split_type[1])
  return Mod.data.mods[m.name].events[split_type[2]]
end

--- Creates a deep copy of the `mod.base_event` event and returns it with a custom type and referrer.
--- @param m down.Mod A reference to the init invoking the function.
--- @param name string A relative path to a valid event template.
--- @return down.Event
function Mod.define_event(m, name)
  if name then
    m.type = m.name .. '.events.' .. name
  end
  m.referrer = m.name
  return m
end

--- Returns a copy of the event template provided by a init.
--- @param init down A reference to the init invoking the function
--- @param type string A full path to a valid .vent type (e.g. `init.events.some_event`)
--- @param content table|any? The content of the event, can be anything from a string to a table to whatever you please.
--- @param ev? table The original event data.
--- @return down.Event? # New event.
function Mod.create_event(m, type, content, ev)
  -- Get the init that contains the event
  local modn = Mod.split_event_type(type)[1]

  -- Retrieve the template from init.events
  local event_template = Mod.get_event_template(Mod.data.mods[modn] or { name = '' }, type)

  if not event_template then
    log.warn('Unable to create event of type' .. type .. '. Returning nil...')
    return
  end

  -- Make a deep copy here - we don't want to override the actual base table!
  local mn = vim.deepcopy(event_template)

  mn.type = type
  mn.content = content
  mn.referrer = m.name

  -- Override all the important values
  mn.split_type = assert(Mod.split_event_type(type))
  mn.filename = vim.fn.expand('%:t') --[[@as string]]
  mn.filehead = vim.fn.expand('%:p:h') --[[@as string]]
  local bufid = ev and ev.buf or vim.api.nvim_get_current_buf()
  local winid = assert(vim.fn.bufwinid(bufid))
  if winid == -1 then
    winid = vim.api.nvim_get_current_win()
  end
  mn.cursor_position = vim.api.nvim_win_get_cursor(winid)
  local row_1b = mn.cursor_position[1]
  mn.line_content = vim.api.nvim_buf_get_lines(bufid, row_1b - 1, row_1b, true)[1]
  mn.referrer = m.name
  mn.broadcast = true
  mn.buffer = bufid
  mn.window = winid
  mne = vim.api.nvim_get_mode()

  return mn
end

--- Sends an event to all subscribed mod. The event contains the filename, filehead, cursor position and line content as a bonus.
--- @param event down.Event An event, usually created by `mod.create_event()`.
--- @param callback function? A callback to be invoked after all events have been asynchronously broadcast
function Mod.broadcast(event, callback)
  -- Broadcast the event to all mod
  if not event.split_type then
    log.error('Unable to broadcast event of type' .. event.type .. '- invalid event name')
    return
  end

  cb.handle(event)

  for _, cm in pairs(Mod.data.mods) do
    if cm.subscribed and cm.subscribed[event.split_type[1]] then
      local evt = cm.subscribed[event.split_type[1]][event.split_type[2]]
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
--- @param ev down.Event An event, usually created by `mod.create_event()`.
--- @return nil
function Mod.send_event(recv, ev)
  if not Mod.is_mod_loaded(recv) then
    log.warn('Unable to send event to init' .. recv .. '- the init is not loaded.')
    return
  end
  ev.broadcast = false
  cb.handle(ev)
  local modl = Mod.data.mods[recv]
  if modl.subscribed and modl.subscribed[ev.split_type[1]] then
    local evt = modl.subscribed[ev.split_type[1]][ev.split_type[2]]
    if evt ~= nil and evt == true then
      modl.on(ev)
    end
  end
end

---@param m down.Mod
function Mod.check(m)
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

function Mod.started()
  return Mod.broadcast({
    type = 'mod_loaded',
    split = { 'mod_loaded' },
    file = '',
    dir = '',
    position = { 0, 0 },
    ref = m,
    line = '',
    body = m,
    payload = m,
    topic = 'mod_loaded',
    broadcast = true,
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
    mode = vim.fn.mode(),
  })
end

return setmetatable(Mod, {
  ---@param self down.mod.base.Base
  ---@param modname string
  __call = function(self, modname, ...)
    return self.create(modname, ...)
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
