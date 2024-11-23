--[[
    file: note
    title: Dear note...
    description: The note M allows you to take personal note with zero friction.
    summary: Easily track a note within word.
    ---
The note M exposes a total of six commands.
The first three, `:word note today|yesterday|tomorrow`, allow you to access entries
for a given time relative to today. A file will be opened with the respective date as a `.word` file.

The fourth command, `:word note custom`, allows you to specify a custom date as an argument.
The date must be formatted according to the `YYYY-mm-dd` format, e.g. `2023-01-01`.

The `:word note template` command creates a template file which will be used as the base whenever
a new note entry is created.

Last but not least, the `:word note toc open|update` commands open or create/update a Table of Contents
file found in the root of the note. This file contains link to all other note entries, alongside
their titles.
--]]

local word = require("word")
local config, lib, log, mod = require("word.config").config, word.lib, word.log, word.mod

local M = Mod.create("note")


M.weekdays = {
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
}
M.months = {
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
}
M.number_to_weekday = function(n)
  return M.weekday[n]
end
M.number_to_month = function(n)
  return M.months[n]
end
M.year = tonumber(os.date("%Y"))
M.month = tonumber(os.date("%m"))
M.day = tonumber(os.date("%d"))
M.timetable = {
  year = M.year,
  month = M.month,
  day = M.day,
  hour = 0,
  min = 0,
  sec = 0,
}
M.time = os.time()
M.weekday = tonumber(os.date("%w", os.time(M.timetable)))
M.setup = function()
  return {
    success = true,
    requires = {
      "data",
      "workspace",
      "integration.treesitter",
    },
  }
end


