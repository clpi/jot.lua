local Path = require('pathlib')
local config = require 'down.config'
local log = require 'down.util.log'
local util = require 'down.mod.workspace.util'
local map = require 'down.util.maps'
local mod = require 'down.mod'
local utils = require 'down.util'
local path = require 'plenary.path'

---@class down.mod.Workspace: down.mod
local M = mod.new('workspace')

---@todo TODO: Merge M.config.default and M.config.workspaces.default

---@class down.mod.workspace.Config
M.config = {
  default = 'default',
  -- The list of active down workspaces.
  -- There is always an inbuilt workspace called `default`, whose loc is
  -- set to the Neovim current working directory on boot.
  workspaces = {
    default = vim.fn.getcwd(0),
    cwd = vim.fn.getcwd(0),
  },
  ---- The active workspace
  active = Path.cwd(),
  --- The filetype of new douments, markdown is supported only for now
  ft = 'markdown',
  open_last_workspace = false,
  --- The default index to use
  index = 'index.md',
  -- if `false`, will use vim's default `vim.ui.input` instead.
  use_popup = true,
}

---@return down.mod.Setup
M.setup = function()
  return {
    loaded = true,
    requires = { 'ui', 'data', 'note' },
  }
end

M.maps = function()
  map.n(',di', '<cmd>Down index<cr>')
  map.n(',dw', '<CMD>Telescope down workspace<CR>')
  map.n(',dw', '<CMD>Down workspace<CR>')
  map.n(',d,', '<CMD>Down workspace default<CR>')
  map.n(',dd', '<CMD>Down workspace cwd<CR>')
end

M.load = function()
  for name, wsloc in pairs(M.config.workspaces) do
    M.config.workspaces[name] = Path(wsloc):resolve():to_absolute()
  end
  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    callback = function()
      mod.await('cmd', function(cmd)
        cmd.add_commands_from_table({
          index = {
            args = 0,
            name = 'workspace.index',
          },
        })
      end)
    end,
  })
  -- Synchronize default.cmd autocompletions
  M.data.sync()

  if M.config.open_last_workspace and vim.fn.argc(-1) == 0 then
    if M.config.open_last_workspace == 'default' then
      if not M.config.default then
        log.warn(
          'Configuration error in `default.workspace`: the `open_last_workspace` option is set to "default", but no default workspace is provided in the `default_workspace` configuration variable. defaulting to opening the last known workspace.'
        )
        M.data.set_last_workspace()
        return
      end

      M.data.open_workspace(M.config.default)
    else
      M.data.set_last_workspace()
    end
  elseif M.config.default then
    M.data.set_workspace(M.config.default)
  end
end

