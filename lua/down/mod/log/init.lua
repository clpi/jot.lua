local down = require('down')
local config = require 'down.config'
local lib = require 'down.util.lib'
local log = require 'down.util.log'
local mod = require 'down.mod'

local M = mod.new 'log'

M.load = function() end

M.commands = {
  log = {
    min_args = 1,
    max_args = 2,
    name = 'log',
    callback = function(e)
      log.trace(('log %s'):format(e.body))
    end,
    subcommands = {
      index = {
        args = 0,
        name = 'log.index',
        callback = M.data.open_index,
      },
      month = {
        max_args = 1,
        name = 'log.month',
        callback = M.data.open_month,
      },
      tomorrow = {
        args = 0,
        name = 'log.tomorrow',
        callback = M.data.log_tomorrow,
      },
      yesterday = {
        args = 0,
        callback = M.data.log_yesterday,
        name = 'log.yesterday',
      },
      new = {
        args = 0,
        callback = M.data.log_new,
        name = 'log.new',
      },
      custom = {
        callback = M.data.calendar_months,
        max_args = 1,
        name = 'log.custom',
      }, -- format :yyyy-mm-dd
      template = {
        args = 0,
        name = 'log.template',
        callback = M.data.create_template,
      },
    },
  },
}

M.setup = function()
  return {
    loaded = function(e) end,
    dependencies = {
      'ui.calendar',
      'ui.popup',
      'edit.inline',
      'ui.win',
      'ui.progress',
      'workspace',
      'tool.treesitter',
      'cmd',
    },
  }
end

---@class data.log.Config
M.config = {
  -- Which workspace to use for the log files, the base behaviour
  -- is to use the current workspace.
  --
  -- It is recommended to set this to a static workspace, but the most optimal
  -- behaviour may vary from workflow to workflow.
  workspace = nil,

  -- The name for the folder in which the log files are put.
  log_folder = 'log',

  -- The strategy to use to create directories.
  -- May be "flat" (`2022-03-02.down`), "nested" (`2022/03/02.down`),
  -- a lua string with the format given to `os.date()` or a lua function
  -- that returns a lua string with the same format.
  strategy = 'nested',

  -- The name of the template file to use when running `:down log template`.
  template_name = 'template.md',

  -- Whether to apply the template file to new log entries.
  use_template = function(e) end,
}

M.config.strategies = {
  flat = '%Y-%m-%d.md',
  nested = '%Y' .. config.pathsep .. '%m' .. config.pathsep .. '%d.md',
}

