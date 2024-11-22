local mod = require("word").mod
local log = require("word").log
local utils = require("word").utils
local Path = require("pathlib")
M = {}
M.get_vaults = function()
  return M.config.public.vaults
end
---@return string[]
function M.get_vault_names()
  return vim.tbl_keys(M.config.public.vaults)
end

--- If present retrieve a vault's path by its name, else returns nil
---@param name string #The name of the vault
M.get_vault = function(name)
  return M.config.public.vaults[name]
end
--- Returns a table in the format { "vault_name", "path" }
M.get_current_vault = function()
  return M.private.current_vault
end

--- Sets the vault to the one specified (if it exists) and broadcasts the vault_changed event
---@param ws_name string #The name of a valid namespace we want to switch to
---@return boolean #True if the vault is set correctly, false otherwise
M.set_vault = function(ws_name)
  -- Grab the vault location
  local vault = M.config.public.vaults[ws_name]
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
  local current_ws = vim.deepcopy(M.private.current_vault)

  -- Set the current vault to the new vault object we constructed
  M.private.current_vault = new_vault

  if ws_name ~= "default" then
    M.required["store"].store("last_vault", ws_name)
  end

  -- Broadcast the vault_changed event with all the necessary information
  mod.broadcast_event(
    assert(
      mod.create_event(
        M,
        "vault.events.vault_changed",
        { old = current_ws, new = new_vault }
      )
    )
  )

  return true
end
--- Dynamically defines a new vault if the name isn't already occupied and broadcasts the vault_added event
---@return boolean True if the vault is added successfully, false otherwise
---@param vault_name string #The unique name of the new vault
---@param vault_path string|PathlibPath #A full path to the vault root
M.add_vault = function(vault_name, vault_path)
  -- If the M already exists then bail
  if M.config.public.vaults[vault_name] then
    return false
  end

  vault_path = Path(vault_path):resolve():to_absolute()
  -- Set the new vault and its path accordingly
  M.config.public.vaults[vault_name] = vault_path
  -- Broadcast the vault_added event with the newly added vault as the content
  mod.broadcast_event(
    assert(
      mod.create_event(M, "vault.events.vault_added", { vault_name, vault_path })
    )
  )

  -- Sync autocompletions so the user can see the new vault
  M.sync()

  return true
end
--- If the file we opened is within a vault directory, returns the name of the vault, else returns nil
M.get_vault_match = function()
  -- Cache the current working directory
  M.config.public.vaults.base = Path.cwd()

  local file = Path(vim.fn.expand("%:p"))

  -- Name of matching vault. Falls back to "base"
  local ws_name = "base"

  -- Store the depth of the longest match
  local longest_match = 0

  -- Find a matching vault
  for vault, location in pairs(M.config.public.vaults) do
    if vault ~= "base" then
      if file:is_relative_to(location) and location:depth() > longest_match then
        ws_name = vault
        longest_match = location:depth()
      end
    end
  end

  return ws_name
end
--- Uses the `get_vault_match()` function to determine the root of the vault based on the
--- current working directory, then changes into that vault
M.set_closest_vault_match = function()
  -- Get the closest vault match
  local ws_match = M.get_vault_match()

  -- If that match exists then set the vault to it!
  if ws_match then
    M.set_vault(ws_match)
  else
    -- Otherwise try to reset the vault to the base
    M.set_vault("base")
  end
end
--- Updates completions for the :word command
M.sync = function()
  -- Get all the vault names
  local vault_names = M.get_vault_names()

  -- Add the command to base.cmd so it can be used by the user!
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      vault = {
        max_args = 1,
        name = "vault.vault",
        complete = { vault_names },
      },
    })
  end)
end

---@class base.vault.create_file_opts
---@field no_open? boolean do not open the file after creation?
---@field force? boolean overwrite file if it already exists?
---@field metadata? base.esupports.metagen.metadata metadata fields, if provided inserts metadata - an empty table uses base values

