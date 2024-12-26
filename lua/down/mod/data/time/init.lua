local down = require("down")
local util = require("down.util")
local mod = require("down.mod")
local lib = require("down.util.lib")
local u = require("down.mod.data.time.util")

local M = mod.create("data.time")

-- NOTE: Maybe encapsulate whole date parser in a single PEG grammar?
local _, time_regex =
    pcall(vim.re.compile, [[{%d%d?} ":" {%d%d} ("." {%d%d?})?]])

---@alias Date {weekday: {name: string, number: number}?, day: number?, month: {name: string, number: number}?, year: number?, timezone: string?, time: {hour: number, minute: number, second: number?}?}

---@class down.data.time.Data
M.data = {
  tostringable_date = function(date_table)
    return setmetatable(date_table, {
      __tostring = function()
        local function d(str)
          return str and (tostring(str) .. " ") or ""
        end

        return vim.trim(
          d(date_table.weekday and date_table.weekday.name)
          .. d(date_table.day)
          .. d(date_table.month and date_table.month.name)
          .. d(date_table.year and string.format("%04d", date_table.year))
          .. d(date_table.time and tostring(date_table.time))
          .. d(date_table.timezone)
        )
      end,
    })
  end,
  --- Converts a parsed date with `parse_date` to a lua date.
  ---@param parsed_date Date #The date to convert
  ---@return osdate #A Lua date
  to_lua_date = function(parsed_date)
    local now = os.date("*t") --[[@as osdate]]
    local parsed = os.time(vim.tbl_deep_extend("force", now, {
      day = parsed_date.day,
      month = parsed_date.month and parsed_date.month.number or nil,
      year = parsed_date.year,
      hour = parsed_date.time and parsed_date.time.hour,
      min = parsed_date.time and parsed_date.time.minute,
      sec = parsed_date.time and parsed_date.time.second,
    }) --[[@as osdateparam]])
    return os.date("*t", parsed) --[[@as osdate]]
  end,

  --- Converts a lua `osdate` to a down date.
  ---@param osdate osdate #The date to convert
  ---@param include_time boolean? #Whether to include the time (hh::mm.ss) in the output.
  ---@return Date #The converted date
  to_date = function(osdate, include_time)
    -- TODO: Extract into a function to get weekdays (have to hot recalculate every time because the user may change locale
    local weekdays = {}
    for i = 1, 7 do
      table.insert(
        weekdays,
        os.date("%A", os.time({ year = 2000, month = 5, day = i })):lower()
      ) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
    end

    local months = {}
    for i = 1, 12 do
      table.insert(
        months,
        os.date("%B", os.time({ year = 2000, month = i, day = 1 })):lower()
      ) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
    end

    -- os.date("*t") returns wday with Sunday as 1, needs to be
    -- converted to Monday as 1
    local converted_weekday = lib.number_wrap(osdate.wday - 1, 1, 7)

    return M.data.tostringable_date({
      weekday = osdate.wday and {
        number = converted_weekday,
        name = lib.title(weekdays[converted_weekday]),
      } or nil,
      day = osdate.day,
      month = osdate.month and {
        number = osdate.month,
        name = lib.title(months[osdate.month]),
      } or nil,
      year = osdate.year,
      time = osdate.hour and setmetatable({
        hour = osdate.hour,
        minute = osdate.min or 0,
        second = osdate.sec or 0,
      }, {
        __tostring = function()
          if not include_time then
            return ""
          end

          return tostring(osdate.hour)
              .. ":"
              .. tostring(string.format("%02d", osdate.min))
              .. (osdate.sec ~= 0 and ("." .. tostring(osdate.sec)) or "")
        end,
      }) or nil,
    })
  end,

  --- Parses a date and returns a table representing the date
  ---@param input string #The input which should follow the date specification found in the down spec.
  ---@return Date|string #The data extracted from the input or an error message
  parse_date = function(input)
    local weekdays = {}
    for i = 1, 7 do
      table.insert(
        weekdays,
        os.date("%A", os.time({ year = 2000, month = 5, day = i })):lower()
      ) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
    end

    local months = {}
    for i = 1, 12 do
      table.insert(
        months,
        os.date("%B", os.time({ year = 2000, month = i, day = 1 })):lower()
      ) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
    end

    local output = {}

    for down in vim.gsplit(input, "%s+") do
      if down:len() == 0 then
        goto continue
      end

      if down:match("^-?%d%d%d%d+$") then
        output.year = tonumber(down)
      elseif down:match("^%d+%w*$") then
        output.day = tonumber(down:match("%d+"))
      elseif vim.list_contains(u.tz, down:upper()) then
        output.timezone = down:upper()
      else
        do
          local hour, minute, second = vim.re.match(down, time_regex)

          if hour and minute then
            output.time = setmetatable({
              hour = tonumber(hour),
              minute = tonumber(minute),
              second = second and tonumber(second) or nil,
            }, {
              __tostring = function()
                return down
              end,
            })

            goto continue
          end
        end

        do
          local valid_months = {}

          -- Check for month abbreviation
          for i, month in ipairs(months) do
            if vim.startswith(month, down:lower()) then
              valid_months[month] = i
            end
          end

          local count = vim.tbl_count(valid_months)
          if count > 1 then
            return "Ambiguous month name! Possible interpretations: "
                .. table.concat(vim.tbl_keys(valid_months), ",")
          elseif count == 1 then
            local valid_month_name, valid_month_number = next(valid_months)

            output.month = {
              name = lib.title(valid_month_name),
              number = valid_month_number,
            }

            goto continue
          end
        end

        do
          down = down:match("^([^,]+),?$")

          local valid_weekdays = {}

          -- Check for weekday abbreviation
          for i, weekday in ipairs(weekdays) do
            if vim.startswith(weekday, down:lower()) then
              valid_weekdays[weekday] = i
            end
          end

          local count = vim.tbl_count(valid_weekdays)
          if count > 1 then
            return "Ambiguous weekday name! Possible interpretations: "
                .. table.concat(vim.tbl_keys(valid_weekdays), ",")
          elseif count == 1 then
            local valid_weekday_name, valid_weekday_number =
                next(valid_weekdays)

            output.weekday = {
              name = lib.title(valid_weekday_name),
              number = valid_weekday_number,
            }

            goto continue
          end
        end

        return "Unidentified string: `"
            .. down
            .. "` - make sure your locale and language are set correctly if you are using a language other than English!"
      end

      ::continue::
    end

    return M.data.tostringable_date(output)
  end,

  insert_date = function(insert_mode)
    local function callback(input)
      if input == "" or not input then
        return
      end

      local output

      if type(input) == "table" then
        output = tostring(M.data.to_date(input))
      else
        output = M.data.parse_date(input)

        if type(output) == "string" then
          utils.notify(output, vim.log.levels.ERROR)

          vim.ui.input({
            prompt = "Date: ",
            default = input,
          }, callback)

          return
        end

        output = tostring(output)
      end

      vim.api.nvim_put({ "{@ " .. output .. "}" }, "c", false, true)

      if insert_mode then
        vim.cmd.startinsert()
      end
    end

    if Mod.is_mod_loaded("ui.calendar") then
      vim.cmd.stopinsert()
      Mod.get_mod("ui.calendar")
          .select({ callback = vim.schedule_wrap(callback) })
    else
      vim.ui.input({
        prompt = "Date: ",
      }, callback)
    end
  end,
}

M.maps = function()
  vim.keymap.set(
    "",
    "<Plug>(down.time.insert-date)",
    lib.wrap(M.data.insert_date, false)
  )
  vim.keymap.set(
    "i",
    "<Plug>(down.time.insert-date.insert-mode)",
    lib.wrap(M.data.insert_date, true)
  )
end

function M.setup()
  return {
    laoded = true
  }
end

return M
