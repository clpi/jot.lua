--[[
    file: vault
    title: The Most Critical Component of any Organized Workflow
    description: The `vault` init handles different collections of notes in separate directories.
    summary: This init is be responsible for managing directories full of .word files.
    ---
`default.vault` provides other mod the ability to see which directories the user is in, where
each note collection is stored and how to interact with it.

When writing notes, it is often crucial to have notes on a certain topic be isolated from notes on another topic.
vault achieves this with a concept of "vaults", which are named directories full of `.word` notes.

To use `default.vault`, simply load up the init in your configuration and specify the directories you would like to be managed for you:

```lua
require('word').setup {
    load = {
        ["default"] = {},
        ["vault"] = {
            config = {
                vaults = {
                    my_ws = "~/word", -- Format: <name_of_vault> = <path_to_vault_root>
                    my_other_notes = "~/work/notes",
                },
                index = "index.word", -- The name of the main (root) .word file
            }
        }
    }
}
```

To query the current vault, run `:word vault`. To set the vault, run `:word vault <vault_name>`.

### Changing the Current Working Directory
After a recent update `default.vault` will no longer change the current working directory after switching
vault. To get the best experience it's recommended to set the `autochdir` Neovim option.


### Create a new note (in lua)
You can use vault to create new notes in your vaults.

```lua
local vault = require('word').mod.get_mod("vault")
vault.create_file("my_file", "my_ws", {
    no_open  = false,  -- open file after creation?
    force    = false,  -- overwrite file if exists
    metadata = {}      -- key-value table for metadata fields
})
```

## keys

This init exposes the following keys (see [`default.keys`](@default.keys) for instructions on
mapping them):

- `word.vault.new-note` - Create a new note in the current vault, prompt for name

--]]

local Path = require("pathlib")

local word = require("word")
local log, mod, utils = word.log, word.mod, word.utils
local vault_utils

local init = mod.create("vault")

init.setup = function()
  return {
    success = true,
    requires = { "ui", "store", "vault.utils" },
  }
end

init.load = function()
  -- Go through every vault and expand special symbols like ~
  for name, vault_location in pairs(init.config.public.vaults) do
    -- init.config.public.vaults[name] = vim.fn.expand(vim.fn.fnameescape(vault_location)) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
    init.config.public.vaults[name] = Path(vault_location):resolve():to_absolute()
  end

  vault_utils = init.required["vault.utils"]

  -- vim.keymap.set("<c-\\><c-\\>", "<Plug>(word.vault.new-note)", init.public.new_note)

  -- Used to detect when we've entered a buffer with a potentially different cwd

  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      index = {
        args = 0,
        name = "vault.index",
      },
    })
  end)

  -- Synchronize default.cmd autocompletions
  init.public.sync()

  if init.config.public.open_last_vault and vim.fn.argc(-1) == 0 then
    if init.config.public.open_last_vault == "default" then
      if not init.config.public.default_vault then
        log.warn(
          'Configuration error in `default.vault`: the `open_last_vault` option is set to "default", but no default vault is provided in the `default_vault` configuration variable. defaulting to opening the last known vault.'
        )
        init.public.set_last_vault()
        return
      end

      init.public.open_vault(init.config.public.default_vault)
    else
      init.public.set_last_vault()
    end
  elseif init.config.public.default_vault then
    init.public.set_vault(init.config.public.default_vault)
  end
end

init.config.public = {
  -- The list of active word vaults.
  --
  -- There is always an inbuilt vault called `default`, whose location is
  -- set to the Neovim current working directory on boot.
  ---@type table<string, PathlibPath>
  vaults = {
    default = require("pathlib").cwd(),
  },
  -- The name for the index file.
  --
  -- The index file is the "entry point" for all of your notes.
  index = "index.md",
  -- The default vault to set whenever Neovim starts.
  default_vault = nil,
  -- Whether to open the last vault's index file when `nvim` is executed
  -- without arguments.
  --
  -- May also be set to the string `"default"`, due to which word will always
  -- open up the index file for the vault defined in `default_vault`.
  open_last_vault = false,
  -- Whether to use default.ui.text_popup for `vault.new.note` event.
  -- if `false`, will use vim's default `vim.ui.input` instead.
  use_popup = true,
}

