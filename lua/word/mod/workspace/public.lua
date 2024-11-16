local mod = require("word").mod
local log = require("word").log
local utils = require("word").utils
local Path = require("pathlib")
M = {}
M.get_workspaces = function()
  return M.config.public.workspaces
end
---@return string[]
function M.get_workspace_names()
  return vim.tbl_keys(M.config.public.workspaces)
end

--- If present retrieve a workspace's path by its name, else returns nil
---@param name string #The name of the workspace
M.get_workspace = function(name)
  return M.config.public.workspaces[name]
end
--- Returns a table in the format { "workspace_name", "path" }
M.get_current_workspace = function()
  return M.private.current_workspace
end

--- Sets the workspace to the one specified (if it exists) and broadcasts the workspace_changed event
---@param ws_name string #The name of a valid namespace we want to switch to
---@return boolean #True if the workspace is set correctly, false otherwise
M.set_workspace = function(ws_name)
  -- Grab the workspace location
  local workspace = M.config.public.workspaces[ws_name]
  -- Create a new object describing our new workspace
  local new_workspace = { ws_name, workspace }

  -- If the workspace does not exist then error out
  if not workspace then
    log.warn("Unable to set workspace to", workspace, "- that workspace does not exist")
    return false
  end

  -- Create the workspace directory if not already present
  workspace:mkdir(Path.const.o755, true)

  -- Cache the current workspace
  local current_ws = vim.deepcopy(M.private.current_workspace)

  -- Set the current workspace to the new workspace object we constructed
  M.private.current_workspace = new_workspace

  if ws_name ~= "default" then
    M.required["store"].store("last_workspace", ws_name)
  end

  -- Broadcast the workspace_changed event with all the necessary information
  mod.broadcast_event(
    assert(
      mod.create_event(
        M,
        "workspace.events.workspace_changed",
        { old = current_ws, new = new_workspace }
      )
    )
  )

  return true
end
--- Dynamically defines a new workspace if the name isn't already occupied and broadcasts the workspace_added event
---@return boolean True if the workspace is added successfully, false otherwise
---@param workspace_name string #The unique name of the new workspace
---@param workspace_path string|PathlibPath #A full path to the workspace root
M.add_workspace = function(workspace_name, workspace_path)
  -- If the M already exists then bail
  if M.config.public.workspaces[workspace_name] then
    return false
  end

  workspace_path = Path(workspace_path):resolve():to_absolute()
  -- Set the new workspace and its path accordingly
  M.config.public.workspaces[workspace_name] = workspace_path
  -- Broadcast the workspace_added event with the newly added workspace as the content
  mod.broadcast_event(
    assert(
      mod.create_event(M, "workspace.events.workspace_added", { workspace_name, workspace_path })
    )
  )

  -- Sync autocompletions so the user can see the new workspace
  M.sync()

  return true
end
--- If the file we opened is within a workspace directory, returns the name of the workspace, else returns nil
M.get_workspace_match = function()
  -- Cache the current working directory
  M.config.public.workspaces.base = Path.cwd()

  local file = Path(vim.fn.expand("%:p"))

  -- Name of matching workspace. Falls back to "base"
  local ws_name = "base"

  -- Store the depth of the longest match
  local longest_match = 0

  -- Find a matching workspace
  for workspace, location in pairs(M.config.public.workspaces) do
    if workspace ~= "base" then
      if file:is_relative_to(location) and location:depth() > longest_match then
        ws_name = workspace
        longest_match = location:depth()
      end
    end
  end

  return ws_name
end
--- Uses the `get_workspace_match()` function to determine the root of the workspace based on the
--- current working directory, then changes into that workspace
M.set_closest_workspace_match = function()
  -- Get the closest workspace match
  local ws_match = M.get_workspace_match()

  -- If that match exists then set the workspace to it!
  if ws_match then
    M.set_workspace(ws_match)
  else
    -- Otherwise try to reset the workspace to the base
    M.set_workspace("base")
  end
