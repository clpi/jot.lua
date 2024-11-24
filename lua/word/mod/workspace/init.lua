local Path = require("pathlib")

local word = require("word")
local log, mod, utils = word.log, require("word.mod"), word.utils

local M = mod.create("workspace")

M.setup = function()
  return {
    success = true,
    requires = { "ui", "data", "note", "data.dirs" },
  }
end

M.maps = function()
  Map.nmap(",ww", "<CMD>Telescope word workspace<CR>")
  Map.nmap(",w,", "<CMD>Word workspace default<CR>")
  Map.nmap(",wd", "<CMD>Word workspace default<CR>")
end

M.load = function()
  -- Go through every workspace and expand special symbols like ~
  for name, workspace_location in pairs(M.config.public.workspaces) do
    -- M.config.public.workspaces[name] = vim.fn.expand(vim.fn.fnameescape(workspace_location)) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
    -- print(name, workspace_location)
    M.config.public.workspaces[name] =
        Path(workspace_location):resolve():to_absolute()
  end

  -- vim.keymap.set("<c-\\><c-\\>", "<Plug>(word.workspace.new-note)", M.public.new_note)

  -- Used to detect when we've entered a buffer with a potentially different cwd

  -- M.required.autocommands.enable_autocommand("BufEnter", true)
  -- mod.await("cmd", function(cmd)
  --   cmd.add_commands_from_table({
  --     index = {
  --       args = 0,
  --       name = "workspace.index",
  --     },
  --   })
  -- end)
  --
  vim.api.nvim_create_autocmd("BufEnter", {
    -- pattern = "markdown",
    callback = function()
      mod.await("cmd", function(cmd)
        cmd.add_commands_from_table({
          index = {
            args = 0,
            name = "workspace.index",
          },
        })
      end)
    end,
  })
  -- Synchronize default.cmd autocompletions
  M.public.sync()

  if M.config.public.open_last_workspace and vim.fn.argc(-1) == 0 then
    if M.config.public.open_last_workspace == "default" then
      if not M.config.public.default then
        log.warn(
          'Configuration error in `default.workspace`: the `open_last_workspace` option is set to "default", but no default workspace is provided in the `default_workspace` configuration variable. defaulting to opening the last known workspace.'
        )
        M.public.set_last_workspace()
        return
      end

      M.public.open_workspace(M.config.public.default)
    else
      M.public.set_last_workspace()
    end
  elseif M.config.public.default then
    M.public.set_workspace(M.config.public.default)
  end
end

M.config.public = {
  -- The list of active word workspaces.
  --
  -- There is always an inbuilt workspace called `default`, whose location is
  -- set to the Neovim current working directory on boot.
  ---@type table<string, PathlibPath>
  workspaces = {
    default = Path.cwd(),
  },
  -- The name for the index file.
  --
  -- The index file is the "entry point" for all of your notes.
  index = "index.md",
  -- The default workspace to set whenever Neovim starts.
  default = nil,
  -- Whether to open the last workspace's index file when `nvim` is executed
  -- without arguments.
  --
  -- May also be set to the string `"default"`, due to which word will always
  -- open up the index file for the workspace defined in `default_workspace`.
  open_last_workspace = false,
  -- Whether to use default.ui.text_popup for `workspace.new.note` event.
  -- if `false`, will use vim's default `vim.ui.input` instead.
  use_popup = true,
}

M.private = {
  ---@type { [1]: string, [2]: PathlibPath }
  current_workspace = { "default", Path.cwd() },
}