---@class log
M.data = {
  data = {},
  logs = {},

  count = 0,
  calendar_months = function(e)
    if not e.content[1] then
      local calendar = mod.get_mod('ui.calendar')
      if not calendar then
        log.error('[ERROR]: `base.calendar` is not loaded! Said M is dep for this operation.')
        return
      end
      M.dep['ui.calendar'].select({
        callback = vim.schedule_wrap(function(osdate)
          M.data.open_log(
            nil,
            string.format('%04d', osdate.year)
            .. '-'
            .. string.format('%02d', osdate.month)
            .. '-'
            .. string.format('%02d', osdate.day)
          )
        end),
      })
    else
      M.data.open_log(nil, e.content[1])
    end
  end,
  get_log = function() end,
  get_logs = function() end,
  open_index = function() end,
  --- Opens a log entry at the given time
  ---@param time? number #The time to open the log entry at as returned by `os.time()`
  ---@param custom_date? string #A YYYY-mm-dd string that specifies a date to open the log at instead
  open_log = function(time, custom_date)
    -- TODO(vhyrro): Change this to use down dates!
    local workspace = M.config.workspace or M.dep['workspace'].get_current_workspace()[1]
    local workspace_path = M.dep['workspace'].get_workspace(workspace)
    local folder_name = M.config.log_folder
    local template_name = M.config.template_name

    if custom_date then
      local year, month, day = custom_date:match('^(%d%d%d%d)-(%d%d)-(%d%d)$')

      if not year or not month or not day then
        log.error('Wrong date format: use YYYY-mm-dd')
        return
      end

      time = os.time({
        year = year,
        month = month,
        day = day,
      })
    end

    local path = os.date(
      type(M.config.strategy) == 'function' and M.config.strategy(os.date('*t', time))
      or M.config.strategy,
      time
    )

    local log_file_exists =
        M.dep['workspace'].file_exists(workspace_path .. '/' .. folder_name .. config.pathsep .. path)

    M.dep['workspace'].new_file(folder_name .. config.pathsep .. path, workspace)

    M.dep['workspace'].new_file(folder_name .. config.pathsep .. path, workspace)

    if
        not log_file_exists
        and M.config.use_template
        and M.dep['workspace'].file_exists(
          workspace_path .. '/' .. folder_name .. '/' .. template_name
        )
    then
      vim.cmd(
        '$read ' .. workspace_path .. '/' .. folder_name .. '/' .. template_name .. '| silent! w'
      )
    end
  end,

  --- Opens a log entry for tomorrow's date
  log_tomorrow = function()
    -- M.dep['ui.progress'].start()
    M.dep['ui.win'].new_new()
  end,

  --- Opens a log entry for yesterday's date
  log_yesterday = function()
    M.dep['ui.win'].win(0)
  end,

  --- Opens a log entry for new's date
  log_new = function()
    vim.ui.input({
      prompt = 'New log name: ',

      default = nil,
      completion = M.data.logs,
    }, function()
      vim.notify('hi')
    end)
    M.data.open_log()
  end,

  --- Creates a template file
  create_template = function()
    local workspace = M.config.workspace
    local folder_name = M.config.log_folder
    local template_name = M.config.template_name

    M.dep['workspace'].new_file(
      folder_name .. config.pathsep .. template_name,
      workspace or M.dep['workspace'].get_current_workspace()[1]
    )
  end,

  --- Opens the toc file
  open_toc = function()
    local workspace = M.config.workspace or M.dep['workspace'].get_current_workspace()[1]
    local index = mod.mod_config('workspace').index
    local folder_name = M.config.log_folder

    -- If the toc exists, open it, if not, create it
    if M.dep['workspace'].file_exists(folder_name .. config.pathsep .. index) then
      M.dep['workspace'].open_file(workspace, folder_name .. config.pathsep .. index)
    else
      M.data.new_toc()
    end
  end,

  --- Creates or updates the toc file
  create_toc = function()
    local workspace = M.config.workspace or M.dep['workspace'].get_current_workspace()[1]
    local index = mod.mod_config('workspace').index
    local workspace_path = M.dep['workspace'].get_workspace(workspace)
    local workspace_name_for_link = M.config.workspace or ''
    local folder_name = M.config.log_folder

    -- Each entry is a table that contains tables like { yy, mm, dd, link, title }
    local toc_entries = {}

    -- Get a filesystem handle for the files in the log folder
    -- path is for each subfolder
    local get_fs_handle = function(path)
      path = path or ''
      local handle = vim.loop.fs_scandir(
        workspace_path .. config.pathsep .. folder_name .. config.pathsep .. path
      )

      if type(handle) ~= 'userdata' then
        error(lib.lazy_string_concat("Failed to scan directory '", workspace, path, "': ", handle))
      end

      return handle
    end

    -- Gets the title from the metadata of a file, must be called in a vim.schedule
    local get_title = function(file)
      local buffer =
          vim.fn.bufadd(workspace_path .. config.pathsep .. folder_name .. config.pathsep .. file)
      local meta = M.dep['workspace'].get_document_metadata(buffer)
      return meta.title
    end

    vim.loop.fs_scandir(
      workspace_path .. config.pathsep .. folder_name .. config.pathsep,
      function(err, handle)
        assert(
          not err,
          lib.lazy_string_concat("Unable to generate TOC for directory '", folder_name, "' - ", err)
        )

        while true do
          -- Name corresponds to either a YYYY-mm-dd.down file, or just the year ("nested" strategy)
          local name, type = vim.loop.fs_scandir_next(handle) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>

          if not name then
            break
          end

          -- Handle nested entries
          if type == 'directory' then
            local years_handle = get_fs_handle(name)
            while true do
              -- mname is the month
              local mname, mtype = vim.loop.fs_scandir_next(years_handle)

              if not mname then
                break
              end

              if mtype == 'directory' then
                local months_handle = get_fs_handle(name .. config.pathsep .. mname)
                while true do
                  -- dname is the day
                  local dname, dtype = vim.loop.fs_scandir_next(months_handle)

                  if not dname then
                    break
                  end

                  -- If it's a .down file, also ensure it is a day entry
                  if dtype == 'file' and string.match(dname, '%d%d%.md') then
                    -- Split the file name
                    local file = vim.split(dname, '.', { plain = true })

                    vim.schedule(function()
                      -- Get the title from the metadata, else, it just base to the name of the file
                      local title = get_title(
                        name .. config.pathsep .. mname .. config.pathsep .. dname
                      ) or file[1]

                      -- Insert a new entry
                      table.insert(toc_entries, {
                        tonumber(name),
                        tonumber(mname),
                        tonumber(file[1]),
                        '{:$'
                        .. workspace_name_for_link
                        .. config.pathsep
                        .. M.config.log_folder
                        .. config.pathsep
                        .. name
                        .. config.pathsep
                        .. mname
                        .. config.pathsep
                        .. file[1]
                        .. ':}',
                        title,
                      })
                    end)
                  end
                end
              end
            end
          end

          -- Handles flat entries
          -- If it is a .down file, but it's not any user generated file.
          -- The match is here to avoid handling files made by the user, like a template file, or
          -- the toc file
          if type == 'file' and string.match(name, '%d+-%d+-%d+%.md') then
            -- Split yyyy-mm-dd to a table
            local file = vim.split(name, '.', { plain = true })
            local parts = vim.split(file[1], '-')

            -- Convert the parts into numbers
            for k, v in pairs(parts) do
              parts[k] = tonumber(v) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
            end

            vim.schedule(function()
              -- Get the title from the metadata, else, it just base to the name of the file
              local title = get_title(name) or parts[3]

              -- And insert a new entry that corresponds to the file
              table.insert(toc_entries, {
                parts[1],
                parts[2],
                parts[3],
                '{:$'
                .. workspace_name_for_link
                .. config.pathsep
                .. M.config.log_folder
                .. config.pathsep
                .. file[1]
                .. ':}',
                title,
              })
            end)
          end
        end

        vim.schedule(function()
          -- Gets a base format for the entries
          local format = M.config.toc_format
              or function(entries)
                local months_text = require 'down.mod.note.util'.months
                -- Convert the entries into a certain format to be written
                local output = {}
                local current_year
                local current_month
                for _, entry in ipairs(entries) do
                  -- Don't print the year and month if they haven't changed
                  if not current_year or current_year < entry[1] then
                    current_year = entry[1]
                    current_month = nil
                    table.insert(output, '* ' .. current_year)
                  end
                  if not current_month or current_month < entry[2] then
                    current_month = entry[2]
                    table.insert(output, '** ' .. months_text[current_month])
                  end

                  -- Prints the file link
                  table.insert(output, '   ' .. entry[4] .. string.format('[%s]', entry[5]))
                end

                return output
              end

          M.dep['workspace'].new_file(
            folder_name .. config.pathsep .. index,
            workspace or M.dep['workspace'].get_current_workspace()[1]
          )

          -- The current buffer now must be the toc file, so we set our toc entries there
          vim.api.nvim_buf_set_lines(0, 0, -1, false, format(toc_entries))
          vim.cmd('silent! w')
        end)
      end
    )
  end,
}

-- M.handle = {
--   cmd = {
--     ['log.index'] = M.data.open_index,
--     ['log.month'] = M.data.open_month,
--     ['log.yesterday'] = M.data.log_yesterday,
--     ['log.tomorrow'] = M.data.log_tomorrow,
--     ['log.new'] = M.data.log_new,
--     ['log.custom'] = function(e) end,
--     ['log.template'] = M.data.new_template,
--   },
-- }

return M
