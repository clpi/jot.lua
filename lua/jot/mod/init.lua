local uv, lu, fn = vim.loop or vim.uv, vim.lsp.util, vim.fn
local cb = require("jot.util.callback")
local config = require("jot.config").config
local log = require("jot.util.log")
local utils = require("jot.util")

_G.Mod = {}

Mod.default_mod = function(name)
  return {
    setup = function()
      ---@type jot.mod.setup
      return {
        success = true,
        requires = {},
        replaces = nil,
        wants = {},
        replace_merge = false,
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
      Map.nmap(",wi", "<CMD>Jot index<CR>")
      Map.nmap(",wp", "<CMD>Jot note template<CR>")
      Map.nmap(",wc", "<CMD>Jot note calendar<CR>")
      Map.nmap(",wn", "<CMD>Jot note index<CR>")
      Map.nmap(",w.", "<CMD>Jot note tomorrow<CR>")
      Map.nmap(",w,", "<CMD>Jot note yesterday<CR>")
      Map.nmap(",wm", "<CMD>Jot note month<CR>")
      Map.nmap(",wt", "<CMD>Jot note today<CR>")
      Map.nmap(",wy", "<CMD>Jot note year<CR>")
    end,
    load = function() end,
    on_event = function() end,
    post_load = function() end,
    name = "config",
    namespace = "jot/" .. name,
    path = "mod.config",
    private = {},
    public = {
      version = require("jot").cfg.version,
    },
    config = {
      private = {},
      public = {},
      custom = {},
    },
    events = {
      subscribed = { -- The events that the init is subscribed to
      },
      defined = { -- The events that the init itself has defined
      },
    },
    required = {},
    import = {},
  }
end
-- local cmd = require("jot.cmd")

--- @param name string The name of the new init. Modake sure this is unique. The recommended naming convention is `category.modn` or `category.subcategory.modn`.
--- @param imports? string[] A list of imports to attach to the init. Import data is requestable via `init.required`. Use paths relative to the current init.
--- @return jot.mod
function _G.Mod.create(name, imports)
  ---@type jot.mod
  local new_mod = Mod.default_mod(name)
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
      new_mod.import[fullpath] = Mod.loaded_mod[fullpath]
    end
  end

  if name then
    new_mod.name = name
    new_mod.path = "mod." .. name
    new_mod.namespace = "jot/" .. name
    vim.api.nvim_create_namespace(new_mod.namespace)
  end
  return new_mod
end

--- Constructs a metainit from a list of submod. Modetamod are mod that can autoload batches of mod at once.
--- @param name string The name of the new metainit. Modake sure this is unique. The recommended naming convention is `category.modn` or `category.subcategory.modn`.
--- @param ... string A list of init names to load.
--- @return jot.mod
_G.Mod.create_meta = function(name, ...)
  ---@type jot.mod
  local m = Mod.create(name)

  m.config.public.enable = { ... }

  m.setup = function()
    return { success = true }
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
--- @type { [string]: jot.mod }
Mod.loaded_mod = {}

--- Loads and enables a init
--- Loads a specified init. If the init subscribes to any events then they will be activated too.
--- @param m jot.mod The actual init to load.
--- @return boolean # Whether the init successfully loaded.
function Mod.load_mod_from_table(m)
  log.info("Loading init with name" .. m.name)

  -- If our init is already loaded don't try loading it again
  if Mod.loaded_mod[m.name] then
    log.trace("mod" .. m.name .. "already loaded. Omitting...")
    return true
  end

  -- Invoke the setup function. This function returns whether or not the loading of the init was successful and some metadata.
  ---@type jot.mod.setup
  local mod_load = m.setup and m.setup()
    or {
      success = true,
      replaces = {},
      replace_merge = false,
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
  if mod_load.success == false then
    log.trace("mod" .. m.name .. "did not load properly.")
    return false
  end

  --[[
      --    This small snippet of code creates a copy of an already loaded init with the same name.
      --    If the init wants to replace an already loaded init then we need to create a deepcopy of that old init
      --    in order to stop it from getting overwritten.
      --]]
  ---@type jot.mod
  local mod_to_replace

  -- If the return value of init.setup() tells us to hotswap with another init then cache the init we want to replace with
  if mod_load.replaces and mod_load.replaces ~= "" then
    mod_to_replace = vim.deepcopy(Mod.loaded_mod[mod_load.replaces])
  end

  -- Add the init into the list of loaded mod
  -- The reason we do this here is so other mod don't recursively require each other in the dependency loading loop below
  Mod.loaded_mod[m.name] = m

  -- If the init "wants" any other mod then verify they are loaded
  if mod_load.wants and not vim.tbl_isempty(mod_load.wants) then
    log.info(
      "mod" .. m.name .. "wants certain mod. Ensuring they are loaded..."
    )

    -- Loop through each dependency and ensure it's loaded
    for _, req_mod in ipairs(mod_load.wants) do
      log.trace("Verifying" .. req_mod)

      -- This would've always returned false had we not added the current init to the loaded init list earlier above
      if not Mod.is_mod_loaded(req_mod) then
        if config.user.mods[req_mod] then
          log.trace(
            "Wanted init"
              .. req_mod
              .. "isn't loaded but can be as it's defined in the user's config. Loading..."
          )

          if not Mod.load_mod(req_mod) then
            require("jot.util.log").error(
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
            ("Unable to load init %s, wanted dependency %s was not satisfied. Be sure to load the init and its appropriate config too!"):format(
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
      m.required[req_mod] = Mod.loaded_mod[req_mod].public
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

      -- This would've always returned false had we not added the current init to the loaded init list earlier above
      if not Mod.is_mod_loaded(req_mod) then
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
      m.required[req_mod] = Mod.loaded_mod[req_mod].public
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
        ("Unable to replace init %s - init replacement clashing detected. This error triggers when a init tries to be replaced more than two times - jot doesn't know which replacement to prioritize."):format(
          mod_to_replace.name
        )
      )

      -- Modake sure to clean up after ourselves if the init failed to load
      Mod.loaded_mod[m.name] = nil

      return false
    end

    -- If the replace_merge flag is set to true in the setup() return value then recursively merge the data from the
    -- previous init into our new one. This allows for practically seamless hotswapping, as it allows you to retain the data
    -- of the previous init.
    if mod_load.replace_merge then
      m = utils.extend(m, {
        private = mod_to_replace.private,
        config = mod_to_replace.config,
        public = mod_to_replace.public,
        events = mod_to_replace.events,
      })
    end

    -- Set the special init.replaced flag to let everyone know we've been hotswapped before
    m.replaced = true
  end

  log.info("Successfully loaded init", m.name)

  -- Keep track of the number of loaded mod
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
  -- vim.notify(msg .. " " .. init.name)

  Mod.broadcast_event({
    type = "mod_loaded",
    split_type = { "mod_loaded" },
    filename = "",
    filehead = "",
    cursor_position = { 0, 0 },
    referrer = "",
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
--- This is the recommended way of loading mod - `load_mod_from_table()` should only really be used by jot itself.
--- @param modn string A path to a init on disk. A path seperator in jot is '.', not '/'.
--- @param cfg table? A config that reflects the structure of `jot.config.user.setup["init.name"].config`.
--- @return boolean # Whether the init was successfully loaded.
function _G.Mod.load_mod(modn, cfg)
  -- Don't bother loading the init from disk if it's already loaded
  if _G.Mod.is_mod_loaded(modn) then
    return true
  end
  local modl = require("jot.mod." .. modn)
  if not modl then
    log.error(
      "Unable to load init"
        .. modn
        .. "- loaded file returned nil. Be sure to return the table created by mod.create() at the end of your init.lua file!"
    )
    return false
  end

  -- If the value of `init` is strictly true then it means the required file returned nothing
  -- We obviously can't do anything meaningful with that!
  if modl == true then
    log.error(
      "An error has occurred when loading"
        .. modn
        .. "- loaded file didn't return anything meaningful. Be sure to return the table created by mod.create() at the end of your init.lua file!"
    )
    return false
  end

  -- Load the user-defined config
  if cfg and not vim.tbl_isempty(cfg) then
    modl.config.custom = cfg
    modl.config.public = utils.extend(modl.config.public, cfg)
  else
    modl.config.custom = config.mods[modn]
    modl.config.public =
      utils.extend(modl.config.public, modl.config.custom or {})
  end

  -- Pass execution onto load_mod_from_table() and let it handle the rest
  return Mod.load_mod_from_table(modl)
end

--- Has the same principle of operation as load_mod_from_table(), except it then sets up the parent init's "required" table, allowing the parent to access the child as if it were a dependency.
--- @param init jot.mod A valid table as returned by mod.create()
--- @param parent_mod string|jot.mod If a string, then the parent is searched for in the loaded mod. If a table, then the init is treated as a valid init as returned by mod.create()
function _G.Mod.load_mod_as_dependency_from_table(init, parent_mod)
  if Mod.load_mod_from_table(init) then
    if type(parent_mod) == "string" then
      Mod.loaded_mod[parent_mod].required[init.name] = init.public
    elseif type(parent_mod) == "table" then
      parent_mod.required[init.name] = init.public
    end
  end
end

--- Normally loads a init, but then sets up the parent init's "required" table, allowing the parent init to access the child as if it were a dependency.
--- @param modn string A path to a init on disk. A path seperator in jot is '.', not '/'
--- @param parent_mod string The name of the parent init. This is the init which the dependency will be attached to.
--- @param cfg? table A config that reflects the structure of jot.config.user.setup["init.name"].config
function _G.Mod.load_mod_as_dependency(modn, parent_mod, cfg)
  if Mod.load_mod(modn, cfg) and Mod.is_mod_loaded(parent_mod) then
    Mod.loaded_mod[parent_mod].required[modn] = Mod.get_mod_config(modn)
  end
end

--- Retrieves the public API exposed by the init.
--- @generic T
--- @param modn `T` The name of the init to retrieve.
--- @return T?
function _G.Mod.get_mod(modn)
  if not Mod.is_mod_loaded(modn) then
    log.trace(
      "Attempt to get init with name",
      modn,
      "failed - init is not loaded."
    )
    return
  end

  return Mod.loaded_mod[modn].public
end

--- Returns the init.config.public table if the init is loaded
--- @param modn string The name of the init to retrieve (init must be loaded)
--- @return table?
function _G.Mod.get_mod_config(modn)
  if not Mod.is_mod_loaded(modn) then
    log.trace(
      "Attempt to get init config with name",
      modn,
      "failed - init is not loaded."
    )
    return
  end

  return Mod.loaded_mod[modn].config.public
end

--- Returns true if init with name modn is loaded, false otherwise
--- @param modn string The name of an arbitrary init
--- @return boolean
function _G.Mod.is_mod_loaded(modn)
  return Mod.loaded_mod[modn] ~= nil
end

--- Reads the init's public table and looks for a version variable, then converts it from a string into a table, like so: `{ major = <number>, minor = <number>, patch = <number> }`.
--- @param modn string The name of a valid, loaded init.
--- @return table? parsed_version
function _G.Mod.get_mod_version(modn)
  -- If the init isn't loaded then don't bother retrieving its version
  if not Mod.is_mod_loaded(modn) then
    log.trace(
      "Attempt to get init version with name",
      modn,
      "failed - init is not loaded."
    )
    return
  end

  -- Grab the version of the init
  local version = Mod.get_mod(modn).version

  -- If it can't be found then error out
  if not version then
    log.trace(
      "Attempt to get init version with name",
      modn,
      "failed - version variable not present."
    )
    return
  end

  return utils.parse_version_string(version)
end

--- Executes `callback` once `init` is a valid and loaded init, else the callback gets instantly executed.
--- @param modn string The name of the init to listen for.
--- @param callback fun(mod_public_table: jot.mod.public) The callback to execute.
function _G.Mod.await(modn, callback)
  if Mod.is_mod_loaded(modn) then
    callback(assert(Mod.get_mod(modn)))
    return
  end

  cb.on_event("mod_loaded", function(_, init)
    callback(init.public)
  end, function(event)
    return event.content.name == modn
  end)
end

--- @alias Mode
--- | "n"
--- | "no"
--- | "nov"
--- | "noV"
--- | "noCTRL-V"
--- | "CTRL-V"
--- | "niI"
--- | "niR"
--- | "niV"
--- | "nt"
--- | "Terminal"
--- | "ntT"
--- | "v"
--- | "vs"
--- | "V"
--- | "Vs"
--- | "CTRL-V"
--- | "CTRL-Vs"
--- | "s"
--- | "S"
--- | "CTRL-S"
--- | "i"
--- | "ic"
--- | "ix"
--- | "R"
--- | "Rc"
--- | "Rx"
--- | "Rv"
--- | "Rvc"
--- | "Rvx"
--- | "c"
--- | "cr"
--- | "cv"
--- | "cvr"
--- | "r"
--- | "rm"
--- | "r?"
--- | "!"
--- | "t"

--- @class (exact) jot.event
--- @field type string The type of the event. Exists in the format of `category.name`.
--- @field split_type string[] The event type, just split on every `.` character, e.g. `{ "category", "name" }`.
--- @field content? table|any The content of the event. The data found here is specific to each individual event. Can be thought of as the payload.
--- @field referrer string The name of the init that triggered the event.
--- @field broadcast boolean Whether the event was broadcast to all mod. `true` is so, `false` if the event was specifically sent to a single recipient.
--- @field cursor_position { [1]: number, [2]: number } The position of the cursor at the moment of broadcasting the event.
--- @field filename string The name of the file that the user was in at the moment of broadcasting the event.
--- @field filehead string The directory the user was in at the moment of broadcasting the event.
--- @field line_content string The content of the line the user was editing at the moment of broadcasting the event.
--- @field buffer number The buffer ID of the buffer the user was in at the moment of broadcasting the event.
--- @field window number The window ID of the window the user was in at the moment of broadcasting the event.
--- @field mode Mode The mode Neovim was in at the moment of broadcasting the event.

-- TODO: What goes below this line until the next notice used to belong to mod
-- We need to find a way to make these functions easier to maintain

--[[
  --    jot EVENT FILE
  --    This file is responsible for dealing with event handling and broadcasting.
  --    All mod that subscribe to an event will receive it once it is triggered.
  --]]

--- The working of this function is best illustrated with an example:
--        If type == 'some_plugin.events.my_event', this function will return { 'some_plugin', 'my_event' }
--- @param type string The full path of a init event
--- @return string[]?
function _G.Mod.split_event_type(type)
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
function _G.Mod.get_event_template(init, type)
  -- You can't get the event template of a type if the type isn't loaded
  if not Mod.is_mod_loaded(init.name) then
    log.info("Unable to get event of type", type, "with init", init.name)
    return
  end

  -- Split the event type into two
  local split_type = Mod.split_event_type(type)

  if not split_type then
    log.warn(
      "Unable to get event template for event",
      type,
      "and init",
      init.name
    )
    return
  end

  log.trace("Returning", split_type[2], "for init", split_type[1])

  -- Return the defined event from the specific init
  return Mod.loaded_mod[init.name].events.defined[split_type[2]]
end

--- Creates a deep copy of the `mod.base_event` event and returns it with a custom type and referrer.
--- @param init jot.mod A reference to the init invoking the function.
--- @param name string A relative path to a valid event template.
--- @return jot.event
function Mod.define_event(init, name)
  -- Create a copy of the base event and override the values with ones specified by the user

  ---@type jot.event
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
function Mod.create_event(init, type, content, ev)
  -- Get the init that contains the event
  local modn = Mod.split_event_type(type)[1]

  -- Retrieve the template from init.events.defined
  local event_template =
    Mod.get_event_template(Mod.loaded_mod[modn] or { name = "" }, type)

  if not event_template then
    log.warn("Unable to create event of type", type, ". Returning nil...")
    return
  end

  -- Modake a deep copy here - we don't want to override the actual base table!
  local new_event = vim.deepcopy(event_template)

  new_event.type = type
  new_event.content = content
  new_event.referrer = init.name

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
function _G.Mod.broadcast_event(event, callback)
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

  for _, current_init in pairs(Mod.loaded_mod) do
    if
      current_init.events.subscribed
      and current_init.events.subscribed[event.split_type[1]]
    then
      local evt =
        current_init.events.subscribed[event.split_type[1]][event.split_type[2]]
      if evt ~= nil and evt == true then
        current_init.on_event(event)
      end
    end
  end
  -- TODO: deprecate
  if callback then
    callback()
  end
end

--- @param recv string The name of a loaded init that will be the recipient of the event.
--- @param ev jot.event An event, usually created by `mod.create_event()`.
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
  if modl.events.subscribed and mod.events.subscribed[ev.split_type[1]] then
    local evt = modl.events.subscribed[event.split_type[1]][ev.split_type[2]]
    if evt ~= nil and evt == true then
      modl.on_event(ev)
    end
  end
end

return Mod