---@class workspace
M.public = {
  current = function()
    return M.private.current_workspace
  end,
  files = function(ws)
    local res = {}
    local w = M.public.get_workspace(ws)
    if not w then
      return
    end
    for path in w:fs_iterdir(true, 20) do
      if path:is_file(true) and path:suffix() == ".md" then
        table.insert(res, path)
      end
    end
    return res
  end,
  ---Resolve `$<workspace>/path/to/file` and return the real path
  ---@param path string | PathlibPath # path
  ---@param raw_path boolean? # If true, returns resolved path, otherwise, returns resolved path
  ---and append ".word"
  ---@param host_file string | PathlibPath | nil file the link resides in, if the link is
  ---relative, this file is used instead of the current file
  ---@return PathlibPath?, boolean? # Resolved path. If path does not start with `$` or not absolute, adds
  ---relative from current file.
  expand_pathlib = function(path, raw_path, host_file)
    local relative = false
    if not host_file then
      host_file = vim.fn.expand("%:p")
    end
    local filepath = Path(path)
    local custom_workspace_path = filepath:match("^%$([^/\\]*)[/\\]")
    if custom_workspace_path then
      ---@type mod.workspace
      local ws = mod.get_mod("workspace")
      if not workspace then
        log.error(table.concat({
          "Unable to jump to link with custom workspace: `default.workspace` is not loaded.",
          "Please load the init in order to get workspace support.",
        }, " "))
        return
      end
      -- If the user has given an empty workspace name (i.e. `$/myfile`)
      if custom_workspace_path:len() == 0 then
        filepath = ws.get_current_workspace()[2]
            / filepath:relative_to(Path("$"))
      else -- If the user provided a workspace name (i.e. `$my-workspace/myfile`)
        local workspace = ws.get_workspace(custom_workspace_path)
        if not workspace then
          local msg = "Unable to expand path: workspace '%s' does not exist"
          log.warn(string.format(msg, custom_workspace_path))
          return
        end
        filepath = ws / filepath:relative_to(Path("$" .. custom_workspace_path))
      end
    elseif filepath:is_relative() then
      relative = true
      local this_file = Path(host_file):absolute()
      filepath = this_file:parent_assert() / filepath
    else
      filepath = filepath:absolute()
    end
    -- requested to expand word file
    if not raw_path then
      if
          type(path) == "string"
          and (path:sub(#path) == "/" or path:sub(#path) == "\\")
      then
        -- if path ends with `/`, it is an invalid request!
        log.error(table.concat({
          "md file location cannot point to a directory.",
          string.format("Current link points to '%s'", path),
          "which ends with a `/`.",
        }, " "))
        return
      end
      filepath = filepath:add_suffix(".md")
    end
    return filepath, relative
  end,

  ---Call attempt to edit a file, catches and suppresses the error caused by a swap file being
  ---present. Re-raises other errors via log.error
  ---@param path string
  edit_file = function(path)
    local ok, err = pcall(vim.cmd.edit, path)
    if not ok then
      -- Vim:E325 is the swap file error, in which case, a lengthy message already shows to
      -- the user, and we don't have to crash out of this function (which creates a long and
      -- misleading error message).
      if err and not err:match("Vim:E325") then
        log.error(("Failed to edit file %s. Error:\n%s"):format(path, err))
      end
    end
  end,

  ---Resolve `$<workspace>/path/to/file` and return the real path
  -- NOTE: Use `expand_pathlib` which returns a PathlibPath object instead.
  ---
  ---\@deprecate Use `expand_pathlib` which returns a PathlibPath object instead. TODO: deprecate this <2024-03-27>
  ---@param path string|PathlibPath # path
  ---@param raw_path boolean? # If true, returns resolved path, otherwise, returns resolved path and append ".word"
  ---@return string? # Resolved path. If path does not start with `$` or not absolute, adds relative from current file.
  expand_path = function(path, raw_path)
    local res = M.public.expand_pathlib(path, raw_path)
    return res and res:tostring() or nil
  end,
  get_workspaces = function()
    return M.config.public.workspaces
  end,
  ---@return string[]
  get_workspace_names = function()
    return vim.tbl_keys(M.config.public.workspaces)
  end,
  --- If present retrieve a workspace's path by its name, else returns nil
  ---@param name string #The name of the workspace
  get_workspace = function(name)
    return M.config.public.workspaces[name]
  end,
  --- Returns a table in the format { "workspace_name", "path" }
  get_current_workspace = function()
    return M.private.current_workspace
  end,
  --- Sets the workspace to the one specified (if it exists) and broadcasts the workspace_changed event
  ---@param ws_name string #The name of a valid namespace we want to switch to
  ---@return boolean #True if the workspace is set correctly, false otherwise
  set_workspace = function(ws_name)
    -- Grab the workspace location
    local workspace = M.config.public.workspaces[ws_name]
    -- Create a new object describing our new workspace
    local new_workspace = { ws_name, workspace }

    -- If the workspace does not exist then error out
    if not workspace then
      log.warn(
        "Unable to set workspace to",
        workspace,
        "- that workspace does not exist"
      )
      return false
    end

    -- Create the workspace directory if not already present
    workspace:mkdir(Path.const.o755, true)

    -- Cache the current workspace
    local current_ws = vim.deepcopy(M.private.current_workspace)

    -- Set the current workspace to the new workspace object we constructed
    M.private.current_workspace = new_workspace

    if ws_name ~= "default" then
      M.required["data"].store("last_workspace", ws_name)
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
  end,
  --- Dynamically defines a new workspace if the name isn't already occupied and broadcasts the workspace_added event
  ---@return boolean True if the workspace is added successfully, false otherwise
  ---@param workspace_name string #The unique name of the new workspace
  ---@param workspace_path string|PathlibPath #A full path to the workspace root
  add_workspace = function(workspace_name, workspace_path)
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
        mod.create_event(
          M,
          "workspace.events.workspace_added",
          { workspace_name, workspace_path }
        )
      )
    )

    -- Sync autocompletions so the user can see the new workspace
    M.public.sync()

    return true
  end,
  --- If the file we opened is within a workspace directory, returns the name of the workspace, else returns nil
  get_workspace_match = function()
    -- Cache the current working directory
    M.config.public.workspaces.default = Path.cwd()

    local file = Path(vim.fn.expand("%:p"))

    -- Name of matching workspace. Falls back to "default"
    local ws_name = "default"

    -- data the depth of the longest match
    local longest_match = 0

    -- Find a matching workspace
    for workspace, location in pairs(M.config.public.workspaces) do
      if workspace ~= "default" then
        if
            file:is_relative_to(location) and location:depth() > longest_match
        then
          ws_name = workspace
          longest_match = location:depth()
        end
      end
    end

    return ws_name
  end,
  --- Uses the `get_workspace_match()` function to determine the root of the workspace defaultd on the
  --- current working directory, then changes into that workspace
  set_closest_workspace_match = function()
    -- Get the closest workspace match
    local ws_match = M.public.get_workspace_match()

    -- If that match exists then set the workspace to it!
    if ws_match then
      M.public.set_workspace(ws_match)
    else
      -- Otherwise try to reset the workspace to the default
      M.public.set_workspace("default")
    end
  end,
  --- Updates completions for the :word command
  sync = function()
    -- Get all the workspace names
    local workspace_names = M.public.get_workspace_names()

    -- Add the command to default.cmd so it can be used by the user!
    mod.await("cmd", function(cmd)
      cmd.add_commands_from_table({
        workspace = {
          max_args = 1,
          name = "workspace.workspace",
          complete = { workspace_names },
        },
      })
    end)
  end,
  select_workspace = function() end,

  ---@class default.workspace.create_file_opts
  ---@field ['opts.no_open']? boolean do not open the file after creation?
  ---@field ['opts.force']? boolean overwrite file if it already exists?

  --- Takes in a path (can include directories) and creates a .word file from that path
  ---@param path string|PathlibPath a path to place the .word file in
  ---@param workspace? string workspace name
  ---@param opts? default.workspace.create_file_opts additional options
  create_file = function(path, workspace, opts)
    opts = opts or {}

    -- Grab the current workspace's full path
    local fullpath

    if workspace ~= nil then
      fullpath = M.public.get_workspace(workspace)
    else
      fullpath = M.public.get_current_workspace()[2]
    end

    if fullpath == nil then
      log.error("Error in fetching workspace path")
      return
    end

    local destination = (fullpath / path):add_suffix(".md")

    -- Generate parents just in case
    destination
        :parent_assert()
        :mkdir(Path.const.o755 + 4 * math.pow(8, 4), true) -- 40755(oct)

    -- Create or overwrite the file
    local fd =
        destination:fs_open(opts.force and "w" or "a", Path.const.o644, false)
    if fd then
      vim.loop.fs_close(fd)
    end

    -- Broadcast file creation event
    local bufnr = M.public.get_file_bufnr(destination:tostring())
    mod.broadcast_event(
      assert(
        mod.create_event(
          M,
          "workspace.events.file_created",
          { buffer = bufnr, opts = opts }
        )
      )
    )

    if not opts.no_open then
      -- Begin editing that newly created file
      vim.cmd("e " .. destination:cmd_string() .. "| w")
    end
  end,

  --- Takes in a workspace name and a path for a file and opens it
  ---@param workspace_name string #The name of the workspace to use
  ---@param path string|PathlibPath #A path to open the file (e.g directory/filename.word)
  open_file = function(workspace_name, path)
    local workspace = M.public.get_workspace(workspace_name)

    if workspace == nil then
      return
    end

    vim.cmd("e " .. (workspace / path):cmd_string() .. " | w")
  end,
  --- Reads the word_last_workspace.txt file and loads the cached workspace from there
  set_last_workspace = function()
    -- Attempt to open the last workspace cache file in read-only mode
    local data = mod.get_mod("data")

    if not data then
      log.trace(
        "M `default.data` not loaded, refusing to load last user's workspace."
      )
      return
    end

    local last_workspace = data.retrieve("last_workspace")
    last_workspace = type(last_workspace) == "string" and last_workspace
        or M.config.public.default
        or ""

    local workspace_path = M.public.get_workspace(last_workspace)

    if not workspace_path then
      log.trace(
        "Unable to switch to workspace '"
        .. last_workspace
        .. "'. The workspace does not exist."
      )
      return
    end

    -- If we were successful in switching to that workspace then begin editing that workspace's index file
    if M.public.set_workspace(last_workspace) then
      vim.cmd("e " .. (workspace_path / M.public.get_index()):cmd_string())

      utils.notify("Last workspace -> " .. workspace_path)
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
    if M.public.file_exists(filepath) then
      local uri = vim.uri_from_fname(tostring(filepath))
      return vim.uri_to_bufnr(uri)
    end
  end,
  --- Returns a list of all files relative path from a `workspace_name`
  ---@param workspace_name string
  ---@return PathlibPath[]|nil
  get_note_files = function(workspace_name)
    local workspace = M.public.get_workspace(workspace_name)
    if not workspace then
      return
    end
    local n = M.required["note"].config.public.note_dir
    local wn = Path(workspace / n)
    local res = {} ---@type table<PathlibPath>
    for path in wn:fs_iterdir(true, 20) do
      if path:is_file(true) and path:suffix() == ".md" then
        table.insert(res, path)
      end
    end
    return res
  end,
  --- Returns a list of all files relative path from a `workspace_name`
  ---@param workspace_name string
  ---@return PathlibPath[]|nil
  get_dirs = function(workspace_name)
    local res = {}
    local workspace = M.public.get_workspace(workspace_name)
    if not workspace then
      return
    end

    for path in workspace:fs_iterdir(true, 20) do
      if path:is_file(false) then
        table.insert(res, path)
      end
    end

    return res
  end,
  --- Returns a list of all files relative path from a `workspace_name`
  ---@param workspace_name string
  ---@return PathlibPath[]|nil
  get_files = function(workspace_name)
    local res = {}
    local workspace = M.public.get_workspace(workspace_name)

    if not workspace then
      return
    end

    for path in workspace:fs_iterdir(true, 20) do
      if path:is_file(true) then
        table.insert(res, path)
      end
    end

    return res
  end,
  --- Returns a list of all files relative path from a `workspace_name`
  ---@param workspace_name string
  ---@return PathlibPath[]|nil
  get_word_files = function(workspace_name)
    local res = {}
    local workspace = M.public.get_workspace(workspace_name)

    if not workspace then
      return
    end

    for path in workspace:fs_iterdir(true, 20) do
      if path:is_file(true) and path:suffix() == ".md" then
        table.insert(res, path)
      end
    end

    return res
  end,
  --- Sets the current workspace and opens that workspace's index file
  ---@param workspace string #The name of the workspace to open
  open_workspace = function(workspace)
    -- If we have, then query that workspace
    local ws_match = M.public.get_workspace(workspace)

    -- If the workspace does not exist then give the user a nice error and bail
    if not ws_match then
      log.error(
        'Unable to switch to workspace - "' .. workspace .. '" does not exist'
      )
      return
    end

    -- Set the workspace to the one requested
    M.public.set_workspace(workspace)

    -- If we're switching to a workspace that isn't the default workspace then enter the index file
    if workspace ~= "default" then
      vim.cmd("e " .. (ws_match / M.public.get_index()):cmd_string())
    end
  end,
  --- Touches a file in workspace
  ---@param path string|PathlibPath
  ---@param workspace string
  touch_file = function(path, workspace)
    vim.validate({
      path = { path, "string", "table" },
      workspace = { workspace, "string" },
    })

    local ws_match = M.public.get_workspace(workspace)

    if not workspace then
      return false
    end

    return (ws_match / path):touch(Path.const.o644, true)
  end,
  get_index = function()
    return M.config.public.index
  end,
  new_note = function()
    if M.config.public.use_popup then
      M.required.ui.create_prompt("WordNewNote", "New Note: ", function(text)
        -- Create the file that the user has entered
        M.public.create_file(text)
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
          M.public.create_file(text)
        end
      end)
    end
  end,
}