end
--- Updates completions for the :word command
M.sync = function()
  -- Get all the workspace names
  local workspace_names = M.get_workspace_names()

  -- Add the command to base.cmd so it can be used by the user!
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      workspace = {
        max_args = 1,
        name = "workspace.workspace",
        complete = { workspace_names },
      },
    })
  end)
end

---@class base.workspace.create_file_opts
---@field no_open? boolean do not open the file after creation?
---@field force? boolean overwrite file if it already exists?
---@field metadata? base.esupports.metagen.metadata metadata fields, if provided inserts metadata - an empty table uses base values

--- Takes in a path (can include directories) and creates a .word file from that path
---@param path string|PathlibPath a path to place the .word file in
---@param workspace? string workspace name
---@param opts? base.workspace.create_file_opts additional options
M.create_file = function(path, workspace, opts)
  opts = opts or {}

  -- Grab the current workspace's full path
  local fullpath

  if workspace ~= nil then
    fullpath = M.get_workspace(workspace)
  else
    fullpath = M.get_current_workspace()[2]
  end

  if fullpath == nil then
    log.error("Error in fetching workspace path")
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
    assert(mod.create_event(M, "workspace.events.file_created", { buffer = bufnr, opts = opts }))
  )

  if not opts.no_open then
    -- Begin editing that newly created file
    vim.cmd("e " .. destination:cmd_string() .. "| w")
  end
end

--- Takes in a workspace name and a path for a file and opens it
---@param workspace_name string #The name of the workspace to use
---@param path string|PathlibPath #A path to open the file (e.g directory/filename.word)
M.open_file = function(workspace_name, path)
  local workspace = M.get_workspace(workspace_name)

  if workspace == nil then
    return
  end

  vim.cmd("e " .. (workspace / path):cmd_string() .. " | w")
end
--- Reads the word_last_workspace.txt file and loads the cached workspace from there
M.set_last_workspace = function()
  -- Attempt to open the last workspace cache file in read-only mode
  local store = mod.get_M("store")

  if not store then
    log.trace("M `base.store` not loaded, refusing to load last user's workspace.")
    return
  end

  local last_workspace = store.retrieve("last_workspace")
  last_workspace = type(last_workspace) == "string" and last_workspace
      or M.config.public.base_workspace
      or ""

  local workspace_path = M.get_workspace(last_workspace)

  if not workspace_path then
    log.trace("Unable to switch to workspace '" .. last_workspace .. "'. The workspace does not exist.")
    return
  end

  -- If we were successful in switching to that workspace then begin editing that workspace's index file
  if M.set_workspace(last_workspace) then
    vim.cmd("e " .. (workspace_path / M.get_index()):cmd_string())

    utils.notify("Last Workspace -> " .. workspace_path)
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
--- Returns a list of all files relative path from a `workspace_name`
---@param workspace_name string
---@return PathlibPath[]|nil
M.get_word_files = function(workspace_name)
  local res = {}
  local workspace = M.get_workspace(workspace_name)

  if not workspace then
    return
  end

  for path in workspace:fs_iterdir(true, 20) do
    if path:is_file(true) and path:suffix() == ".md" then
      table.insert(res, path)
    end
  end

  return res
end
--- Sets the current workspace and opens that workspace's index file
---@param workspace string #The name of the workspace to open
M.open_workspace = function(workspace)
  -- If we have, then query that workspace
  local ws_match = M.get_workspace(workspace)

  -- If the workspace does not exist then give the user a nice error and bail
  if not ws_match then
    log.error('Unable to switch to workspace - "' .. workspace .. '" does not exist')
    return
  end

  -- Set the workspace to the one requested
  M.set_workspace(workspace)

  -- If we're switching to a workspace that isn't the base workspace then enter the index file
  if workspace ~= "base" then
    vim.cmd("e " .. (ws_match / M.get_index()):cmd_string())
  end
end
--- Touches a file in workspace
---@param path string|PathlibPath
---@param workspace string
M.touch_file = function(path, workspace)
  vim.validate({
    path = { path, "string", "table" },
    workspace = { workspace, "string" },
  })

  local ws_match = M.get_workspace(workspace)

  if not workspace then
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
