local uv, lu, fn = vim.loop or vim.uv, vim.lsp.util, vim.fn
local cb = require("word.util.event.callback")
local config = require("word.config").config
local log = require("word.util.log")
local utils = require("word.util")

-- TODO: remove global

---@class word.Mod
Mod = setmetatable({}, {
  __index = Mod,
  ---@param self word.Mod
  ---@param other word.Mod
  __eq = function(self, other)
    return self.name == other.name
  end,
  ---@param self word.Mod
  __tostring = function(self)
    return self.name
  end,
})

Mod.default = function(name)
  return {
    setup = function()
      ---@type word.mod.Setup
      return {
        loaded = true,
        requires = {},
        replaces = nil,
        wants = {},
        merge = false,
      }
    end,
    -- NOTE: remove pluralism
    cmds = function() end,
    opts = function()
      vim.cmd([[
      set conceallevel=2
      set concealcursor=nv
    ]])
    end,
    maps = function()
      -- TODO: obviously inefficient
      local Map = require("word.util.maps")
      Map.nmap(",wi", "<CMD>Word index<CR>")
      Map.nmap(",wp", "<CMD>Word note template<CR>")
      Map.nmap(",wc", "<CMD>Word note calendar<CR>")
      Map.nmap(",wn", "<CMD>Word note index<CR>")
      Map.nmap(",w.", "<CMD>Word note tomorrow<CR>")
      Map.nmap(",w,", "<CMD>Word note yesterday<CR>")
      Map.nmap(",wm", "<CMD>Word note month<CR>")
      Map.nmap(",wt", "<CMD>Word note today<CR>")
      Map.nmap(",wy", "<CMD>Word note year<CR>")
    end,
    load = function() end,
    on = function() end,
    post_load = function() end,
    name = "config",
    namespace = "word." .. name,
    path = "mod.config",
    version = require("word").config.version,
    data = {
      --TODO: remove
      data = {},
    },
    config = {
      private = {},
      custom = {},
      public = {},
    },
    events = {
      subscribed = { -- The events that the init is subscribed to
      },
      defined = {    -- The events that the init itself has defined
      },
    },
    required = {},
    import = {},
  }
end
-- local cmd = require("word.cmd")

--- @param name string The name of the new init. Modake sure this is unique. The recommended naming convention is `category.modn` or `category.subcategory.modn`.
--- @param imports? string[] A list of imports to attach to the init. Import data is requestable via `init.required`. Use paths relative to the current init.
--- @return word.Mod
function Mod.create(name, imports)
  ---@type word.Mod
  local new = Mod.default(name)
  if imports then
    for _, imp in ipairs(imports) do
      local fullpath = table.concat({ name, imp }, ".")
      if not Mod.load_mod(fullpath) then
        log.error(
          "Unable to load import '"
          .. fullpath
          .. "'! An error  (see traceback below):"
        )
        assert(false)
      end
      new.import[fullpath] = Mod.loaded_mod[fullpath]
    end
  end

  if name then
    new.name = name
    new.path = "mod." .. name
    new.namespace = "word.mod." .. name
    vim.api.nvim_create_namespace(new.namespace)
  end
  return new
end

--- Constructs a default array of modules
--- @param name string The name of the new metainit. Modake sure this is unique. The recommended naming convention is `category.modn` or `category.subcategory.modn`.
--- @param ... string A list of init names to load.
--- @return word.Mod
Mod.modules = function(name, ...)
  ---@type word.Mod
  local m = Mod.create(name)

  m.config.public.enable = { ... }
  -- print(ms[0])
  -- print(m.config.enable[0])

  m.setup = function()
    return { loaded = true }
  end
  if m.cmds then
    m.cmds()
  end
  if m.opts then
    m.opts()
  end
  if m.maps then
    m.maps()
  end

  m.load = function()
    m.config.public.enable = (function()
      if not m.config.public.disable then
        return m.config.public.enable
      end
      --
      local ret = {}

      for _, mname in ipairs(m.config.public.enable) do
        if not vim.tbl_contains(m.config.public.disable, mname) then
          table.insert(ret, mname)
        end
      end

      return ret
    end)()

    for _, mname in ipairs(m.config.public.enable) do
      Mod.load_mod(mname)
    end
  end
  return m
