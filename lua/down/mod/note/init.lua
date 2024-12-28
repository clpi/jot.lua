local down = require('down')
local u = require 'down.mod.note.util'
local map = require 'down.util.maps'
local config = require('down.config')
local util = require('down.util')
local mod = require('down.mod')

---@class down.mod.Note: down.Mod
local M = mod.new('note', {})

M = setmetatable(M, {
  __index = function(self, k)
    return self.required[k]
  end,
})

local W = M.required['workspace']

M.maps = function()
  map.n(',dn', '<CMD>Down note today<CR>')
  map.n(',dy', '<CMD>Down note yesterday<CR>')
  map.n(',dc', '<CMD>Down note capture<CR>')
  map.n(',dt', '<CMD>Down note tomorrow<CR>')
end

---@class down.mod.note.Data
M.data = {
  week_index = function()
    local wk = os.date('%V')
  end,
  year_index = function()
    local yr = os.date('%Y')
    local ws = M.config.workspace or M.required['workspace'].get_current_workspace()[1]
    local ws_path = M.required['workspace'].get_workspace(ws)
    local ix = M.config.note_folder .. config.pathsep .. yr .. config.pathsep .. M.config.index
    local path = ws_path .. config.pathsep .. ix
    local index_exists = M.required['workspace'].file_exists(path)
    if index_exists then
      M.required['workspace'].open_file(ws, ix)
    else
      M.required['workspace'].new_file(ix, ws)
      M.required['workspace'].open_file(ws, ix)
    end
  end,
  month_index = function()
    local yr = os.date('%Y')
    local mo = os.date('%m')
    local ws = M.config.workspace or M.required['workspace'].get_current_workspace()[1]
    local ws_path = M.required['workspace'].get_workspace(ws)
    local ix = M.config.note_folder
      .. config.pathsep
      .. yr
      .. config.pathsep
      .. mo
      .. config.pathsep
      .. M.config.index
    local path = ws_path .. config.pathsep .. ix
    local index_exists = M.required['workspace'].file_exists(path)
    if index_exists then
      M.required['workspace'].open_file(ws, ix)
    else
      M.required['workspace'].new_file(ix, ws)
      M.required['workspace'].open_file(ws, ix)
    end
  end,
  select_month = function() end,
  note_index = function()
    local ws = M.config.workspace or M.required['workspace'].get_current_workspace()[1]
    local ws_path = M.required['workspace'].get_workspace(ws)
    local ix = M.config.note_folder .. config.pathsep .. M.config.index
    local path = ws_path .. config.pathsep .. ix
    local index_exists = M.required['workspace'].file_exists(path)
    if not index_exists then
      M.required['workspace'].new_file(ix, ws)
    end
    M.required['workspace'].open_file(ws, ix)
  end,
  --- Opens a note entry at the given time
  ---@param time? number #The time to open the note entry at as returned by `os.time()`
  ---@param custom_date? string #A YYYY-mm-dd string that specifies a date to open the note at instead
  open_year = function(time, custom_date)
    -- TODO(vhyrro): Change this to use down dates!
    local workspace = M.config.workspace or M.required['workspace'].get_current_workspace()[1]
    local workspace_path = M.required['workspace'].get_workspace(workspace)
    local folder_name = M.config.note_folder
    local tmpl = M.config.template.year

    if custom_date then
      local year, _month, _day = custom_date:match('^(%d%d%d%d)-(%d%d)-(%d%d)$')

      if not year then
        log.error('Wrong date format: use YYYY-mm-dd')
        return
      end

      time = os.time({
        year = year,
        month = 1,
        day = 1,
      })
      local y = os.date('%Y')
    end

    local path = os.date(
      type(M.config.strategy) == 'function' and M.config.strategy(os.date('*t', time))
        or M.config.strategy,
      time
    )

    local note_file_exists = M.required['workspace'].file_exists(
      workspace_path .. '/' .. folder_name .. config.pathsep .. path
    )

    M.required['workspace'].new_file(folder_name .. config.pathsep .. path, workspace)

    if
      not note_file_exists
      and M.config.template.enable
      and M.required['workspace'].file_exists(workspace_path .. '/' .. folder_name .. '/' .. tmpl)
    then
      vim.cmd('$read ' .. workspace_path .. '/' .. folder_name .. '/' .. tmpl .. '| silent! w')
    end
  end,
  ---@param time? number #The time to open the note entry at as returned by `os.time()`
  ---@param custom_date? string #A YYYY-mm-dd string that specifies a date to open the note at instead
  open_month = function(time, custom_date)
    local workspace = M.config.workspace or M.required['workspace'].get_current_workspace()[1]
    local workspace_path = M.required['workspace'].get_workspace(workspace)
    local folder_name = M.config.note_folder
    local tmpl = M.config.template.month

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

    local note_file_exists = M.required['workspace'].file_exists(
      workspace_path .. '/' .. folder_name .. config.pathsep .. path
    )

    M.required['workspace'].new_file(folder_name .. config.pathsep .. path, workspace)

    if
      not note_file_exists
      and M.config.template.enable
      and M.required['workspace'].file_exists(workspace_path .. '/' .. folder_name .. '/' .. tmpl)
    then
      vim.cmd('$read ' .. workspace_path .. '/' .. folder_name .. '/' .. tmpl .. '| silent! w')
    end
  end,
  capture = function()
    local b, w = M.required['ui.win'].win('today', 'note', 'Down note today')
    -- vim.cmd

    -- Mod.get_mod("ui.win").cmd(w, function()
    --   vim.api.nvim_command("down note today")
    -- end)
    -- pcall(vim.api.nvim_command, ":down note today")
  end,
  --- Opens a note entry at the given time
  ---@param time? number #The time to open the note entry at as returned by `os.time()`
  ---@param custom_date? string #A YYYY-mm-dd string that specifies a date to open the note at instead
  open_note = function(time, custom_date)
    -- TODO(vhyrro): Change this to use down dates!
    local workspace = M.config.workspace or M.required['workspace'].get_current_workspace()[1]
    local workspace_path = M.required['workspace'].get_workspace(workspace)
    local folder_name = M.config.note_folder
    local tmpl = M.config.template.day

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

    local note_file_exists = M.required['workspace'].file_exists(
      workspace_path .. '/' .. folder_name .. config.pathsep .. path
    )

    -- M.required['workspace'].new_file(folder_name .. config.pathsep .. path, workspace)
    M.required['workspace'].new_file(folder_name .. config.pathsep .. path, workspace)

    -- M.required["workspace"].new_file(folder_name..config.pathsep..path, workspace)

    if
      not note_file_exists
      and M.config.template.enable
      and M.required['workspace'].file_exists(workspace_path .. '/' .. folder_name .. '/' .. tmpl)
    then
      vim.cmd('$read ' .. workspace_path .. '/' .. folder_name .. '/' .. tmpl .. '| silent! w')
    end
  end,

  --- Opens a note entry for tomorrow's date
  note_tomorrow = function()
    M.data.open_note(os.time() + 24 * 60 * 60)
  end,

  --- Opens a note entry for yesterday's date
  note_yesterday = function()
    M.data.open_note(os.time() - 24 * 60 * 60)
  end,

  year_prev = function()
    M.data.open_note(os.time() - 24 * 60 * 60 * 365)
  end,
  year_next = function()
    M.data.open_note(os.time() + 24 * 60 * 60 * 365)
  end,
  month_prev = function()
    M.data.open_note(os.time() - 24 * 60 * 60 * 30)
  end,

  month_next = function()
    M.data.open_note(os.time() + 24 * 60 * 60 * 30)
  end,

  week_prev = function()
    M.data.open_note(os.time() - 24 * 60 * 60 * 7)
  end,

  week_next = function()
    M.data.open_note(os.time() + 24 * 60 * 60 * 7)
  end,

  --- Opens a note entry for today's date
  note_today = function()
    M.data.open_note()
  end,

  create_month_template = function()
    local workspace = M.config.workspace
    local folder_name = M.config.note_folder
    local tmpl = M.config.template.month
    M.required['workspace'].new_file(
      folder_name .. config.pathsep .. tmpl,
      workspace or M.required['workspace'].get_current_workspace()[1]
    )
  end,
  --- Creates a template file
  create_year_template = function()
    local workspace = M.config.workspace
    local folder_name = M.config.note_folder
    local tmpl = M.config.template.year
    M.required['workspace'].new_file(
      folder_name .. config.pathsep .. tmpl,
      workspace or M.required['workspace'].get_current_workspace()[1]
    )
  end,
  create_day_template = function()
    local workspace = M.config.workspace
    local folder_name = M.config.note_folder
    local tmpl = M.config.template.day

    M.required['workspace'].new_file(
      folder_name .. config.pathsep .. tmpl,
      workspace or M.required['workspace'].get_current_workspace()[1]
    )
  end,

  --- Opens the toc file
  open_toc = function()
    local workspace = M.config.workspace or M.required['workspace'].get_current_workspace()[1]
    local index = mod.mod_config('workspace').index
    local folder_name = M.config.note_folder

    -- If the toc exists, open it, if not, create it
    if M.required['workspace'].file_exists(folder_name .. config.pathsep .. index) then
      M.required['workspace'].open_file(workspace, folder_name .. config.pathsep .. index)
    else
      M.data.new_toc()
    end
  end,

  --- Creates or updates the toc file
  create_toc = function()
    local workspace = M.config.workspace or M.required['workspace'].get_current_workspace()[1]
    local index = mod.mod_config('workspace').index
    local workspace_path = M.required['workspace'].get_workspace(workspace)
    local workspace_name_for_link = M.config.workspace or ''
    local folder_name = M.config.note_folder

    -- Each entry is a table that contains tables like { yy, mm, dd, link, title }
    local toc_entries = {}

    -- Get a filesystem handle for the files in the note folder
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
      local meta = M.required['workspace'].get_document_metadata(buffer)
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
                          .. M.config.note_folder
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
                  .. M.config.note_folder
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
              local months_text = M.months
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

          M.required['workspace'].new_file(
            folder_name .. config.pathsep .. index,
            workspace or M.required['workspace'].get_current_workspace()[1]
          )

          -- The current buffer now must be the toc file, so we set our toc entries there
          vim.api.nvim_buf_set_lines(0, 0, -1, false, format(toc_entries))
          -- vim.cmd("w")
        end)
      end
    )
  end,
}

