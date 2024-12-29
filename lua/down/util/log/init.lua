--- @alias down.log.Level
--- | "trace"
--- | "debug"
--- | "info"
--- | "warn"
--- | "error"
--- | "fatal"

--- @class (exact) down.log.Config
--- @field plugin string                                           Name of the plugin. Prepended to log messages.
--- @field use_console boolean                                     Whether to print the output to Neovim while running.
--- @field highlights boolean                                      Whether highlighting should be used in console (using `:echohl`).
--- @field use_file boolean                                        Whether to write output to a file.
--- @field level down.log.Level                                          Any messages above this level will be logged.
--- @field modes ({ name: down.log.Level, hl: string, level: number })[] Level config.
--- @field float_precision number                                  Can limit the number of decimals displayed for floats.

local vl, a, lvl, ext = vim.log, vim.api, vim.log.levels, vim.tbl_deep_extend

--- User config section
--- @type down.log.Config
local default_config = function(plug)
  return {
    plugin = plug or 'down',

    use_console = false,

    highlights = true,

    use_file = true,

    level = 'trace',

    outfile = string.format('%s/%s.log', a.nvim_call_function('stdpath', { 'data' }), plug or 'down'),

    ---@type number
    lvl = vim.log.levels.TRACE,

    modes = {
      trace = { hl = 'Comment', level = lvl.TRACE },
      debug = { hl = 'Comment', level = lvl.DEBUG },
      info = { hl = 'None', level = lvl.INFO },
      warn = { hl = 'WarningMsg', level = lvl.WARN },
      error = { hl = 'ErrorMsg', level = lvl.ERROR },
      fatal = { hl = 'ErrorMsg', level = 5 },
    },

    float_precision = 0.01,
  }
end

local Log = {
  levels = {
    trace = 0,
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
    fatal = 5,
  },
  config = default_config('down'),
}

Log.get_default_config = function()
  return default_config('down')
end

-- local unpack = unpack or table.unpack

Log.debug = function(...)
  Log.at_level('debug', Log.config.modes['debug'], Log.format, ...)
end
Log.warn = function(...)
  Log.at_level('warn', Log.config.modes['warn'], Log.format, ...)
end
Log.info = function(...)
  Log.at_level('info', Log.config.modes['info'], Log.format, ...)
end
Log.error = function(...)
  Log.at_level('error', Log.config.modes['error'], Log.format, ...)
end
Log.fatal = function(...)
  Log.at_level('fatal', Log.config.modes['fatal'], Log.format, ...)
end
Log.trace = function(...)
  Log.at_level('trace', Log.config.modes['trace'], Log.format, ...)
end

Log.at_level = function(level, level_config, message_maker, ...)
  if Log.levels[level] < Log.levels[Log.config.level] then
    return
  end
  local nameupper = level:upper()

  local msg = message_maker(...)
  local info = debug.getinfo(2, 'Sl')
  local lineinfo = info.short_src .. ':' .. info.currentline

  -- Output to console
  if Log.config.use_console then
    local v = string.format('(%s)\n%s\n%s', os.date('%H:%M:%S'), lineinfo, msg)

    if Log.config.highlights and level_config.hl then
      (vim.schedule_wrap(function()
        vim.cmd(string.format('echohl %s', level_config.hl))
      end))()
    end

    (vim.schedule_wrap(function()
      vim.notify(
        string.format('[%s] %s', Log.config.plugin, vim.fn.escape(v, '"')),
        level_config.level
      )
      -- vim.cmd(string.format([[echom [%s] %s]], Log.config.plugin, vim.fn.escape(v, '"')))
    end))()

    if Log.config.highlights and level_config.hl then
      (vim.schedule_wrap(function()
        vim.cmd('echohl NONE')
      end))()
    end
  end

  -- Output to log file
  if Log.config.use_file then
    local fp = assert(io.open(Log.config.outfile, 'a'))
    local str = string.format('[%-6s%s] %s: %s\n', nameupper, os.date(), lineinfo, msg)
    fp:write(str)
    fp:close()
  end
end
Log.round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)) * increment
end

Log.format = function(...)
  local t = {}
  for i = 1, select('#', ...) do
    local x = select(i, ...)

    if type(x) == 'number' and Log.config.float_precision then
      x = tostring(Log.round(x, Log.config.float_precision))
    elseif type(x) == 'table' then
      x = vim.inspect(x)
    else
      x = tostring(x)
    end

    t[#t + 1] = x
  end
  return table.concat(t, ' ')
end
function Log.log(...)
  local passed = { ... }
  local fmt = table.remove(passed, 1)
  local inspected = {}
  for _, v in ipairs(passed) do
    table.insert(inspected, vim.inspect(v))
  end
  return string.format(fmt, table.unpack(inspected))
end

--- @param cfg down.log.Config
--- @param standalone boolean
Log.new = function(cfg, standalone)
  cfg = vim.tbl_deep_extend('force', default_config('down'), cfg)
  cfg.plugin = 'down' -- Force the plugin name to be down
  Log.config = cfg
  for m, v in ipairs(cfg.modes) do
    Log.levels[m] = v.level
  end

  local obj = standalone ~= nil and Log or {}

  for m, x in ipairs(cfg.modes) do
    obj[m] = function(...)
      return Log.at_level(m, x, Log.format, ...)
    end

    obj[('fmt_%s'):format(m)] = function(...)
      return Log.at_level(m, x, Log.log, ...)
    end
  end
end

-- }}}

return Log