M.on_event = function(event)
  -- If somebody has executed the :word workspace command then
  if event.type == "cmd.events.workspace.workspace" then
    -- Have we supplied an argument?
    if event.content[1] then
      M.public.open_workspace(event.content[1])

      vim.schedule(function()
        local new_workspace = M.public.get_workspace(event.content[1])

        if not new_workspace then
          return
        end

        utils.notify(
          "New workspace: " .. event.content[1] .. " -> " .. new_workspace
        )
      end)
    else -- No argument supplied, simply print the current workspace
      -- Query the current workspace
      local current_ws = M.public.get_current_workspace()
      -- Nicely print it. We schedule_wrap here because people with a configured logger will have this message
      -- silenced by other trace logs
      vim.schedule(function()
        utils.notify(
          "Current workspace: " .. current_ws[1] .. " -> " .. current_ws[2]
        )
      end)
    end
  end

  -- If somebody has executed the :word index command then
  if event.type == "cmd.events.workspace.index" then
    local current_ws = M.public.get_current_workspace()

    local index_path = current_ws[2] / M.public.get_index()

    if vim.fn.filereadable(index_path:tostring("/")) == 0 then
      -- if current_ws[1] == "default" then
      --   utils.notify(table.concat({
      --     "Index file cannot be created in 'default' workspace to avoid confusion.",
      --     "If this is intentional, manually create an index file beforehand to use this command.",
      --   }, " "))
      --   return
      -- end
      if not index_path:touch(Path.const.o644, true) then
        utils.notify(
          table.concat({
            "Unable to create '",
            M.public.get_index(),
            "' in the current workspace - are your filesystem permissions set correctly?",
          }),
          vim.log.levels.WARN
        )
        return
      end
    end

    M.public.edit_file(index_path:cmd_string())
    return
  end
end

M.events.defined = {
  workspace_changed = mod.define_event(M, "workspace_changed"),
  workspace_added = mod.define_event(M, "workspace_added"),
  workspace_cache_empty = mod.define_event(M, "workspace_cache_empty"),
  file_created = mod.define_event(M, "file_created"),
}

M.events.subscribed = {
  workspace = {
    workspace_added = true,

    workspace_changed = true,
  },
  cmd = {
    ["workspace.workspace"] = true,
    ["workspace.new"] = true,
    ["workspace.index"] = true,
  },
}

return M