end

-- TODO: What goes below this line until the next notice used to belong to mod
-- We need to find a way to make these functions easier to maintain

--- Tracks the amount of currently loaded mod.
Mod.loaded_mod_count = 0

--- The table of currently loaded mod
--- @type { [string]: word.Mod }
Mod.loaded_mod = {}

--- Loads and enables a init
--- Loads a specified init. If the init subscribes to any events then they will be activated too.
--- @param m word.Mod The actual init to load.
--- @return boolean # Whether the init successfully loaded.
function Mod.load_mod_from_table(m)
  log.info("Loading init with name" .. m.name)

  -- If our init is already loaded don't try loading it again
  if Mod.loaded_mod[m.name] then
    log.trace("mod" .. m.name .. "already loaded. Omitting...")
    return true
  end

  -- Invoke the setup function. This function returns whether or not the loading of the init was successful and some metadata.
  ---@type word.mod.Setup
  local mod_load = m.setup and m.setup()
      or {
        loaded = true,
        replaces = {},
        merge = false,
        requires = {},
        wants = {},
      }

  -- We do not expect init.setup() to ever return nil, that's why this check is in place
  if not mod_load then
    log.error(
      "init"
      .. m.name
      .. "does not handle init loading correctly; init.setup() returned nil. Omitting..."
    )
    return false
  end

  -- A part of the table returned by init.setup() tells us whether or not the init initialization was successful
  if mod_load.loaded == false then
    log.trace("mod" .. m.name .. "did not load properly.")
    return false
  end

  local mod_to_replace

  if mod_load.replaces and mod_load.replaces ~= "" then
    mod_to_replace = vim.deepcopy(Mod.loaded_mod[mod_load.replaces])
  end

  Mod.loaded_mod[m.name] = m

  if mod_load.wants and not vim.tbl_isempty(mod_load.wants) then
    log.info(
      "mod" .. m.name .. "wants certain mod. Ensuring they are loaded..."
    )

    -- Loop through each dependency and ensure it's loaded
    for _, req_mod in ipairs(mod_load.wants) do
      log.trace("Verifying" .. req_mod)

      if not Mod.is_mod_loaded(req_mod) then
        if config.user.mod[req_mod] then
          log.trace(
            "Wanted init"
            .. req_mod
            .. "isn't loaded but can be as it's defined in the user's config. Loading..."
          )

          if not Mod.load_mod(req_mod) then
            require("word.util.log").error(
              "Unable to load wanted init for"
              .. m.name
              .. "- the init didn't load successfully"
            )

            -- Modake sure to clean up after ourselves if the init failed to load
            Mod.loaded_mod[m.name] = nil
            return false
          end
        else
          log.error(
            ("Unable to load init %s, wanted dependency %s was not satisfied. Be sure to load the init and its appropriate config too!")
            :format(
              m.name,
              req_mod
            )
          )

          -- Modake sure to clean up after ourselves if the init failed to load
          Mod.loaded_mod[m.name] = nil
          return false
        end
      end

      -- Create a reference to the dependency's public table
      m.required[req_mod] = Mod.loaded_mod[req_mod].data
    end
  end

  -- If any dependencies have been defined, handle them
  if mod_load.requires and vim.tbl_count(mod_load.requires) > 0 then
    log.info(
      "mod" .. m.name .. "has dependencies. Loading dependencies first..."
    )

    -- Loop through each dependency and load it one by one
    for _, req_mod in pairs(mod_load.requires) do
      log.trace("Loading submod" .. req_mod)

      if not Mod.is_mod_loaded(req_mod) then
        -- print(req_mod)
        if not Mod.load_mod(req_mod) then
          log.error(
            ("Unable to load init %s, required dependency %s did not load successfully"):format(
              m.name,
              req_mod
            )
          )

          -- Modake sure to clean up after ourselves if the init failed to load
          Mod.loaded_mod[m.name] = nil
          return false
        end
      else
        log.trace("mod" .. req_mod .. "already loaded, skipping...")
      end

      -- Create a reference to the dependency's public table
      m.required[req_mod] = Mod.loaded_mod[req_mod].data
    end
  end

  -- After loading all our dependencies, see if we need to hotswap another init with ourselves
  if mod_to_replace then
    -- Modake sure the names of both mod match
    m.name = mod_to_replace.name

    -- Whenever a init gets hotswapped, a special flag is set inside the init in order to signalize that it has been hotswapped before
    -- If this flag has already been set before, then throw an error - there is no way for us to know which hotswapped init should take priority.
    if mod_to_replace.replaced then
      log.error(
        ("Unable to replace init %s - init replacement clashing detected. This error triggers when a init tries to be replaced more than two times - word doesn't know which replacement to prioritize.")
        :format(
          mod_to_replace.name
        )
      )

      -- Modake sure to clean up after ourselves if the init failed to load
      Mod.loaded_mod[m.name] = nil

      return false
    end

    -- If the merge flag is set to true in the setup() return value then recursively merge the data from the
    -- previous init into our new one. This allows for practically seamless hotswapping, as it allows you to retain the data
    -- of the previous init.
    if mod_load.merge then
      m = utils.extend(m, {
        config = mod_to_replace.config,
        data = mod_to_replace.data,
        events = mod_to_replace.events,
      })
    end

    m.replaced = true
  end

  log.info("Successfully loaded init" .. m.name)

  Mod.loaded_mod_count = Mod.loaded_mod_count + 1

  if m.cmds then
    m.cmds()
  end
  if m.opts then
    m.opts()
  end
  if m.maps then
    m.maps()
  end
  if m.load then
    m.load()
  end

  -- local msg = ("%fms"):format((vim.loop.hrtime() - start) / 1e6)
  -- vim.notify(msg.." "..init.name)

  Mod.broadcast({
    type = "mod_loaded",
    split_type = { "mod_loaded" },
    filename = "",
    filehead = "",
    cursor_position = { 0, 0 },
    referrer = m.name,
    line_content = "",
    content = m,
    payload = m,
    topic = "mod_loaded",
    broadcast = true,
    buffer = vim.api.nvim_get_current_buf(),
    window = vim.api.nvim_get_current_win(),
    mode = vim.fn.mode(),
  })

  return true