---@class (exact) down.mod.note.Config
M.config = {
  -- Which workspace to use for the note files, the base behaviour
  -- is to use the current workspace.
  --
  -- It is recommended to set this to a static workspace, but the most optimal
  -- behaviour may vary from workflow to workflow.
  workspace = nil,

  -- The name for the folder in which the note files are put.
  note_folder = 'note',

  index = 'index.md',

  -- The strategy to use to create directories.
  -- May be "flat" (`2022-03-02.down`), "nested" (`2022/03/02.down`),
  -- a lua string with the format given to `os.date()` or a lua function
  -- that returns a lua string with the same format.
  strategy = 'nested',

  -- The name of the template file to use when running `:down note template`.
  template = {

    enable = true,
    day = 'day.md',
    month = 'month.md',
    year = 'month.md',
    week = 'week.md',
    default = 'note.md',
  },

  -- Formatter function used to generate the toc file.
  -- Receives a table that contains tables like { yy, mm, dd, link, title }.
  --
  -- The function must return a table of strings.
  toc_format = nil,
}

M.config.strategies = {
  flat = '%Y-%m-%d.md',
  nested = '%Y' .. config.pathsep .. '%m' .. config.pathsep .. '%d.md',
}

---@param event down.Event
M.on = function(event)
  local ty = event.split[1]
  local ev = event.split[2]
  if ty == 'cmd' then
    if ev == 'note' or ev == 'note.index' then
      M.data.note_index()
    elseif ev == 'note.week' or ev == 'note.week.index' then
      M.data.week_index()
    elseif event.split[2] == 'note.week.previous' then
      M.data.week_prev()
    elseif event.split[2] == 'note.week.next' then
      M.data.week_next()
    elseif event.split[2] == 'note.month.previous' then
      print('TODO:month previous')
    elseif event.split[2] == 'note.month.next' then
      print('TODO:month next')
    elseif event.split[2] == 'note.year.previous' then
      print('TODO:year prev')
    elseif event.split[2] == 'note.year.next' then
      print('TODO:year next')
    elseif ev == 'note.year' or ev == 'note.year.index' then
      M.data.year_index()
    elseif ev == 'note.month' or ev == 'note.month.index' then
      M.data.month_index()
    elseif event.split[2] == 'note.capture' then
      M.data.capture()
    elseif event.split[2] == 'note.tomorrow' then
      M.data.note_tomorrow()
    elseif event.split[2] == 'note.yesterday' then
      M.data.note_yesterday()
    elseif event.split[2] == 'calendar' then
      if not event.body[1] then
        local cal = M.required['ui.calendar']
        if not cal then
          print('[ERROR]: `ui.calendar` is not loaded!')
          return
        end
        cal.select_date({
          callback = vim.schedule_wrap(function(osdate)
            M.data.open_note(
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
        M.data.open_note(nil, event.body[1])
      end
    elseif event.split[2] == 'note.calendar' then
      if not event.body[1] then
        local cal = M.required['ui.calendar']
        if not cal then
          print('[ERROR]: `ui.calendar` is not loaded!')
          return
        end
        cal.select_date({
          callback = vim.schedule_wrap(function(osdate)
            M.data.open_note(
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
        M.data.open_note(nil, event.body[1])
      end
    elseif ev == 'note.today' then
      M.data.note_today()
    elseif ev == 'note.template' then
      M.data.new_day_template()
    elseif ev == 'note.template.day' then
      M.data.new_template()
    elseif ev == 'note.template.week' then
      -- M.data.new_template()
      print('TODO note template week index')
    elseif ev == 'note.template.month' then
      -- M.data.new_template()
      print('TODO note template month')
    elseif ev == 'note.template.year' then
      -- M.data.new_template()
      print('TODO note template year')
    elseif ev == 'note.toc.open' then
      M.data.open_toc()
    elseif ev == 'note.toc.update' then
      M.data.new_toc()
    end
  end
end

M.load = function()
  if M.config.strategies[M.config.strategy] then
    M.config.strategy = M.config.strategies[M.config.strategy]
  end
  require('down.mod').await('cmd', function(cmd)
    cmd.add_commands_from_table({
      calendar = {
        max_args = 1,
        name = 'calendar',
      }, -- format :yyyy-mm-dd
      note = {
        min_args = 1,
        max_args = 2,
        subcommands = {
          index = { args = 0, name = 'note.index' },
          month = {
            max_args = 1,
            name = 'note.month',
            subcommands = {
              index = { args = 0, name = 'note.month.index' },
              previous = {
                args = 0,
                name = 'note.month.previous',
              },
              next = {
                args = 0,
                name = 'note.month.next',
              },
            },
          },
          week = {
            subcommands = {
              index = { args = 0, name = 'note.week.index' },
              previous = {
                args = 0,
                name = 'note.week.previous',
              },
              next = {
                args = 0,
                name = 'note.week.next',
              },
            },
            max_args = 1,
            name = 'note.week',
          },
          year = {
            max_args = 1,
            name = 'note.year',
            subcommands = {
              index = { args = 0, name = 'note.year.index' },
              previous = {
                args = 0,
                name = 'note.year.previous',
              },
              next = {
                args = 0,
                name = 'note.year.next',
              },
            },
          },
          capture = { args = 0, name = 'note.capture' },
          tomorrow = { args = 0, name = 'note.tomorrow' },
          yesterday = { args = 0, name = 'note.yesterday' },
          today = { args = 0, name = 'note.today' },
          calendar = {
            max_args = 1,
            name = 'note.calendar',
          }, -- format :yyyy-mm-dd
          template = {
            subcommands = {
              year = {
                name = 'notes.template.year',
                args = 0,
              },
              week = {
                name = 'notes.template.week',
                args = 0,
              },
              month = {
                name = 'notes.template.month',
                args = 0,
              },
              day = {
                name = 'notes.template.day',
                args = 0,
              },
            },
            args = 0,
            name = 'note.template',
          },
          toc = {
            args = 1,
            name = 'note.toc',
            subcommands = {
              open = { args = 0, name = 'note.toc.open' },
              update = { args = 0, name = 'note.toc.update' },
            },
          },
        },
      },
    })
  end)
end

---@return down.mod.Setup
M.setup = function()
  return {
    loaded = true,
    requires = {
      'cmd',
      'ui.win',
      'ui.calendar',
      'data',
      'data.template',
      'workspace',
      'tool.treesitter',
    },
  }
end

---@class down.mod.note.Subscribed
M.subscribed = {
  cmd = {
    ['note.index'] = true,
    ['note.month'] = true,
    ['note.week'] = true,
    ['note.year'] = true,
    ['note'] = true,
    ['note.month.previous'] = true,
    ['note.week.previous'] = true,
    ['note.year.previous'] = true,
    ['note.month.next'] = true,
    ['note.week.next'] = true,
    ['note.year.next'] = true,
    ['note.month.index'] = true,
    ['note.week.index'] = true,
    ['note.year.index'] = true,
    ['note.yesterday'] = true,
    ['note.tomorrow'] = true,
    ['note.capture'] = true,
    ['note.today'] = true,
    ['calendar'] = true,
    ['note.calendar'] = true,
    ['note.template'] = true,
    ['note.template.day'] = true,
    ['note.template.month'] = true,
    ['note.template.week'] = true,
    ['note.template.year'] = true,
    ['note.toc.update'] = true,
    ['note.toc.open'] = true,
  },
}

return M
