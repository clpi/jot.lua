--[[
    file: Calendar
    title: Frictionless Dates
    description: The calendar init provides a range of functionality for different date-related tasks.
    summary: Opens an interactive calendar for date-related tasks.
---
The calendar is most often invoked with the intent of selecting a date, but may
also be launched in standalone mode, select date range mode and others.

To view keys and help, press `?` in the calendar view.
--]]

local word = require("word")
local mod = word.mod

local init = mod.create("ui.calendar")

init.setup = function()
  return {
    requires = {
      "ui",
      "ui.calendar.month",
      "ui.calendar.time",
    },
  }
end

---@class base.calendar
init.data = {

  data = {

    modes = {},
    views = {},

    get_mode = function(name, callback)
      if init.data.data.modes[name] ~= nil then
        local cur_mode = init.data.data.modes[name](callback)
        cur_mode.name = name
        return cur_mode
      end

      print("Error: mode not set or not available")
    end,

    get_view = function(name)
      if init.data.data.views[name] ~= nil then
        return init.data.data.views[name]
      end

      print("Error: view not set or not available")
    end,

    extract_ui_info = function(buffer, window)
      local width = vim.api.nvim_win_get_width(window)
      local height = vim.api.nvim_win_get_height(window)

      local half_width = math.floor(width / 2)
      local half_height = math.floor(height / 2)

      return {
        window = window,
        buffer = buffer,
        width = width,
        height = height,
        half_width = half_width,
        half_height = half_height,
      }
    end,

    open_window = function(options)
      local MIN_HEIGHT = 14

      local buffer, window = init.required["ui"].create_split(
        "ui.calendar-" .. tostring(os.clock()):gsub("%.", "-"),
        {},
        options.height or MIN_HEIGHT + (options.padding or 0)
      )

      vim.api.nvim_create_autocmd({ "WinClosed", "BufDelete" }, {
        buffer = buffer,

        callback = function()
          pcall(vim.api.nvim_win_close, window, true)
          pcall(vim.api.nvim_buf_delete, buffer, { force = true })
        end,
      })

      return buffer, window
    end,
  },
  add_mode = function(name, factory)
    init.data.data.modes[name] = factory
  end,

  add_view = function(name, details)
    init.data.data.views[name] = details
  end,

  create_calendar = function(buffer, window, options)
    local callback_and_close = function(result)
      if options.callback ~= nil then
        options.callback(result)
      end

      pcall(vim.api.nvim_win_close, window, true)
      pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    end

    local mode = init.data.data.get_mode(options.mode, callback_and_close)
    if mode == nil then
      return
    end

    local ui_info = init.data.data.extract_ui_info(buffer, window)

    local view = init.data.data.get_view(options.view or "month")

    view.setup(ui_info, mode, options.date or os.date("*t"), options)
  end,

  open = function(options)
    local buffer, window = init.data.data.open_window(options)

    options.mode = "standalone"

    return init.data.create_calendar(buffer, window, options)
  end,

  select_date = function(options)
    local buffer, window = init.data.data.open_window(options)

    options.mode = "select_date"

    return init.data.create_calendar(buffer, window, options)
  end,

  select_date_range = function(options)
    local buffer, window = init.data.data.open_window(options)

    options.mode = "select_range"

    return init.data.create_calendar(buffer, window, options)
  end,
}

init.load = function()
  -- Add base calendar modes
  init.data.add_mode("standalone", function(_)
    return {}
  end)

  init.data.add_mode("select_date", function(callback)
    return {
      on_select = function(_, date)
        if callback then
          callback(date)
        end
        return false
      end,
    }
  end)

  init.data.add_mode("select_range", function(callback)
    return {
      range_start = nil,
      range_end = nil,

      on_select = function(self, date)
        if not self.range_start then
          self.range_start = date
          return true
        else
          if os.time(date) <= os.time(self.range_start) then
            print(
              "Error: you should choose a date that is after the starting day."
            )
            return false
          end

          self.range_end = date
          callback({ self.range_start, self.range_end })
          return false
        end
      end,

      get_day_highlight = function(self, date, base_highlight)
        if self.range_start ~= nil then
          if os.time(date) < os.time(self.range_start) then
            return "@comment"
          end
        end
        return base_highlight
      end,
    }
  end)
end

return init
