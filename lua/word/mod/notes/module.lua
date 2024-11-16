--[[
    file: notes
    title: Dear diary...
    description: The notes module allows you to take personal notes with zero friction.
    summary: Easily track a notes within word.
    ---
The notes module exposes a total of six commands.
The first three, `:word notes today|yesterday|tomorrow`, allow you to access entries
for a given time relative to today. A file will be opened with the respective date as a `.word` file.

The fourth command, `:word notes custom`, allows you to specify a custom date as an argument.
The date must be formatted according to the `YYYY-mm-dd` format, e.g. `2023-01-01`.

The `:word notes template` command creates a template file which will be used as the base whenever
a new notes entry is created.

Last but not least, the `:word notes toc open|update` commands open or create/update a Table of Contents
file found in the root of the notes. This file contains link to all other notes entries, alongside
their titles.
--]]

local word = require("word")
local config, lib, log, mod = word.config, word.lib, word.log, word.mod

local module = mod.create("notes")

module.examples = {
    ["Changing TOC format to divide year in quarters"] = function()
        -- In your ["notes"] options, change toc_format to a function like this:

        require("word").setup({
            load = {
                -- ...
                ["notes"] = {
                    config = {
                        -- ...
                        toc_format = function(entries)
                            -- Convert the entries into a certain format

                            local output = {}
                            local current_year
                            local current_quarter
                            local last_quarter
                            local current_month
                            for _, entry in ipairs(entries) do
                                -- Don't print the year if it hasn't changed
                                if not current_year or current_year < entry[1] then
                                    current_year = entry[1]
                                    current_month = nil
                                    table.insert(output, "* " .. current_year)
                                end

                                -- Check to which quarter the current month corresponds to
                                if entry[2] <= 3 then
                                    current_quarter = 1
                                elseif entry[2] <= 6 then
                                    current_quarter = 2
                                elseif entry[2] <= 9 then
                                    current_quarter = 3
                                else
                                    current_quarter = 4
                                end

                                -- If the current month corresponds to another quarter, print it
                                if current_quarter ~= last_quarter then
                                    table.insert(output, "** Quarter " .. current_quarter)
                                    last_quarter = current_quarter
                                end

                                -- Don't print the month if it hasn't changed
                                if not current_month or current_month < entry[2] then
                                    current_month = entry[2]
                                    table.insert(output, "*** Month " .. current_month)
                                end

                                -- Prints the file link
                                table.insert(output, "   " .. entry[4] .. string.format("[%s]", entry[5]))
                            end

                            return output
                        end,
                        -- ...
                    },
                },
            },
        })
    end,
}

module.setup = function()
    return {
        success = true,
        requires = {
            "workspace",
            "treesitter",
        },
    }
end

module.private = {
    --- Opens a diary entry at the given time
    ---@param time? number #The time to open the notes entry at as returned by `os.time()`
    ---@param custom_date? string #A YYYY-mm-dd string that specifies a date to open the diary at instead
    open_diary = function(time, custom_date)
        -- TODO(vhyrro): Change this to use word dates!
        local workspace = module.config.public.workspace or module.required["workspace"].get_current_workspace()[1]
        local folder_name = module.config.public.notes_folder
        local template_name = module.config.public.template_name

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
            type(module.config.public.strategy) == "function" and module.config.public.strategy(os.date("*t", time))
            or module.config.public.strategy,
            time
        )

        local workspace_path = module.required["workspace"].get_workspace(workspace)

        local notes_file_exists =
            module.required["workspace"].file_exists(workspace_path .. "/" .. folder_name .. config.pathsep .. path)

        module.required["workspace"].create_file(folder_name .. config.pathsep .. path, workspace)

        module.required["workspace"].create_file(folder_name .. config.pathsep .. path, workspace)

        if
            not notes_file_exists
            and module.config.public.use_template
            and module.required["workspace"].file_exists(workspace_path .. "/" .. folder_name .. "/" .. template_name)
        then
            vim.cmd("$read " .. workspace_path .. "/" .. folder_name .. "/" .. template_name .. "| w")
        end
    end,

    --- Opens a diary entry for tomorrow's date
    diary_tomorrow = function()
        module.private.open_diary(os.time() + 24 * 60 * 60)
    end,

    --- Opens a diary entry for yesterday's date
    diary_yesterday = function()
        module.private.open_diary(os.time() - 24 * 60 * 60)
    end,

    --- Opens a diary entry for today's date
    diary_today = function()
        module.private.open_diary()
    end,

    --- Creates a template file
    create_template = function()
        local workspace = module.config.public.workspace
        local folder_name = module.config.public.notes_folder
        local template_name = module.config.public.template_name

        module.required["workspace"].create_file(
            folder_name .. config.pathsep .. template_name,
            workspace or module.required["workspace"].get_current_workspace()[1]
        )
    end,

    --- Opens the toc file
    open_toc = function()
        local workspace = module.config.public.workspace or module.required["workspace"].get_current_workspace()[1]
        local index = mod.get_module_config("workspace").index
        local folder_name = module.config.public.notes_folder

        -- If the toc exists, open it, if not, create it
        if module.required["workspace"].file_exists(folder_name .. config.pathsep .. index) then
            module.required["workspace"].open_file(workspace, folder_name .. config.pathsep .. index)
        else
            module.private.create_toc()
        end
    end,

    --- Creates or updates the toc file
    create_toc = function()
        local workspace = module.config.public.workspace or module.required["workspace"].get_current_workspace()[1]
        local index = mod.get_module_config("workspace").index
        local workspace_path = module.required["workspace"].get_workspace(workspace)
        local workspace_name_for_link = module.config.public.workspace or ""
        local folder_name = module.config.public.notes_folder

        -- Each entry is a table that contains tables like { yy, mm, dd, link, title }
        local toc_entries = {}

        -- Get a filesystem handle for the files in the notes folder
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
            local meta = module.required["treesitter"].get_document_metadata(buffer)
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
                                            .. module.config.public.notes_folder
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
                            .. module.config.public.notes_folder
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
                local format = module.config.public.toc_format
                    or function(entries)
                        local months_text = {
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

                module.required["workspace"].create_file(
                    folder_name .. config.pathsep .. index,
                    workspace or module.required["workspace"].get_current_workspace()[1]
                )

                -- The current buffer now must be the toc file, so we set our toc entries there
                vim.api.nvim_buf_set_lines(0, 0, -1, false, format(toc_entries))
                vim.cmd("w")
            end)
        end)
    end,
}