init.private = {
  ---@type { [1]: string, [2]: PathlibPath }
  current_vault = { "default", Path.cwd() },
}

---@class default.vault
init.public = {
  get_vaults = function()
    return init.config.public.vaults
  end,
  ---@return string[]
  get_vault_names = function()
    return vim.tbl_keys(init.config.public.vaults)
  end,
  --- If present retrieve a vault's path by its name, else returns nil
  ---@param name string #The name of the vault
  get_vault = function(name)
    return init.config.public.vaults[name]
  end,
  --- Returns a table in the format { "vault_name", "path" }
  get_current_vault = function()
    return init.private.current_vault
  end,
  --- Sets the vault to the one specified (if it exists) and broadcasts the vault_changed event
  ---@param ws_name string #The name of a valid namespace we want to switch to
  ---@return boolean #True if the vault is set correctly, false otherwise
  set_vault = function(ws_name)
    -- Grab the vault location
    local vault = init.config.public.vaults[ws_name]
    -- Create a new object describing our new vault
    local new_vault = { ws_name, vault }

    -- If the vault does not exist then error out
    if not vault then
      log.warn("Unable to set vault to", vault, "- that vault does not exist")
      return false
    end

    -- Create the vault directory if not already present
    vault:mkdir(Path.const.o755, true)

    -- Cache the current vault
    local current_ws = vim.deepcopy(init.private.current_vault)

    -- Set the current vault to the new vault object we constructed
    init.private.current_vault = new_vault

    if ws_name ~= "default" then
      init.required["store"].store("last_vault", ws_name)
    end

    -- Broadcast the vault_changed event with all the necessary information
    mod.broadcast_event(
      assert(
        mod.create_event(
          init,
          "vault.events.vault_changed",
          { old = current_ws, new = new_vault }
        )
      )
    )

    return true
  end,
  --- Dynamically defines a new vault if the name isn't already occupied and broadcasts the vault_added event
  ---@return boolean True if the vault is added successfully, false otherwise
  ---@param vault_name string #The unique name of the new vault
  ---@param vault_path string|PathlibPath #A full path to the vault root
  add_vault = function(vault_name, vault_path)
    -- If the init already exists then bail
    if init.config.public.vaults[vault_name] then
      return false
    end

    vault_path = Path(vault_path):resolve():to_absolute()
    -- Set the new vault and its path accordingly
    init.config.public.vaults[vault_name] = vault_path
    -- Broadcast the vault_added event with the newly added vault as the content
    mod.broadcast_event(
      assert(
        mod.create_event(init, "vault.events.vault_added", { vault_name, vault_path })
      )
    )

    -- Sync autocompletions so the user can see the new vault
    init.public.sync()

    return true
  end,
  --- If the file we opened is within a vault directory, returns the name of the vault, else returns nil
  get_vault_match = function()
    -- Cache the current working directory
    init.config.public.vaults.default = Path.cwd()

    local file = Path(vim.fn.expand("%:p"))

    -- Name of matching vault. Falls back to "default"
    local ws_name = "default"

    -- Store the depth of the longest match
    local longest_match = 0

    -- Find a matching vault
    for vault, location in pairs(init.config.public.vaults) do
      if vault ~= "default" then
        if file:is_relative_to(location) and location:depth() > longest_match then
          ws_name = vault
          longest_match = location:depth()
        end
      end
    end

    return ws_name
  end,
  --- Uses the `get_vault_match()` function to determine the root of the vault defaultd on the
  --- current working directory, then changes into that vault
  set_closest_vault_match = function()
    -- Get the closest vault match
    local ws_match = init.public.get_vault_match()

    -- If that match exists then set the vault to it!
    if ws_match then
      init.public.set_vault(ws_match)
    else
      -- Otherwise try to reset the vault to the default
      init.public.set_vault("default")
    end
  end,
  --- Updates completions for the :word command
  sync = function()
    -- Get all the vault names
    local vault_names = init.public.get_vault_names()

    -- Add the command to default.cmd so it can be used by the user!
    mod.await("cmd", function(cmd)
      cmd.add_commands_from_table({
        vault = {
          max_args = 1,
          name = "vault.vault",
          complete = { vault_names },
        },
      })
    end)
  end,

  ---@class default.vault.create_file_opts
  ---@field no_open? boolean do not open the file after creation?
  ---@field force? boolean overwrite file if it already exists?
  ---@field metadata? default.esupports.metagen.metadata metadata fields, if provided inserts metadata - an empty table uses default values

  --- Takes in a path (can include directories) and creates a .word file from that path
  ---@param path string|PathlibPath a path to place the .word file in
  ---@param vault? string vault name
  ---@param opts? default.vault.create_file_opts additional options
  create_file = function(path, vault, opts)
    opts = opts or {}

    -- Grab the current vault's full path
    local fullpath

    if vault ~= nil then
      fullpath = init.public.get_vault(vault)
    else
      fullpath = init.public.get_current_vault()[2]
    end

    if fullpath == nil then
      log.error("Error in fetching vault path")
      return
    end

    local destination = (fullpath / path):add_suffix(".md")

    -- Generate parents just in case
    destination:parent_assert():mkdir(Path.const.o755 + 4 * math.pow(8, 4), true) -- 40755(oct)

    -- Create or overwrite the file
    local fd = destination:fs_open(opts.force and "w" or "a", Path.const.o644, false)
    if fd then
      vim.loop.fs_close(fd)
    end

    -- Broadcast file creation event
    local bufnr = init.public.get_file_bufnr(destination:tostring())
    mod.broadcast_event(
      assert(mod.create_event(init, "vault.events.file_created", { buffer = bufnr, opts = opts }))
    )

    if not opts.no_open then
      -- Begin editing that newly created file
      vim.cmd("e " .. destination:cmd_string() .. "| w")
    end
  end,

  --- Takes in a vault name and a path for a file and opens it
  ---@param vault_name string #The name of the vault to use
  ---@param path string|PathlibPath #A path to open the file (e.g directory/filename.word)
  open_file = function(vault_name, path)
    local vault = init.public.get_vault(vault_name)

    if vault == nil then
      return
    end

    vim.cmd("e " .. (vault / path):cmd_string() .. " | w")
  end,
  --- Reads the word_last_vault.txt file and loads the cached vault from there
  set_last_vault = function()
    -- Attempt to open the last vault cache file in read-only mode
    local store = mod.get_mod("store")

    if not store then
      log.trace("init `default.store` not loaded, refusing to load last user's vault.")
      return
    end

    local last_vault = store.retrieve("last_vault")
    last_vault = type(last_vault) == "string" and last_vault
        or init.config.public.default_vault
        or ""

    local vault_path = init.public.get_vault(last_vault)

    if not vault_path then
      log.trace("Unable to switch to vault '" .. last_vault .. "'. The vault does not exist.")
      return
    end

    -- If we were successful in switching to that vault then begin editing that vault's index file
    if init.public.set_vault(last_vault) then
      vim.cmd("e " .. (vault_path / init.public.get_index()):cmd_string())

      utils.notify("Last vault -> " .. vault_path)
    end
  end,
  --- Checks for file existence by supplying a full path in `filepath`
  ---@param filepath string|PathlibPath
  file_exists = function(filepath)
    return Path(filepath):exists()
  end,
  --- Get the bufnr for a `filepath` (full path)
  ---@param filepath string|PathlibPath
  get_file_bufnr = function(filepath)
    if init.public.file_exists(filepath) then
      local uri = vim.uri_from_fname(tostring(filepath))
      return vim.uri_to_bufnr(uri)
    end
  end,
  --- Returns a list of all files relative path from a `vault_name`
  ---@param vault_name string
  ---@return PathlibPath[]|nil
  get_word_files = function(vault_name)
    local res = {}
    local vault = init.public.get_vault(vault_name)

    if not vault then
      return
    end

    for path in vault:fs_iterdir(true, 20) do
      if path:is_file(true) and path:suffix() == ".md" then
        table.insert(res, path)
      end
    end

    return res
  end,
  --- Sets the current vault and opens that vault's index file
  ---@param vault string #The name of the vault to open
  open_vault = function(vault)
    -- If we have, then query that vault
    local ws_match = init.public.get_vault(vault)

    -- If the vault does not exist then give the user a nice error and bail
    if not ws_match then
      log.error('Unable to switch to vault - "' .. vault .. '" does not exist')
      return
    end

    -- Set the vault to the one requested
    init.public.set_vault(vault)

    -- If we're switching to a vault that isn't the default vault then enter the index file
    if vault ~= "default" then
      vim.cmd("e " .. (ws_match / init.public.get_index()):cmd_string())
    end
  end,
  --- Touches a file in vault
  ---@param path string|PathlibPath
  ---@param vault string
  touch_file = function(path, vault)
    vim.validate({
      path = { path, "string", "table" },
      vault = { vault, "string" },
    })

    local ws_match = init.public.get_vault(vault)

    if not vault then
      return false
    end

    return (ws_match / path):touch(Path.const.o644, true)
  end,
  get_index = function()
    return init.config.public.index
  end,
  new_note = function()
    if init.config.public.use_popup then
      init.required["ui"].create_prompt("wordNewNote", "New Note: ", function(text)
        -- Create the file that the user has entered
        init.public.create_file(text)
      end, {
        center_x = true,
        center_y = true,
      }, {
        width = 25,
        height = 1,
        row = 10,
        col = 0,
      })
    else
      vim.ui.input({ prompt = "New Note: " }, function(text)
        if text ~= nil and #text > 0 then
          init.public.create_file(text)
        end
      end)
    end
  end,
}