end

--- Unlike `load_mod_from_table()`, which loads a init from memory, `load_mod()` tries to find the corresponding init file on disk and loads it into memory.
--- If the init cannot not be found, attempt to load it off of github (unimplemented). This function also applies user-defined config and keys to the mod themselves.
--- This is the recommended way of loading mod - `load_mod_from_table()` should only really be used by word itself.
--- @param modn string A path to a init on disk. A path in word is '.', not '/'.
--- @param cfg table? A config that reflects the structure of `word.config.user.setup["init.name"].config`.
--- @return boolean # Whether the init was successfully loaded.
function Mod.load_mod(modn, cfg)
  if Mod.is_mod_loaded(modn) then
    return true
  end
  local modl = require("word.mod." .. modn)
  if not modl then
    log.error(
      "Unable to load init"
      .. modn
      .. "- loaded file returned nil. Be sure to return the table created by mod.create() at the end of your init.lua file!"
    )
    return false
  end

  if modl == true then
    log.error(
      "An error has occurred when loading"
      .. modn
      ..
      "- loaded file didn't return anything meaningful. Be sure to return the table created by mod.create() at the end of your init.lua file!"
    )
    return false
  end

  -- modl.config = {}
  if cfg and not vim.tbl_isempty(cfg) then
    modl.config.custom = cfg
    modl.config.public = utils.extend(modl.config.public, cfg)
  else
    -- print(modl.config.custom, modl.config.public, config.mod[modn])
    modl.config.custom = config.mod[modn]
    modl.config.public =
    -- vim.tbl_extend("force", modl.config.public, modl.config.custom or {})
        utils.extend(modl.config.public, modl.config.custom or {})
  end

  -- Pass execution onto load_mod_from_table() and let it handle the rest
  return Mod.load_mod_from_table(modl)
end

