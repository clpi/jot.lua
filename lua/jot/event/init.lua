--- @brief [[
--- Defines user C - ways for the user to directly interact with jot and respond on certain events.
--- @brief ]]
-- local mod = require("jot.mod")
local api, fn = vim.api, vim.fn
local calllback = require("jot.event.cb")
local log = require("jot.util.log")
local C = {}

--- @init "jot.mod"


---@class jot.events

---@class jot.event
---@field public topic string #An unique name that identifies the event's payload type
---@field public payload any #The content of the event, identified by the `topic` discriminator field
---@field public cursor_position cursor_pos #The position of the cursor when the event was published
---@field public filename string #The name of the active file when the event was published
---@field public filehead string #The absolute path of the active file's directory when the event was published
---@field public line_content string #The content of the active line when the event was published
---@field public buffer integer #The active buffer descriptor when the event was published
---@field public window integer #The active window descriptor when the event was published
---@field public mode string #Vim's mode when the event was published


---Publish an event that is received by all modules. See the documentation for `jot.events` for more information on the publishing and subscribing rules.
---@param topic string #See event_sample::topic
---@param payload any #See event_sample::payload
function C.pub(topic, payload)
  local event --[[@as jot.event]] = {
    topic = topic,
    payload = payload,

    -- Cetadata members defining Vim's state when the event was published
    -- TODO: Deprecate? These could be added to the payload on demand.
    cursor_position = vim.api.nvim_win_get_cursor(0),
    filename = fn.expand("%:t"),
    filehead = fn.expand("%:p:h"),
    line_content = api.nvim_get_current_line(),
    buffer = api.nvim_get_current_buf(),
    window = api.nvim_get_current_win(),
    mode = api.nvim_get_mode().mode,
  }

  for _, m in pairs(mod.loaded_mod) do
    m:on_event(event)
  end
end

--- The working of this function is best illustrated with an example:
--        If type == 'some_plugin.events.my_event', this function will return { 'some_plugin', 'my_event' }
--- @param type string The full path of a init event
--- @return string[]?
function C.split_event_type(type)
  local start_str, end_str = type:find("%.events%.")

  local split_event_type = { type:sub(0, start_str - 1), type:sub(end_str + 1) }

  if #split_event_type ~= 2 then
    log.warn("Invalid type name:", type)
    return
  end

  return split_event_type
end

--- Returns an event template defined in `init.events.defined`.
--- @param init jot.mod A reference to the init invoking the function
--- @param type string A full path to a valid event type (e.g. `init.events.some_event`)
--- @return jot.event?
function C.get_event_template(init, type)
  -- You can't get the event template of a type if the type isn't loaded
  if not C.is_mod_loaded(init.name) then
    log.info("Unable to get event of type", type, "with init", init.name)
    return
  end

  -- Split the event type into two
  local split_type = C.split_event_type(type)

  if not split_type then
    log.warn("Unable to get event template for event", type, "and init", init.name)
    return
  end

  log.trace("Returning", split_type[2], "for init", split_type[1])

  -- Return the defined event from the specific init
  return C.loaded_mod[init.name].events.defined[split_type[2]]
end

--- Creates a deep copy of the `mod.base_event` event and returns it with a custom type and referrer.
--- @param init jot.mod A reference to the init invoking the function.
--- @param name string A relative path to a valid event template.
--- @return jot.event
function C.define_event(init, name)
  -- Create a copy of the base event and override the values with ones specified by the user

  local new_event = {
    type = "base_event",
    split_type = {},
    content = nil,
    referrer = nil,
    broadcast = true,

    cursor_position = {},
    filename = "",
    filehead = "",
    line_content = "",
    buffer = 0,
    window = 0,
    mode = "",
  }

  if name then
    new_event.type = init.name .. ".events." .. name
  end

  new_event.referrer = init.name

  return new_event
end