init.on_event = function(event)
  -- If somebody has executed the :word vault command then
  if event.type == "cmd.events.vault.vault" then
    -- Have we supplied an argument?
    if event.content[1] then
      init.public.open_vault(event.content[1])

      vim.schedule(function()
        local new_vault = init.public.get_vault(event.content[1])

        if not new_vault then
          return
        end

        utils.notify("New vault: " .. event.content[1] .. " -> " .. new_vault)
      end)
    else -- No argument supplied, simply print the current vault
      -- Query the current vault
      local current_ws = init.public.get_current_vault()
      -- Nicely print it. We schedule_wrap here because people with a configured logger will have this message
      -- silenced by other trace logs
      vim.schedule(function()
        utils.notify("Current vault: " .. current_ws[1] .. " -> " .. current_ws[2])
      end)
    end
  end

  -- If somebody has executed the :word index command then
  if event.type == "cmd.events.vault.index" then
    local current_ws = init.public.get_current_vault()

    local index_path = current_ws[2] / init.public.get_index()

    if vim.fn.filereadable(index_path:tostring("/")) == 0 then
      -- if current_ws[1] == "default" then
      --   utils.notify(table.concat({
      --     "Index file cannot be created in 'default' vault to avoid confusion.",
      --     "If this is intentional, manually create an index file beforehand to use this command.",
      --   }, " "))
      --   return
      -- end
      if not index_path:touch(Path.const.o644, true) then
        utils.notify(
          table.concat({
            "Unable to create '",
            init.public.get_index(),
            "' in the current vault - are your filesystem permissions set correctly?",
          }),
          vim.log.levels.WARN
        )
        return
      end
    end

    vault_utils.edit_file(index_path:cmd_string())
    return
  end
end

init.events.defined = {
  vault_changed = mod.define_event(init, "vault_changed"),
  vault_added = mod.define_event(init, "vault_added"),
  vault_cache_empty = mod.define_event(init, "vault_cache_empty"),
  file_created = mod.define_event(init, "file_created"),
}

init.events.subscribed = {
  vault = {
    vault_changed = true,
  },
  cmd = {
    ["vault.vault"] = true,
    ["vault.index"] = true,
  },
}

return init