--- Has the same principle of operation as load_mod_from_table(), except it then sets up the parent init's "required" table, allowing the parent to access the child as if it were a dependency.
--- @param md word.Mod A valid table as returned by mod.create()
--- @param parent_mod string|word.Mod If a string, then the parent is searched for in the loaded mod. If a table, then the init is treated as a valid init as returned by mod.create()
function Mod.load_mod_as_dependency_from_table(md, parent_mod)
  if Mod.load_mod_from_table(md) then
    if type(parent_mod) == "string" then
      Mod.loaded_mod[parent_mod].required[md.name] = md.data
    elseif type(parent_mod) == "table" then
      parent_mod.required[md.name] = md.data
    end
  end
end

--- Normally loads a init, but then sets up the parent init's "required" table, allowing the parent init to access the child as if it were a dependency.
--- @param modn string A path to a init on disk. A path  in word is '.', not '/'
--- @param parent_mod string The name of the parent init. This is the init which the dependency will be attached to.
--- @param cfg? table A config that reflects the structure of word.config.user.setup["init.name"].config
function Mod.load_mod_as_dependency(modn, parent_mod, cfg)
  if Mod.load_mod(modn, cfg) and Mod.is_mod_loaded(parent_mod) then
    Mod.loaded_mod[parent_mod].required[modn] = Mod.get_mod_config(modn)
  end
end

--- Retrieves the public API exposed by the init.
--- @generic T
--- @param modn `T` The name of the init to retrieve.
--- @return T?
function Mod.get_mod(modn)
  if not Mod.is_mod_loaded(modn) then
    log.trace(
      "Attempt to get init with name" .. modn .. "failed - init is not loaded."
    )
    return
  end

  return Mod.loaded_mod[modn].data
end

--- Returns the init.config table if the init is loaded
--- @param modn string The name of the init to retrieve (init must be loaded)
--- @return table?
function Mod.get_mod_config(modn)
  if not Mod.is_mod_loaded(modn) then
    log.trace(
      "Attempt to get init config with name"
      .. modn
      .. "failed - init is not loaded."
    )
    return
  end

  return Mod.loaded_mod[modn].config.public
end

--- Returns true if init with name modn is loaded, false otherwise
--- @param modn string The name of an arbitrary init
--- @return boolean
function Mod.is_mod_loaded(modn)
  return Mod.loaded_mod[modn] ~= nil
end

--- Reads the init's data table and looks for a version variable, then converts it from a string into a table, like so: `{ major = <number>, minor = <number>, patch = <number> }`.
--- @param modn string The name of a valid, loaded init.
--- @return table? parsed_version
function Mod.get_mod_version(modn)
  -- If the init isn't loaded then don't bother retrieving its version
  if not Mod.is_mod_loaded(modn) then
    log.trace(
      "Attempt to get init version with name"
      .. modn
      .. "failed - init is not loaded."
    )
    return
  end

  -- Grab the version of the init
  local version = Mod.get_mod(modn).version

  -- If it can't be found then error out
  if not version then
    log.trace(
      "Attempt to get init version with name"
      .. modn
      .. "failed - version variable not present."
    )
    return
  end

  return utils.parse_version_string(version)
end