--- Returns a copy of the event template provided by a init.
--- @param init jot.mod A reference to the init invoking the function
--- @param type string A full path to a valid .vent type (e.g. `init.events.some_event`)
--- @param content table|any? The content of the event, can be anything from a string to a table to whatever you please.
--- @param ev? table The original event data.
--- @return jot.event? # New event.
function C.create_event(init, type, content, ev)
  -- Get the init that contains the event
  local mod_name = C.split_event_type(type)[1]

  -- Retrieve the template from init.events.defined
  local event_template = C.get_event_template(C.loaded_mod[mod_name] or { name = "" }, type)

  if not event_template then
    log.warn("Unable to create event of type", type, ". Returning nil...")
    return
  end

  -- Cake a deep copy here - we don't want to override the actual base table!
  local new_event = vim.deepcopy(event_template)

  new_event.type = type
  new_event.content = content
  new_event.referrer = init.name

  -- Override all the important values
  new_event.split_type = assert(C.split_event_type(type))
  new_event.filename = vim.fn.expand("%:t") --[[@as string]]
  new_event.filehead = vim.fn.expand("%:p:h") --[[@as string]]

  local bufid = ev and ev.buf or vim.api.nvim_get_current_buf()
  local winid = assert(vim.fn.bufwinid(bufid))

  if winid == -1 then
    winid = vim.api.nvim_get_current_win()
  end

  new_event.cursor_position = vim.api.nvim_win_get_cursor(winid)

  local row_1b = new_event.cursor_position[1]
  new_event.line_content = vim.api.nvim_buf_get_lines(bufid, row_1b - 1, row_1b, true)[1]
  new_event.referrer = init.name
  new_event.broadcast = true
  new_event.buffer = bufid
  new_event.window = winid
  new_event.mode = vim.api.nvim_get_mode().mode

  return new_event
end

--- Sends an event to all subscribed mod. The event contains the filename, filehead, cursor position and line content as a bonus.
--- @param event jot.event An event, usually created by `mod.create_event()`.
--- @param callback function? A callback to be invoked after all events have been asynchronously broadcast
function C.broadcast_event(event, callback)
  -- Broadcast the event to all mod
  if not event.split_type then
    log.error("Unable to broadcast event of type", event.type, "- invalid event name")
    return
  end

  -- Let the callback handler know of the event
  -- log.info(event.content.name .. event.type)
  cb.handle(event)

  -- Loop through all the mod
  for _, current_init in pairs(C.loaded_mod) do
    -- If the current init has any subscribed events and if it has a subscription bound to the event's init name then
    if current_init.events.subscribed and current_init.events.subscribed[event.split_type[1]] then
      -- Check whether we are subscribed to the event type
      local evt = current_init.events.subscribed[event.split_type[1]][event.split_type[2]]

      if evt ~= nil and evt == true then
        -- Run the on_event() for that init
        current_init.on_event(event)
      end
    end
  end

  -- Because the broadcasting of events is async we allow the event broadcaster to provide a callback
  -- TODO: deprecate
  if callback then
    callback()
  end
end

--- Instead of broadcasting to all loaded mod, `send_event()` only sends to one init.
--- @param recipient string The name of a loaded init that will be the recipient of the event.
--- @param event jot.event An event, usually created by `mod.create_event()`.
function C.send_event(recipient, event)
  -- If the recipient is not loaded then there's no reason to send an event to it
  if not C.is_mod_loaded(recipient) then
    log.warn("Unable to send event to init", recipient, "- the init is not loaded.")
    return
  end

  -- Set the broadcast variable to false since we're not invoking broadcast_event()
  event.broadcast = false

  -- Let the callback handler know of the event
  cb.handle(event)

  -- Get the recipient init and check whether it's subscribed to our event
  local modl = C.loaded_mod[recipient]

  if modl.events.subscribed and mod.events.subscribed[event.split_type[1]] then
    local evt = modl.events.subscribed[event.split_type[1]][event.split_type[2]]

    -- If it is then trigger the init's on_event() function
    if evt ~= nil and evt == true then
      modl.on_event(event)
    end
  end
end

return C