M.private = {
  week_index = function()

  end,
  year_index = function()
    local yr = os.date("%Y")
    local ws = M.config.public.workspace or M.required.workspace.get_current_workspace()[1]
    local ws_path = M.required.workspace.get_workspace(ws)
    local ix = M.config.public.note_folder .. config.pathsep .. yr .. config.pathsep .. "index.md"
    local path = ws_path .. config.pathsep .. ix
    local index_exists = M.required.workspace.file_exists(path)
    if index_exists then
      M.required.workspace.open_file(ws, ix)
    else
      M.required.workspace.create_file(ix, ws)
      M.required.workspace.open_file(ws, ix)
    end
  end,
  month_index = function()
    local yr = os.date("%Y")
    local mo = os.date("%m")
    local ws = M.config.public.workspace or M.required.workspace.get_current_workspace()[1]
    local ws_path = M.required.workspace.get_workspace(ws)
    local ix = M.config.public.note_folder ..
        config.pathsep .. yr .. config.pathsep .. mo .. config.pathsep .. "index.md"
    local path = ws_path .. config.pathsep .. ix
    local index_exists = M.required.workspace.file_exists(path)
    if index_exists then
      M.required.workspace.open_file(ws, ix)
    else
      M.required.workspace.create_file(ix, ws)
      M.required.workspace.open_file(ws, ix)
    end
  end,
  select_month = function()

  end,
  note_index = function()
    local ws = M.config.public.workspace or M.required.workspace.get_current_workspace()[1]
    local ws_path = M.required.workspace.get_workspace(ws)
    local ix = M.config.public.note_folder .. config.pathsep .. "index.md"
    local path = ws_path .. config.pathsep .. ix
    local index_exists = M.required.workspace.file_exists(path)
    if index_exists then
      M.required.workspace.open_file(ws, ix)
    else
      M.required.workspace.create_file(ix, ws)
      M.required.workspace.open_file(ws, ix)
    end
  end,
  --- Opens a note entry at the given time
  ---@param time? number #The time to open the note entry at as returned by `os.time()`
  ---@param custom_date? string #A YYYY-mm-dd string that specifies a date to open the note at instead
  open_year = function(time, custom_date)
    -- TODO(vhyrro): Change this to use word dates!
    local workspace = M.config.public.workspace or M.required["workspace"].get_current_workspace()[1]
    local workspace_path = M.required["workspace"].get_workspace(workspace)
    local folder_name = M.config.public.note_folder
    local tmpl = M.config.public.template.year

    if custom_date then
      local year, _month, _day = custom_date:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")

      if not year then
        log.error("Wrong date format: use YYYY-mm-dd")
        return
      end

      time = os.time({
        year = year,
      })
      local y = os.date("%Y")
    end

    local path = os.date(
      type(M.config.public.strategy) == "function" and M.config.public.strategy(os.date("*t", time))
      or M.config.public.strategy,
      time
    )


    local note_file_exists =
        M.required["workspace"].file_exists(workspace_path .. "/" .. folder_name .. config.pathsep .. path)

    M.required["workspace"].create_file(folder_name .. config.pathsep .. path, workspace)

    -- M.required["workspace"].create_file(folder_name .. config.pathsep .. path, workspace)

    if
        not note_file_exists
        and M.config.public.template.enable
        and M.required["workspace"].file_exists(workspace_path .. "/" .. folder_name .. "/" .. tmpl)
    then
      vim.cmd("$read " .. workspace_path .. "/" .. folder_name .. "/" .. tmpl .. "| w")
    end
  end,
  ---@param time? number #The time to open the note entry at as returned by `os.time()`
  ---@param custom_date? string #A YYYY-mm-dd string that specifies a date to open the note at instead
  open_month = function(time, custom_date)
    -- TODO(vhyrro): Change this to use word dates!
    local workspace = M.config.public.workspace or M.required["workspace"].get_current_workspace()[1]
    local workspace_path = M.required["workspace"].get_workspace(workspace)
    local folder_name = M.config.public.note_folder
    local tmpl = M.config.public.template.month

    if custom_date then
      local year, month, day = custom_date:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")

      if not year or not month or not day then
        log.error("Wrong date format: use YYYY-mm-dd")
        return
      end

      time = os.time({
        year = year,
        month = month,
        day = day,
      })
    end

    local path = os.date(
      type(M.config.public.strategy) == "function" and M.config.public.strategy(os.date("*t", time))
      or M.config.public.strategy,
      time
    )


    local note_file_exists =
        M.required["workspace"].file_exists(workspace_path .. "/" .. folder_name .. config.pathsep .. path)

    M.required["workspace"].create_file(folder_name .. config.pathsep .. path, workspace)

    -- M.required["workspace"].create_file(folder_name .. config.pathsep .. path, workspace)

    if
        not note_file_exists
        and M.config.public.template.enable
        and M.required["workspace"].file_exists(workspace_path .. "/" .. folder_name .. "/" .. tmpl)
    then
      vim.cmd("$read " .. workspace_path .. "/" .. folder_name .. "/" .. tmpl .. "| w")
    end
  end,
  --- Opens a note entry at the given time
  ---@param time? number #The time to open the note entry at as returned by `os.time()`
  ---@param custom_date? string #A YYYY-mm-dd string that specifies a date to open the note at instead
  open_note = function(time, custom_date)
    -- TODO(vhyrro): Change this to use word dates!
    local workspace = M.config.public.workspace or M.required["workspace"].get_current_workspace()[1]
    local workspace_path = M.required["workspace"].get_workspace(workspace)
    local folder_name = M.config.public.note_folder
    local tmpl = M.config.public.template.day

    if custom_date then
      local year, month, day = custom_date:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")

      if not year or not month or not day then
        log.error("Wrong date format: use YYYY-mm-dd")
        return
      end

      time = os.time({
        year = year,
        month = month,
        day = day,
      })
    end

    local path = os.date(
      type(M.config.public.strategy) == "function" and M.config.public.strategy(os.date("*t", time))
      or M.config.public.strategy,
      time
    )


    local note_file_exists =
        M.required["workspace"].file_exists(workspace_path .. "/" .. folder_name .. config.pathsep .. path)

    M.required["workspace"].create_file(folder_name .. config.pathsep .. path, workspace)

    -- M.required["workspace"].create_file(folder_name .. config.pathsep .. path, workspace)

    if
        not note_file_exists
        and M.config.public.template.enable
        and M.required["workspace"].file_exists(workspace_path .. "/" .. folder_name .. "/" .. tmpl)
    then
      vim.cmd("$read " .. workspace_path .. "/" .. folder_name .. "/" .. tmpl .. "| w")
    end
  end,

  --- Opens a note entry for tomorrow's date
  note_tomorrow = function()
    M.private.open_note(os.time() + 24 * 60 * 60)
  end,

  --- Opens a note entry for yesterday's date
  note_yesterday = function()
    M.private.open_note(os.time() - 24 * 60 * 60)
  end,

  year_prev = function()
    M.private.open_note(os.time() - 24 * 60 * 60 * 365)
  end,
  year_next = function()
    M.private.open_note(os.time() + 24 * 60 * 60 * 365)
  end,
  month_prev = function()
    M.private.open_note(os.time() - 24 * 60 * 60 * 30)
  end,

  month_next = function()
    M.private.open_note(os.time() + 24 * 60 * 60 * 30)
  end,

  week_prev = function()
    M.private.open_note(os.time() - 24 * 60 * 60 * 7)
  end,

  week_next = function()
    M.private.open_note(os.time() + 24 * 60 * 60 * 7)
  end,

  --- Opens a note entry for today's date
  note_today = function()
    M.private.open_note()
  end,

  create_month_template = function()
    local workspace = M.config.public.workspace
    local folder_name = M.config.public.note_folder
    local tmpl = M.config.public.template.month
    M.required.workspace.create_file(
      folder_name .. config.pathsep .. tmpl,
      workspace or M.required.workspace.get_current_workspace()[1]
    )
  end,
  --- Creates a template file
  create_year_template = function()
    local workspace = M.config.public.workspace
    local folder_name = M.config.public.note_folder
    local tmpl = M.config.public.template.year
    M.required.workspace.create_file(
      folder_name .. config.pathsep .. tmpl,
      workspace or M.required.workspace.get_current_workspace()[1]
    )
  end,
  create_day_template = function()
    local workspace = M.config.public.workspace
    local folder_name = M.config.public.note_folder
    local tmpl = M.config.public.template.day

    M.required.workspace.create_file(
      folder_name .. config.pathsep .. tmpl,
      workspace or M.required.workspace.get_current_workspace()[1]
    )
  end,

  --- Opens the toc file
  open_toc = function()
    local workspace = M.config.public.workspace or M.required["workspace"].get_current_workspace()[1]
    local index = mod.get_mod_config("workspace").index
    local folder_name = M.config.public.note_folder

    -- If the toc exists, open it, if not, create it
    if M.required.workspace.file_exists(folder_name .. config.pathsep .. index) then
      M.required.workspace.open_file(workspace, folder_name .. config.pathsep .. index)
    else
      M.private.create_toc()
    end
  end,

  --- Creates or updates the toc file
  create_toc = function()
    local workspace = M.config.public.workspace or M.required["workspace"].get_current_workspace()[1]
    local index = mod.get_mod_config("workspace").index
    local workspace_path = M.required["workspace"].get_workspace(workspace)
    local workspace_name_for_link = M.config.public.workspace or ""
    local folder_name = M.config.public.note_folder

    -- Each entry is a table that contains tables like { yy, mm, dd, link, title }
    local toc_entries = {}

    -- Get a filesystem handle for the files in the note folder
    -- path is for each subfolder
    local get_fs_handle = function(path)
      path = path or ""
      local handle =
          vim.loop.fs_scandir(workspace_path .. config.pathsep .. folder_name .. config.pathsep .. path)

      if type(handle) ~= "userdata" then
        error(lib.lazy_string_concat("Failed to scan directory '", workspace, path, "': ", handle))
      end

      return handle
    end

    -- Gets the title from the metadata of a file, must be called in a vim.schedule
    local get_title = function(file)
      local buffer = vim.fn.bufadd(workspace_path .. config.pathsep .. folder_name .. config.pathsep .. file)
      local meta = M.required["workspace"].get_document_metadata(buffer)
      return meta.title
    end

    vim.loop.fs_scandir(workspace_path .. config.pathsep .. folder_name .. config.pathsep, function(err, handle)
      assert(not err, lib.lazy_string_concat("Unable to generate TOC for directory '", folder_name, "' - ", err))

      while true do
        -- Name corresponds to either a YYYY-mm-dd.word file, or just the year ("nested" strategy)
        local name, type = vim.loop.fs_scandir_next(handle) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>

        if not name then
          break
        end

        -- Handle nested entries
        if type == "directory" then
          local years_handle = get_fs_handle(name)
          while true do
            -- mname is the month
            local mname, mtype = vim.loop.fs_scandir_next(years_handle)

            if not mname then
              break
            end

            if mtype == "directory" then
              local months_handle = get_fs_handle(name .. config.pathsep .. mname)
              while true do
                -- dname is the day
                local dname, dtype = vim.loop.fs_scandir_next(months_handle)

                if not dname then
                  break
                end

                -- If it's a .word file, also ensure it is a day entry
                if dtype == "file" and string.match(dname, "%d%d%.md") then
                  -- Split the file name
                  local file = vim.split(dname, ".", { plain = true })

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
                      "{:$"
                      .. workspace_name_for_link
                      .. config.pathsep
                      .. M.config.public.note_folder
                      .. config.pathsep
                      .. name
                      .. config.pathsep
                      .. mname
                      .. config.pathsep
                      .. file[1]
                      .. ":}",
                      title,
                    })
                  end)
                end
              end
            end
          end
        end

        -- Handles flat entries
        -- If it is a .word file, but it's not any user generated file.
        -- The match is here to avoid handling files made by the user, like a template file, or
        -- the toc file
        if type == "file" and string.match(name, "%d+-%d+-%d+%.md") then
          -- Split yyyy-mm-dd to a table
          local file = vim.split(name, ".", { plain = true })
          local parts = vim.split(file[1], "-")

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
              "{:$"
              .. workspace_name_for_link
              .. config.pathsep
              .. M.config.public.note_folder
              .. config.pathsep
              .. file[1]
              .. ":}",
              title,
            })
          end)
        end
      end

      vim.schedule(function()
        -- Gets a base format for the entries
        local format = M.config.public.toc_format
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
                  table.insert(output, "* " .. current_year)
                end
                if not current_month or current_month < entry[2] then
                  current_month = entry[2]
                  table.insert(output, "** " .. months_text[current_month])
                end

                -- Prints the file link
                table.insert(output, "   " .. entry[4] .. string.format("[%s]", entry[5]))
              end

              return output
            end

        M.required["workspace"].create_file(
          folder_name .. config.pathsep .. index,
          workspace or M.required["workspace"].get_current_workspace()[1]
        )

        -- The current buffer now must be the toc file, so we set our toc entries there
        vim.api.nvim_buf_set_lines(0, 0, -1, false, format(toc_entries))
        vim.cmd("w")
      end)
    end)
  end,
}