--- Executes `callback` once `init` is a valid and loaded init, else the callback gets instantly executed.
--- @param modn string The name of the init to listen for.
--- @param callback fun(mod_public_table: table
function Mod.await(modn, callback)
  if Mod.is_mod_loaded(modn) then
    callback(assert(Mod.get_mod(modn)))
    return
  end

  cb.on("mod_loaded", function(_, m)
    callback(m.data)
  end, function(event)
    return event.content.name == modn
  end)
end

--- @param type string The full path of a init event
--- @return string[]?
function Mod.split_event_type(type)
  local start_str, end_str = type:find("%.events%.")

  local split_event_type = { type:sub(0, start_str - 1), type:sub(end_str + 1) }

  if #split_event_type ~= 2 then
    log.warn("Invalid type name:", type)
    return
  end

  return split_event_type
end

--- Returns an event template defined in `init.events.defined`.
--- @param m word.Mod A reference to the init invoking the function
--- @param type string A full path to a valid event type (e.g. `init.events.some_event`)
--- @return word.Event?
function Mod.get_event_template(m, type)
  -- You can't get the event template of a type if the type isn't loaded
  if not Mod.is_mod_loaded(m.name) then
    log.info("Unable to get event of type" .. type .. "with init", m.name)
    return
  end

  local split_type = Mod.split_event_type(type)

  if not split_type then
    log.warn(
      "Unable to get event template for event" .. type .. "and init" .. m.name
    )
    return
  end

  log.trace("Returning" .. split_type[2] .. "for init" .. split_type[1])

  -- Return the defined event from the specific init
  return Mod.loaded_mod[m.name].events.defined[split_type[2]]
end

--- Creates a deep copy of the `mod.base_event` event and returns it with a custom type and referrer.
--- @param m word.Mod A reference to the init invoking the function.
--- @param name string A relative path to a valid event template.
--- @return word.Event
function Mod.define_event(m, name)
  -- Create a copy of the base event and override the values with ones specified by the user

  ---@type word.Event
  local new_event = {
    payload = nil,
    topic = "base_event",
    type = "base_event",
    split_type = {},
    content = nil,
    referrer = "config",
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
    new_event.type = m.name .. ".events." .. name
  end
  new_event.referrer = m.name
  return new_event
end

--- Returns a copy of the event template provided by a init.
--- @param init word.Mod A reference to the init invoking the function
--- @param type string A full path to a valid .vent type (e.g. `init.events.some_event`)
--- @param content table|any? The content of the event, can be anything from a string to a table to whatever you please.
--- @param ev? table The original event data.
--- @return word.Event? # New event.
function Mod.create_event(m, type, content, ev)
  -- Get the init that contains the event
  local modn = Mod.split_event_type(type)[1]

  -- Retrieve the template from init.events.defined
  local event_template =
      Mod.get_event_template(Mod.loaded_mod[modn] or { name = "" }, type)

  if not event_template then
    log.warn("Unable to create event of type" .. type .. ". Returning nil...")
    return
  end

  -- Modake a deep copy here - we don't want to override the actual base table!
  local new_event = vim.deepcopy(event_template)

  new_event.type = type
  new_event.content = content
  new_event.referrer = m.name

  -- Override all the important values
  new_event.split_type = assert(Mod.split_event_type(type))
  new_event.filename = vim.fn.expand("%:t") --[[@as string]]
  new_event.filehead = vim.fn.expand("%:p:h") --[[@as string]]
  local bufid = ev and ev.buf or vim.api.nvim_get_current_buf()
  local winid = assert(vim.fn.bufwinid(bufid))
  if winid == -1 then
    winid = vim.api.nvim_get_current_win()
  end
  new_event.cursor_position = vim.api.nvim_win_get_cursor(winid)
  local row_1b = new_event.cursor_position[1]
  new_event.line_content =
      vim.api.nvim_buf_get_lines(bufid, row_1b - 1, row_1b, true)[1]
  new_event.referrer = m.name
  new_event.broadcast = true
  new_event.buffer = bufid
  new_event.window = winid
  new_event.mode = vim.api.nvim_get_mode().mode

  return new_event
end

--- Sends an event to all subscribed mod. The event contains the filename, filehead, cursor position and line content as a bonus.
--- @param event word.Event An event, usually created by `mod.create_event()`.
--- @param callback function? A callback to be invoked after all events have been asynchronously broadcast
function Mod.broadcast(event, callback)
  -- Broadcast the event to all mod
  if not event.split_type then
    log.error(
      "Unable to broadcast event of type"
      .. event.type
      .. "- invalid event name"
    )
    return
  end

  cb.handle(event)

  for _, cm in pairs(Mod.loaded_mod) do
    if cm.events.subscribed and cm.events.subscribed[event.split_type[1]] then
      local evt = cm.events.subscribed[event.split_type[1]][event.split_type[2]]
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
--- @param ev word.Event An event, usually created by `mod.create_event()`.
--- @return nil
function Mod.send_event(recv, ev)
  if not Mod.is_mod_loaded(recv) then
    log.warn(
      "Unable to send event to init" .. recv .. "- the init is not loaded."
    )
    return
  end
  ev.broadcast = false
  cb.handle(ev)
  local modl = Mod.loaded_mod[recv]
  if modl.events.subscribed and modl.events.subscribed[ev.split_type[1]] then
    local evt = modl.events.subscribed[ev.split_type[1]][ev.split_type[2]]
    if evt ~= nil and evt == true then
      modl.on(ev)
    end
  end
end

return Mod
