local down = require 'down'
local mod = require 'down.mod'
local util = require 'down.util'
local log = require 'down.util.log'

local G = mod.new 'ui.calendar'

G.maps = {
  { 'n', ',d.', '<CMD>Down calendar<CR>', 'Open calendar' },
  { 'n', ',do', '<CMD>Down calendar<CR>' },
  { 'n', ',dl', '<CMD>Down calendar<CR>' },
}
G.setup = function()
  return {
    loaded = true,
    dependencies = {
      'ui',
      'ui.calendar.day',
      'ui.calendar.month',
      'ui.calendar.time',
    },
  }
end

---@class down.ui.calendar.Data
---@field select_date fun(options:table)
G.data = {

  modes = {},
  view = {},

  get_mode = function(name, callback)
    if G.data.modes[name] ~= nil then
      local cur_mode = G.data.modes[name](callback)
      cur_mode.id = name
      return cur_mode
    end

    log.error 'Error: mode not set or not available'
  end,
}

G.data.get_view = function(name)
  local n = name or 'month'
  if G.data.view[n] ~= nil then
    return G.data.view[name]
  end

  log.error 'Error: view not set or not available'
end

G.data.extract_ui_info = function(buffer, window)
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
end

G.data.open_window = function(options)
  local MIN_HEIGHT = 14

  local buffer, window = G.dep['ui'].new_split(
    'ui.calendar-' .. tostring(os.clock()):gsub('%.', '-'),
    {},
    options.height or MIN_HEIGHT + (options.padding or 0)
  )

  vim.bo.filetype = 'calendar'
  vim.api.nvim_create_autocmd({ 'WinClosed', 'BufDelete' }, {
    buffer = buffer,
    callback = function()
      pcall(vim.api.nvim_win_close, window, true)
      pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    end,
  })

  return buffer, window
end
G.data.add_mode = function(name, factory)
  G.data.modes[name] = factory
end

G.data.add_view = function(name, details)
  G.data.view[name] = details
end

G.data.new_calendar = function(buffer, window, options)
  local callback_and_close = function(result)
    if options.callback ~= nil then
      options.callback(result)
    end

    pcall(vim.api.nvim_win_close, window, true)
    pcall(vim.api.nvim_buf_delete, buffer, { force = true })
  end

  local mode = G.data.get_mode(options.mode, callback_and_close)
  if mode == nil then
    return
  end

  local ui_info = G.data.extract_ui_info(buffer, window)

  local v = G.data.get_view(options.view or 'month')

  v.setup(ui_info, mode, options.date or os.date '*t', options)
end

G.data.open = function(options)
  local buffer, window = G.data.open_window(options)

  options.mode = 'standalone'

  return G.data.new_calendar(buffer, window, options)
end

G.data.select_date = function(options)
  local buffer, window = G.data.open_window(options)

  options.mode = 'select_date'

  return G.data.new_calendar(buffer, window, options)
end

G.data.select_date_range = function(options)
  local buffer, window = G.data.open_window(options)

  options.mode = 'select_range'

  return G.data.new_calendar(buffer, window, options)
end

G.load = function()
  -- Add base calendar modes
  G.data.add_mode('standalone', function(_)
    return {}
  end)

  G.data.add_mode('select_date', function(callback)
    return {
      on_select = function(_, date)
        if callback then
          callback(date)
        end
        return false
      end,
    }
  end)

  G.data.add_mode('select_range', function(callback)
    return {
      range_start = nil,
      range_end = nil,

      on_select = function(self, date)
        if not self.range_start then
          self.range_start = date
          return true
        else
          if os.time(date) <= os.time(self.range_start) then
            log.error 'Error: you should choose a date that is after the starting day.'
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
            return '@comment'
          end
        end
        return base_highlight
      end,
    }
  end)
end

return G