M.config.public = {
  -- Which workspace to use for the note files, the base behaviour
  -- is to use the current workspace.
  --
  -- It is recommended to set this to a static workspace, but the most optimal
  -- behaviour may vary from workflow to workflow.
  workspace = nil,

  -- The name for the folder in which the note files are put.
  note_folder = "note",

  -- The strategy to use to create directories.
  -- May be "flat" (`2022-03-02.word`), "nested" (`2022/03/02.word`),
  -- a lua string with the format given to `os.date()` or a lua function
  -- that returns a lua string with the same format.
  strategy = "nested",

  -- The name of the template file to use when running `:word note template`.
  template = {

    enable = true,
    day = "day.md",
    month = "month.md",
    year = "month.md",
    week = "week.md",
    default = "note.md",

  },


  -- Formatter function used to generate the toc file.
  -- Receives a table that contains tables like { yy, mm, dd, link, title }.
  --
  -- The function must return a table of strings.
  toc_format = nil,
}

M.config.private = {
  strategies = {
    flat = "%Y-%m-%d.md",
    nested = "%Y" .. config.pathsep .. "%m" .. config.pathsep .. "%d.md",
  },
}

---@class base.note
M.public = {
  version = "0.1.0",
}

M.load = function()
  if M.config.private.strategies[M.config.public.strategy] then
    M.config.public.strategy = M.config.private.strategies[M.config.public.strategy]
  end

  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      note = {
        min_args = 1,
        max_args = 2,
        subcommands = {
          index = { args = 0, name = "note.index" },
          month = {
            max_args = 1,
            name = "note.month",
            subcommands = {
              index = { args = 0, name = "note.month.index" },
              previous = {
                args = 0,
                name = "note.month.previous",
              },
              next = {
                args = 0,
                name = "note.month.next",
              },
            },
          },
          week = {
            subcommands = {
              index = { args = 0, name = "note.week.index" },
              previous = {
                args = 0,
                name = "note.week.previous",
              },
              next = {
                args = 0,
                name = "note.week.next",
              },
            },
            max_args = 1,
            name = "note.week"
          },
          year = {
            max_args = 1,
            name = "note.year",
            subcommands = {
              index = { args = 0, name = "note.year.index" },
              previous = {
                args = 0,
                name = "note.year.previous",
              },
              next = {
                args = 0,
                name = "note.year.next",
              },
            },
          },
          tomorrow = { args = 0, name = "note.tomorrow" },
          yesterday = { args = 0, name = "note.yesterday" },
          today = { args = 0, name = "note.today" },
          calendar = { max_args = 1, name = "note.calendar" }, -- format :yyyy-mm-dd
          template = {
            subcommands = {
              year = {
                name = "notes.template.year",
                args = 0
              },
              week = {
                name = "notes.template.week",
                args = 0
              },
              month = {
                name = "notes.template.month",
                args = 0
              },
              day = {
                name = "notes.template.day",
                args = 0
              }
            },
            args = 0,
            name = "note.template"
          },
          toc = {
            args = 1,
            name = "note.toc",
            subcommands = {
              open = { args = 0, name = "note.toc.open" },
              update = { args = 0, name = "note.toc.update" },
            },
          },
        },
      },
    })
  end)