---@class down.mod.workspace.Data
M.data = {
  ---@type { [1]: string, [2]: PathlibPath }
  current_workspace = { 'default', Path.cwd() },
  history = { 'default' },
  new_missing_file = function(path) end,
  current = function()
    return M.data.current_workspace
  end,
  files = function(ws)
    local res = {}
    local w = M.data.get_workspace(ws)
    if not w then
      return
    end
    for path in w:fs_iterdir(true, 20) do
      if path:is_file(true) and path:suffix() == '.md' then
        table.insert(res, path)
      end
    end
    return res
  end,
  ---Resolve `$<workspace>/path/to/file` and return the real path
  ---@param path string | PathlibPath # path
  ---@param raw_path boolean? # If true, returns resolved path, otherwise, returns resolved path
  ---and append ".down"
  ---@param host_file string | PathlibPath | nil file the link resides in, if the link is
  ---relative, this file is used instead of the current file
  ---@return PathlibPath?, boolean? # Resolved path. If path does not start with `$` or not absolute, adds
  ---relative from current file.
  expand_pathlib = function(path, raw_path, host_file)
    local relative = false
    if not host_file then
      host_file = vim.fn.expand('%:p')
    end
    local filepath = Path(path)
    local custom_wspath = filepath:match('^%$([^/\\]*)[/\\]')
    if custom_wspath then
      ---@type down.mod.Workspace
      local ws = require('down.mod').get_mod('workspace')
      if not ws then
        log.error(table.concat({
          'Unable to jump to link with custom workspace: `default.workspace` is not loaded.',
          'Please load the init in order to get workspace support.',
        }, ' '))
        return
      end
      -- If the user has given an empty workspace name (i.e. `$/myfile`)
      if custom_wspath:len() == 0 then
        filepath = ws.get_current_workspace()[2] / filepath:relative_to(Path('$'))
      else -- If the user provided a workspace name (i.e. `$my-workspace/myfile`)
        local workspace = ws.get_workspace(custom_wspath)
        if not workspace then
          local msg = "Unable to expand path: workspace '%s' does not exist"
          log.warn(string.format(msg, custom_wspath))
          return
        end
        filepath = ws / filepath:relative_to(Path('$' .. custom_wspath))
      end
    elseif filepath:is_relative() then
      relative = true
      local this_file = Path(host_file):absolute()
      filepath = this_file:parent_assert() / filepath
    else
      filepath = filepath:absolute()
    end
    -- requested to expand down file
    if not raw_path then
      if type(path) == 'string' and (path:sub(#path) == '/' or path:sub(#path) == '\\') then
        -- if path ends with `/`, it is an invalid request!
        log.error(table.concat({
          'md file loc cannot point to a directory.',
          string.format("Current link points to '%s'", path),
          'which ends with a `/`.',
        }, ' '))
        return
      end
      filepath = filepath:add_suffix('.md')
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
      if err and not err:match('Vim:E325') then
        log.error(('Failed to edit file %s. Error:\n%s'):format(path, err))
      end
    end
  end,

  ---Resolve `$<workspace>/path/to/file` and return the real path
  -- NOTE: Use `expand_pathlib` which returns a PathlibPath object instead.
  ---
  ---\@deprecate Use `expand_pathlib` which returns a PathlibPath object instead. TODO: deprecate this <2024-03-27>
  ---@param path string|PathlibPath # path
  ---@param raw_path boolean? # If true, returns resolved path, otherwise, returns resolved path and append ".down"
  ---@return string? # Resolved path. If path does not start with `$` or not absolute, adds relative from current file.
  expand_path = function(path, raw_path)
    local res = M.data.expand_pathlib(path, raw_path)
    return res and res:tostring() or nil
  end,
  get_workspaces = function()
    return M.config.workspaces
  end,
  ---@return string[]
  get_wsnames = function()
    return vim.tbl_keys(M.config.workspaces)
  end,
  --- If present retrieve a workspace's path by its name, else returns nil
  ---@param name string #The name of the workspace
  get_workspace = function(name)
    return M.config.workspaces[name]
  end,
  --- Returns a table in the format { "wsname", "path" }
  get_current_workspace = function()
    return M.data.current_workspace
  end,
  --- Sets the workspace to the one specified (if it exists) and broadcasts the wschanged event
  ---@param ws_name string #The name of a valid namespace we want to switch to
  ---@return boolean #True if the workspace is set correctly, false otherwise
  set_workspace = function(ws_name)
    -- Grab the workspace loc
    local workspace = M.config.workspaces[ws_name]
    -- Create a new object describing our new workspace
    local new_workspace = { ws_name, workspace }

    -- If the workspace does not exist then error out
    if not workspace then
      -- log.warn('Unable to set workspace to' .. workspace .. '- that workspace does not exist')
      return false
    end

    -- Create the workspace directory if not already present
    workspace:mkdir(Path.const.o755, true)

    -- Cache the current workspace
    local current_ws = vim.deepcopy(M.data.current_workspace)

    -- Set the current workspace to the new workspace object we constructed
    M.data.current_workspace = new_workspace

    if ws_name ~= 'default' then
      M.required['data'].store('last_workspace', ws_name)
    end

    -- Broadcast the wschanged event with all the necessary information
    mod.broadcast(
      assert(
        mod.new_event(M, 'workspace.events.wschanged', { old = current_ws, new = new_workspace })
      )
    )

    return true
  end,
  --- Dynamically defines a new workspace if the name isn't already occupied and broadcasts the wsadded event
  ---@return boolean True if the workspace is added successfully, false otherwise
  ---@param wsname string #The unique name of the new workspace
  ---@param wspath string|PathlibPath #A full path to the workspace root
  add_workspace = function(wsname, wspath)
    -- If the M already exists then bail
    if M.config.workspaces[wsname] then
      return false
    end

    wspath = Path(wspath):resolve():to_absolute()
    -- Set the new workspace and its path accordingly
    M.config.workspaces[wsname] = wspath
    -- Broadcast the wsadded event with the newly added workspace as the body
    mod.broadcast(assert(mod.new_event(M, 'workspace.events.wsadded', { wsname, wspath })))

    -- Sync autocompletions so the user can see the new workspace
    M.data.sync()

    return true
  end,
  --- If the file we opened is within a workspace directory, returns the name of the workspace, else returns nil
  get_wsmatch = function()
    -- Cache the current working directory
    M.config.workspaces.default = Path.cwd()

    local file = Path(vim.fn.expand('%:p'))

    -- Name of matching workspace. Falls back to "default"
    local ws_name = 'default'

    -- data the depth of the longest match
    local longest_match = 0

    -- Find a matching workspace
    for workspace, loc in pairs(M.config.workspaces) do
      if workspace ~= 'default' then
        if file:is_relative_to(loc) and loc:depth() > longest_match then
          ws_name = workspace
          longest_match = loc:depth()
        end
      end
    end

    return ws_name
  end,
  --- Uses the `get_wsmatch()` function to determine the root of the workspace defaultd on the
  --- current working directory, then changes into that workspace
  set_closest_wsmatch = function()
    -- Get the closest workspace match
    local ws_match = M.data.get_wsmatch()

    -- If that match exists then set the workspace to it!
    if ws_match then
      M.data.set_workspace(ws_match)
    else
      -- Otherwise try to reset the workspace to the default
      M.data.set_workspace('default')
    end
  end,
  --- Updates completions for the :down command
  sync = function()
    -- Get all the workspace names
    local wsnames = M.data.get_wsnames()

    -- Add the command to default.cmd so it can be used by the user!
    mod.await('cmd', function(cmd)
      cmd.add_commands_from_table({
        workspace = {
          max_args = 1,
          name = 'workspace.workspace',
          complete = { wsnames },
        },
      })
    end)
  end,
  --- @param prompt? string | nil
  --- @param fmt? fun(item: string): string
  --- @param fn? fun(item: number|string, idx: number|string)|nil
  select = function(prompt, fmt, fn)
    local workspaces = M.data.get_workspaces()
    local format = fmt
      or function(item)
        local current = M.data.get_current_workspace()
        if item == current then
          return '• ' .. item
        end
        return item
      end
    local func = fn
      or function(item, idx)
        local current = M.data.get_current_workspace()
        print(item, idx)
        if item == current then
          utils.notify('Already in workspace ' .. current)
          print(item, idx)
          M.data.open_workspace(item)
        else
          print(item, idx)
          M.data.set_workspace(item)
          M.data.open_workspace(item)
          utils.notify('Workspace set to ' .. item)
        end
      end
    return vim.ui.select(vim.tbl_keys(workspaces), {
      prompt = prompt or 'Select workspace',
      format_items = format,
    }, fn or func)
  end,
  set_selected = function()
    local workspace = M.data.select()
    print(workspace)
    M.data.set_workspace(workspace)
    utils.notify('Changed workspace to ' .. workspace)
  end,

  ---@class default.workspace.CreateFileOpts
  ---@field ['opts.no_open']? boolean do not open the file after creation?
  ---@field ['opts.force']? boolean overwrite file if it already exists?

  --- Takes in a path (can include directories) and creates a .down file from that path
  ---@param path string|PathlibPath a path to place the .down file in
  ---@param workspace? string workspace name
  ---@param opts? default.workspace.CreateFileOpts
  new_file = function(path, workspace, opts)
    opts = opts or {}

    -- Grab the current workspace's full path
    local fullpath

    if workspace ~= nil then
      fullpath = M.data.get_workspace(workspace)
    else
      fullpath = M.data.get_current_workspace()[2]
    end

    if fullpath == nil then
      log.error('Error in fetching workspace path')
      return
    end

    local destination = (fullpath / path):add_suffix('.md')

    -- Generate parents just in case
    destination:parent_assert():mkdir(Path.const.o755 + 4 * math.pow(8, 4), true) -- 40755(oct)

    -- Create or overwrite the file
    local fd = destination:fs_open(opts.force and 'w' or 'a', Path.const.o644, false)
    if fd then
      vim.loop.fs_close(fd)
    end

    -- Broadcast file creation event
    local bufnr = M.data.get_file_bufnr(destination:tostring())
    mod.broadcast(
      assert(mod.new_event(M, 'workspace.events.file_created', { buffer = bufnr, opts = opts }))
    )

    if not opts.no_open then
      -- Begin editing that newly created file
      -- vim.cmd('e ' .. destination:cmd_string() .. '| silent! w')
      vim.cmd('e ' .. destination:tostring() .. '| silent! w')
    end
  end,

  --- Takes in a workspace name and a path for a file and opens it
  ---@param wsname string #The name of the workspace to use
  ---@param path string|PathlibPath #A path to open the file (e.g directory/filename.down)
  open_file = function(wsname, path)
    local workspace = M.data.get_workspace(wsname)

    if workspace == nil then
      return
    end

    vim.cmd('e ' .. (workspace / path):cmd_string() .. ' | silent! w')
  end,
  --- Reads the down_last_workspace.txt file and loads the cached workspace from there
  set_last_workspace = function()
    -- Attempt to open the last workspace cache file in read-only mode
    local data = mod.get_mod('data')

    if not data then
      log.trace("M `default.data` not loaded, refusing to load last user's workspace.")
      return
    end

    local last_workspace = data.retrieve('last_workspace')
    last_workspace = type(last_workspace) == 'string' and last_workspace or M.config.default or ''

    local wspath = M.data.get_workspace(last_workspace)

    if not wspath then
      log.trace(
        "Unable to switch to workspace '" .. last_workspace .. "'. The workspace does not exist."
      )
      return
    end

    -- If we were successful in switching to that workspace then begin editing that workspace's index file
    if M.data.set_workspace(last_workspace) then
      vim.cmd('e ' .. (wspath / M.data.index()):cmd_string())

      utils.notify('Last workspace -> ' .. wspath)
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
    if M.data.file_exists(filepath) then
      local uri = vim.uri_from_fname(tostring(filepath))
      return vim.uri_to_bufnr(uri)
    end
  end,
  --- Returns a list of all files relative path from a `wsname`
  ---@param wsname string
  ---@return PathlibPath[]|nil
  get_note_files = function(wsname)
    local workspace = M.data.get_workspace(wsname)
    if not workspace then
      return
    end
    local n = M.required['note'].config.note_dir
    local wn = Path(workspace / n)
    local res = {} ---@type table<PathlibPath>
    for path in wn:fs_iterdir(true, 20) do
      if path:is_file(true) and path:suffix() == '.md' then
        table.insert(res, path)
      end
    end
    return res
  end,
  --- Returns a list of all files relative path from a `wsname`
  ---@param wsname string
  ---@return PathlibPath[]|nil
  get_dirs = function(wsname)
    local res = {}
    local workspace = M.data.get_workspace(wsname)
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
  --- Returns a list of all files relative path from a `wsname`
  ---@param wsname string
  ---@return PathlibPath[]|nil
  get_files = function(wsname)
    local res = {}
    local workspace = M.data.get_workspace(wsname)

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
  --- Returns a list of all files relative path from a `wsname`
  ---@param wsname string
  ---@return PathlibPath[]|nil
  get_down_files = function(wsname)
    local res = {}
    local workspace = M.data.get_workspace(wsname)

    if not workspace then
      return
    end

    for path in workspace:fs_iterdir(true, 20) do
      if path:is_file(true) and path:suffix() == '.md' then
        table.insert(res, path)
      end
    end

    return res
  end,
  --- Sets the current workspace and opens that workspace's index file
  ---@param workspace string #The name of the workspace to open
  open_workspace = function(workspace)
    -- If we have, then query that workspace
    local ws_match = M.data.get_workspace(workspace)

    -- If the workspace does not exist then give the user a nice error and bail
    if not ws_match then
      log.error('Unable to switch to workspace - "' .. workspace .. '" does not exist')
      return
    end

    -- Set the workspace to the one requested
    M.data.set_workspace(workspace)

    -- If we're switching to a workspace that isn't the default workspace then enter the index file
    if workspace ~= 'default' then
      vim.cmd('e ' .. (ws_match / M.data.index()):cmd_string())
    end
  end,
  --- Touches a file in workspace
  ---@param path string|PathlibPath
  ---@param workspace string
  touch = function(path, workspace)
    vim.validate({
      path = { path, 'string', 'table' },
      workspace = { workspace, 'string' },
    })

    local ws_match = M.data.get_workspace(workspace)

    if not workspace then
      return false
    end

    return (ws_match / path):touch(Path.const.o644, true)
  end,
  index = function()
    return M.config.index
  end,
  new_note = function()
    if M.config.use_popup then
      M.required.ui.new_prompt('downNewNote', 'New Note: ', function(text)
        -- Create the file that the user has entered
        M.data.new_file(text)
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
      vim.ui.input({ prompt = 'New Note: ' }, function(text)
        if text ~= nil and #text > 0 then
          M.data.new_file(text)
        end
      end)
    end
  end,
}

M.data.get_dir = function(wsname)
  if not wsname then
    return M.data.current_workspace[2]
  else
    return M.data.get_workspace(wsname)
  end
end

M.data.subpath = function(path, wsname)
  local wsp = M.data.get_dir(wsname)
  return table.concat({ wsp, path }, config.pathsep)
end

M.data.is_subpath = function(path, wsname)
  local wsp = M.data.get_dir(wsname)
  return not not path:match('^' .. wsp)
end

M.handle = function(event)
  if event.type == 'cmd.events.workspace.workspace' then
    if event.body[1] then
      M.data.open_workspace(event.body[1])

      vim.schedule(function()
        local new_workspace = M.data.get_workspace(event.body[1])

        if not new_workspace then
          new_workspace = M.data.select()
        end

        utils.notify('New workspace: ' .. event.body[1] .. ' -> ' .. new_workspace)
      end)
    else -- No argument supplied, simply print the current workspace
      M.data.select()
    end

    -- If somebody has executed the :down index command then
  elseif event.type == 'cmd.events.workspace.index' then
    local current_ws = M.data.get_current_workspace()

    local index_path = current_ws[2] / M.data.index()

    if vim.fn.filereadable(index_path:tostring('/')) == 0 then
      if not index_path:touch(Path.const.o644, true) then
        return
      end
    end

    M.data.edit_file(index_path:cmd_string())
    return
  end
end

---@class down.mod.workspace.Events
M.events = {
  wschanged = mod.define_event(M, 'wschanged'),
  wsadded = mod.define_event(M, 'wsadded'),
  wscache_empty = mod.define_event(M, 'wscache_empty'),
  file_created = mod.define_event(M, 'file_created'),
}

---@class down.mod.workspace.Subscribed
M.subscribed = {
  workspace = {
    wsadded = true,
    file_created = true,
    wschanged = true,
  },
  cmd = {
    ['workspace.workspace'] = true,
    ['workspace.new'] = true,
    ['workspace.index'] = true,
  },
}

return M