module.config.public = {
    -- Which workspace to use for the notes files, the base behaviour
    -- is to use the current workspace.
    --
    -- It is recommended to set this to a static workspace, but the most optimal
    -- behaviour may vary from workflow to workflow.
    workspace = nil,

    -- The name for the folder in which the notes files are put.
    notes_folder = "notes",

    -- The strategy to use to create directories.
    -- May be "flat" (`2022-03-02.word`), "nested" (`2022/03/02.word`),
    -- a lua string with the format given to `os.date()` or a lua function
    -- that returns a lua string with the same format.
    strategy = "nested",

    -- The name of the template file to use when running `:word notes template`.
    template_name = "template.md",

    -- Whether to apply the template file to new notes entries.
    use_template = true,

    -- Formatter function used to generate the toc file.
    -- Receives a table that contains tables like { yy, mm, dd, link, title }.
    --
    -- The function must return a table of strings.
    toc_format = nil,
}

module.config.private = {
    strategies = {
        flat = "%Y-%m-%d.md",
        nested = "%Y" .. config.pathsep .. "%m" .. config.pathsep .. "%d.md",
    },
}

---@class base.notes
module.public = {
    version = "0.0.9",
}

module.load = function()
    if module.config.private.strategies[module.config.public.strategy] then
        module.config.public.strategy = module.config.private.strategies[module.config.public.strategy]
    end

    mod.await("cmd", function(cmd)
        cmd.add_commands_from_table({
            notes = {
                min_args = 1,
                max_args = 2,
                subcommands = {
                    tomorrow = { args = 0, name = "notes.tomorrow" },
                    yesterday = { args = 0, name = "notes.yesterday" },
                    today = { args = 0, name = "notes.today" },
                    custom = { max_args = 1, name = "notes.custom" }, -- format :yyyy-mm-dd
                    template = { args = 0, name = "notes.template" },
                    toc = {
                        args = 1,
                        name = "notes.toc",
                        subcommands = {
                            open = { args = 0, name = "notes.toc.open" },
                            update = { args = 0, name = "notes.toc.update" },
                        },
                    },
                },
            },
        })
    end)
end

module.on_event = function(event)
    if event.split_type[1] == "cmd" then
        if event.split_type[2] == "notes.tomorrow" then
            module.private.diary_tomorrow()
        elseif event.split_type[2] == "notes.yesterday" then
            module.private.diary_yesterday()
        elseif event.split_type[2] == "notes.custom" then
            if not event.content[1] then
                local calendar = mod.get_module("calendar")

                if not calendar then
                    log.error("[ERROR]: `base.calendar` is not loaded! Said module is required for this operation.")
                    return
                end

                calendar.select_date({
                    callback = vim.schedule_wrap(function(osdate)
                        module.private.open_diary(
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
                module.private.open_diary(nil, event.content[1])
            end
        elseif event.split_type[2] == "notes.today" then
            module.private.diary_today()
        elseif event.split_type[2] == "notes.template" then
            module.private.create_template()
        elseif event.split_type[2] == "notes.toc.open" then
            module.private.open_toc()
        elseif event.split_type[2] == "notes.toc.update" then
            module.private.create_toc()
        end
    end
end

module.events.subscribed = {
    ["cmd"] = {
        ["notes.yesterday"] = true,
        ["notes.tomorrow"] = true,
        ["notes.today"] = true,
        ["notes.custom"] = true,
        ["notes.template"] = true,
        ["notes.toc.update"] = true,
        ["notes.toc.open"] = true,
    },
}

return module