end

M.on_event = function(event)
  if event.split_type[1] == "cmd" then
    if event.split_type[2] == "note.index" then
      M.private.note_index()
    elseif event.split_type[2] == "note.week" or event.split_type[2] == "note.week.index" then
      M.private.week_index()
    elseif event.split_type[2] == "note.week.previous" then
      M.private.week_prev()
    elseif event.split_type[2] == "note.week.next" then
      M.private.week_next()
    elseif event.split_type[2] == "note.month.previous" then
      M.private.week_prev()
    elseif event.split_type[2] == "note.month.next" then
      M.private.week_next()
    elseif event.split_type[2] == "note.year.previous" then
      M.private.week_prev()
    elseif event.split_type[2] == "note.year.next" then
      M.private.week_next()
    elseif event.split_type[2] == "note.year" or event.split_type[2] == "note.year.index" then
      M.private.year_index()
    elseif event.split_type[2] == "note.month" or event.split_type[2] == "note.month.index" then
      M.private.month_index()
    elseif event.split_type[2] == "note.tomorrow" then
      M.private.note_tomorrow()
    elseif event.split_type[2] == "note.yesterday" then
      M.private.note_yesterday()
    elseif event.split_type[2] == "note.calendar" then
      if not event.content[1] then
        local calendar = mod.get_mod("ui.calendar")

        if not calendar then
          log.error("[ERROR]: `base.calendar` is not loaded! Said M is required for this operation.")
          return
        end

        calendar.select_date({
          callback = vim.schedule_wrap(function(osdate)
            M.private.open_note(
              nil,
              string.format("%04d", osdate.year)
              .. "-"
              .. string.format("%02d", osdate.month)
              .. "-"
              .. string.format("%02d", osdate.day)
            )
          end),
        })
      else
        M.private.open_note(nil, event.content[1])
      end
    elseif event.split_type[2] == "note.today" then
      M.private.note_today()
    elseif event.split_type[2] == "note.template" then
      M.private.create_day_template()
    elseif event.split_type[2] == "note.template.day" then
      M.private.create_template()
    elseif event.split_type[2] == "note.template.week" then
      M.private.create_template()
    elseif event.split_type[2] == "note.template.month" then
      M.private.create_template()
    elseif event.split_type[2] == "note.template.year" then
      M.private.create_template()
    elseif event.split_type[2] == "note.toc.open" then
      M.private.open_toc()
    elseif event.split_type[2] == "note.toc.update" then
      M.private.create_toc()
    end
  end
end

M.events.subscribed = {
  cmd = {
    ["note.index"] = true,
    ["note.month"] = true,
    ["note.week"] = true,
    ["note.year"] = true,
    ["note.month.previous"] = true,
    ["note.week.previous"] = true,
    ["note.year.previous"] = true,
    ["note.month.next"] = true,
    ["note.week.next"] = true,
    ["note.year.next"] = true,
    ["note.month.index"] = true,
    ["note.week.index"] = true,
    ["note.year.index"] = true,
    ["note.yesterday"] = true,
    ["note.tomorrow"] = true,
    ["note.today"] = true,
    ["note.calendar"] = true,
    ["note.template"] = true,
    ["note.template.day"] = true,
    ["note.template.month"] = true,
    ["note.template.week"] = true,
    ["note.template.year"] = true,
    ["note.toc.update"] = true,
    ["note.toc.open"] = true,
  },
}

return M