--- Takes in a path (can include directories) and creates a .word file from that path
---@param path string|PathlibPath a path to place the .word file in
---@param vault? string vault name
---@param opts? base.vault.create_file_opts additional options
M.create_file = function(path, vault, opts)
  opts = opts or {}

  -- Grab the current vault's full path
  local fullpath

  if vault ~= nil then
    fullpath = M.get_vault(vault)
  else
    fullpath = M.get_current_vault()[2]
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
  local bufnr = M.get_file_bufnr(destination:tostring())
  mod.broadcast_event(
    assert(mod.create_event(M, "vault.events.file_created", { buffer = bufnr, opts = opts }))
  )

  if not opts.no_open then
    -- Begin editing that newly created file
    vim.cmd("e " .. destination:cmd_string() .. "| w")
  end
end

--- Takes in a vault name and a path for a file and opens it
---@param vault_name string #The name of the vault to use
---@param path string|PathlibPath #A path to open the file (e.g directory/filename.word)
M.open_file = function(vault_name, path)
  local vault = M.get_vault(vault_name)

  if vault == nil then
    return
  end

  vim.cmd("e " .. (vault / path):cmd_string() .. " | w")
end
--- Reads the word_last_vault.txt file and loads the cached vault from there
M.set_last_vault = function()
  -- Attempt to open the last vault cache file in read-only mode
  local store = mod.get_M("store")

  if not store then
    log.trace("M `base.store` not loaded, refusing to load last user's vault.")
    return
  end

  local last_vault = store.retrieve("last_vault")
  last_vault = type(last_vault) == "string" and last_vault
      or M.config.public.base_vault
      or ""

  local vault_path = M.get_vault(last_vault)

  if not vault_path then
    log.trace("Unable to switch to vault '" .. last_vault .. "'. The vault does not exist.")
    return
  end

  -- If we were successful in switching to that vault then begin editing that vault's index file
  if M.set_vault(last_vault) then
    vim.cmd("e " .. (vault_path / M.get_index()):cmd_string())

    utils.notify("Last vault -> " .. vault_path)
  end
end
--- Checks for file existence by supplying a full path in `filepath`
---@param filepath string|PathlibPath
M.file_exists = function(filepath)
  return Path(filepath):exists()
end
--- Get the bufnr for a `filepath` (full path)
---@param filepath string|PathlibPath
M.get_file_bufnr = function(filepath)
  if M.file_exists(filepath) then
    local uri = vim.uri_from_fname(tostring(filepath))
    return vim.uri_to_bufnr(uri)
  end
end
--- Returns a list of all files relative path from a `vault_name`
---@param vault_name string
---@return PathlibPath[]|nil
M.get_word_files = function(vault_name)
  local res = {}
  local vault = M.get_vault(vault_name)

  if not vault then
    return
  end

  for path in vault:fs_iterdir(true, 20) do
    if path:is_file(true) and path:suffix() == ".md" then
      table.insert(res, path)
    end
  end

  return res
end
--- Sets the current vault and opens that vault's index file
---@param vault string #The name of the vault to open
M.open_vault = function(vault)
  -- If we have, then query that vault
  local ws_match = M.get_vault(vault)

  -- If the vault does not exist then give the user a nice error and bail
  if not ws_match then
    log.error('Unable to switch to vault - "' .. vault .. '" does not exist')
    return
  end

  -- Set the vault to the one requested
  M.set_vault(vault)

  -- If we're switching to a vault that isn't the base vault then enter the index file
  if vault ~= "base" then
    vim.cmd("e " .. (ws_match / M.get_index()):cmd_string())
  end
end
--- Touches a file in vault
---@param path string|PathlibPath
---@param vault string
M.touch_file = function(path, vault)
  vim.validate({
    path = { path, "string", "table" },
    vault = { vault, "string" },
  })

  local ws_match = M.get_vault(vault)

  if not vault then
    return false
  end

  return (ws_match / path):touch(Path.const.o644, true)
end
M.get_index = function()
  return M.config.public.index
end
M.new_note = function()
  if M.config.public.use_popup then
    M.required["ui"].create_prompt("wordNewNote", "New Note: ", function(text)
      -- Create the file that the user has entered
      M.create_file(text)
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
        M.create_file(text)
      end
    end)
  end
end

return M
