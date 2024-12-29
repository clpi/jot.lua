local log = require 'down.util.log'

---@type down.Event
local Event = {
  topic = '',
  type = '',
  ref = '',
  split = {},
  body = nil,
  broadcast = true,
  position = vim.api.nvim_win_get_cursor(0),
  file = vim.fn.expand('%:p'),
  dir = vim.fn.getcwd(),
  buf = vim.api.nvim_get_current_buf(),
  win = vim.api.nvim_get_current_win(),
  mode = vim.fn.mode(),
  line = vim.api.nvim_win_get_cursor(0)[1],
  char = vim.api.nvim_win_get_cursor(0)[2],
  ---@type down.Context
  context = {
    ---@type down.Position
    position = {
      line = vim.api.nvim_win_get_cursor(0)[1],
      char = vim.api.nvim_win_get_cursor(0)[2],
    },
    line = vim.api.nvim_get_current_line(),
    char = vim.api.nvim_win_get_cursor(0)[2],
    file = vim.fn.expand('%:p'),
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
    dir = vim.fn.getcwd(),
    scope = "global"
  },
}

--- @class down.Callback
---   @field callbacks table<string, { [1]: fun(event: down.Event, content: table|any), [2]?: fun(event: down.Event): boolean }>
local Cb = {
  ---@type table<string, { [1]: fun(event: down.Event, content: table|any), [2]?: fun(event: down.Event): boolean }>
  cb = {},
}


--- @param ty? string
--- @return { [1]: fun(event: down.Event, content: table|any)> }
function Event:get_cb(ty)
  return Cb.cb[ty or self.type]
end

--- Triggers a new callback to execute whenever an event of the requested type is executed.
--- @param self down.Event | string
--- @param cb fun(event: down.Event, content: table|any) The function to call whenever our event gets triggered.
--- @param filt? fun(event: down.Event): boolean # A filtering function to test if a certain event meets our expectations.
function Event.callback(self, cb, filt)
  local ty = (self and self.type) or self
  Cb.cb[ty] = Cb.cb[ty] or {}
  table.insert(Cb.cb[ty], { cb, filt })
end

--- @param cb? fun(event: down.Event, content: table|any)
function Event:set_callback(cb)
  Cb.cb[self.type] = Cb.cb[self.type] or {}
  Cb.cb[self.type]:insert(cb)
end

--- Used internally by down to call all C with an event.
--- @param self down.Event
function Event.handle(self)
  local cbentry = Cb.cb[self.type]
  if cbentry then
    for _, cb in ipairs(cbentry) do
      if not cb[2] or cb[2](self) then
        cb[1](self, self.body)
      end
    end
  end
end

---@type fun(module: down.Mod.Mod, name: string): down.Event
---@return down.Event
Event.define = function(module, name)
  local mn = ""
  if type(module) == 'table' then
    mn = module.name
  elseif type(module) == 'string' then
    mn = module
  end
  local type = mn .. '.events.' .. name
  return { ---@type down.Event
    topic = type,
    type = type,
    ref = mn,
    split = Event.split_type(type) or {},
    body = module,
    broadcast = true,
    position = vim.api.nvim_win_get_cursor(0),
    file = vim.fn.expand('%:p'),
    dir = vim.fn.getcwd(),
    line = vim.api.nvim_get_current_line(),
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
    mode = vim.fn.mode(),
    context = nil,
  }
end

--- @param type string The full path of a init event
--- @return string[]?
function Event.split_type(type)
  local start_str, end_str = type:find('%.events%.')
  local split_event_type = { type:sub(0, start_str - 1), type:sub(end_str + 1) }
  if #split_event_type ~= 2 then
    log.warn('Invalid type name:' .. type)
    return
  end
  return split_event_type
end

--- Returns an event template defined in `init.events`.
--- @param m down.Mod.Mod A reference to the init invoking the function
--- @param type string A full path to a valid event type (e.g. `init.events.some_event`)
--- @return down.Event?
function Event.get_template(m, type)
  local split = Event.split_type(type)
  if not split then
    log.warn('Unable to get event template for event' .. type .. 'and init' .. m.name)
    return
  end

  log.trace('Returning' .. split[2] .. 'for init' .. split[1])
  return m.events[split[2]]
end

--- Returns a copy of the event template provided by a init.
--- @param m down.Mod.Mod A reference to the init invoking the function
--- @param type string A full path to a valid .vent type (e.g. `init.events.some_event`)
--- @param body table|any? The body of the event, can be anything from a string to a table to whatever you please.
--- @param ev? table The original event data.
--- @return down.Event? # New event.
function Event.new(m, type, body, ev)
  local split = Event.split_type(type)
  local event_template = Event.get_template(m or { name = '' }, type)
  if not event_template then
    log.warn('Unable to create event of type' .. type .. '. Returning nil...')
    return
  end
  local mn = vim.deepcopy(event_template)
  mn.type = type
  mn.body = body
  mn.ref = m.name
  mn.split = assert(split)
  mn.file = vim.fn.expand('%:t') --[[@as string]]
  mn.dir = vim.fn.expand('%:p:h') --[[@as string]]
  mn.buf = ev and ev.buf or vim.api.nvim_get_current_buf()
  mn.win = vim.api.nvim_get_current_win()
  mn.position = vim.api.nvim_win_get_cursor(mn.win)
  mn.mode = vim.api.nvim_get_mode()
  mn.line = vim.api.nvim_buf_get_lines(mn.buf, mn.position[1] - 1, mn.position[1], true)[1]
  mn.ref = m.name
  mn.broadcast = true
  return mn
end

--- Sends an event to all subscribed mod. The event contains the filename, filehead, cursor position and line body as a bonus.
--- @param mods down.Mod.Mod[]
--- @param self down.Event
function Event.broadcast_to(self, mods)
  if not self.split then
    log.error('Unable to broadcast event of type' .. self.type .. '- invalid event name')
    return
  end
  Event.handle(self)
  for _, cm in pairs(mods or {}) do
    if cm.subscribed and cm.subscribed[self.split[1]] then
      local evt = cm.subscribed[self.split[1]][self.split[2]]
      if evt ~= nil and evt == true then
        cm.handle(self)
      end
    end
  end
end

--- @param recv down.Mod.Mod The name of a loaded init that will be the recipient of the event.
--- @return nil
--- @param self down.Event
function Event.send(self, recv)
  self.broadcast = false
  Event.handle(self)
  if recv.subscribed and recv.subscribed[self.split[1]] then
    local evt = recv.subscribed[self.split[1]][self.split[2]]
    if evt ~= nil and evt == true then
      recv.handle(self)
    end
  end
end

return Event
