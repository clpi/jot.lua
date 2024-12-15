--- @alias LogLevel
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
--- @field level LogLevel                                          Any messages above this level will be logged.
--- @field modes ({ name: LogLevel, hl: string, level: number })[] Level config.
--- @field float_precision number                                  Can limit the number of decimals displayed for floats.

local vl, a, lvl, ext = vim.log, vim.api, vim.log.levels, vim.tbl_deep_extend

--- User config section
--- @type down.log.Config
local default_config = {
  plugin = "down",

  use_console = true,

  highlights = true,

  use_file = true,

  level = "warn",

  modes = {
    { name = "trace", hl = "Comment", level = lvl.TRACE },
    { name = "debug", hl = "Comment", level = lvl.DEBUG },
    { name = "info", hl = "None", level = lvl.INFO },
    { name = "warn", hl = "WarningMsg", level = lvl.WARN },
    { name = "error", hl = "ErrorMsg", level = lvl.ERROR },
    { name = "fatal", hl = "ErrorMsg", level = 5 },
  },

  float_precision = 0.01,
}

local Log = {}

Log.get_default_config = function()
  return require("down.config.default")
end
Log.get_base_config = function()
  return default_config
end

-- local unpack = unpack or table.unpack

Log.debug = function(inp)
  -- print("ERROR: ", inp)
end
Log.warn = function(inp)
  -- print("ERROR: ", inp)
end
Log.info = function(inp)
  -- print("ERROR: ", inp)
end
Log.error = function(inp)
  -- print("ERROR: ", inp)
end
Log.trace = function(inp)
  -- print("TRACE: ", inp)
end

--- @paraM.config down.log.config
--- @param standalone boolean
Log.new = function(config, standalone)
  config = ext("force", default_config, config)
  config.plugin = "down" -- Force the plugin name to be down

  local outfile = string.format(
    "%s/%s.log",
    a.nvim_call_function("stdpath", { "data" }),
    config.plugin
  )

  local obj = standalone ~= nil and Log or {}

  local levels = {}
  for _, v in ipairs(config.modes) do
    levels[v.name] = v.level
  end

  local round = function(x, increment)
    increment = increment or 1
    x = x / increment
    return (x > 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)) * increment
  end

  local make_string = function(...)
    local t = {}
    for i = 1, select("#", ...) do
      local x = select(i, ...)

      if type(x) == "number" and config.float_precision then
        x = tostring(round(x, config.float_precision))
      elseif type(x) == "table" then
        x = vim.inspect(x)
      else
        x = tostring(x)
      end

      t[#t + 1] = x
    end
    return table.concat(t, " ")
  end

  local log_at_level = function(level_config, message_maker, ...)
    -- Return early if we"re below the config.level
    if levels[level_config.name] < levels[config.level] then
      return
    end
    local nameupper = level_config.name:upper()

    local msg = message_maker(...)
    local info = debug.getinfo(2, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline

    -- Output to console
    if config.use_console then
      local v =
        string.format("(%s)\n%s\n%s", os.date("%H:%M:%S"), lineinfo, msg)

      if config.highlights and level_config.hl then
        (vim.schedule_wrap(function()
          vim.cmd(string.format("echohl %s", level_config.hl))
        end))()
      end

      (vim.schedule_wrap(function()
        vim.notify(
          string.format("[%s] %s", config.plugin, vim.fn.escape(v, '"')),
          level_config.level
        )
        -- vim.cmd(string.format([[echom "[%s] %s"]], config.plugin, vim.fn.escape(v, '"')))
      end))()

      if config.highlights and level_config.hl then
        (vim.schedule_wrap(function()
          vim.cmd("echohl NONE")
        end))()
      end
    end

    -- Output to log file
    if config.use_file then
      local fp = assert(io.open(outfile, "a"))
      local str =
        string.format("[%-6s%s] %s: %s\n", nameupper, os.date(), lineinfo, msg)
      fp:write(str)
      fp:close()
    end
  end

  for _, x in ipairs(config.modes) do
    obj[x.name] = function(...)
      return log_at_level(x, make_string, ...)
    end

    obj[("fmt_%s"):format(x.name)] = function()
      return log_at_level(x, function(...)
        local passed = { ... }
        local fmt = table.remove(passed, 1)
        local inspected = {}
        for _, v in ipairs(passed) do
          table.insert(inspected, vim.inspect(v))
        end
        return string.format(fmt, table.unpack(inspected))
      end)
    end
  end
end

-- }}}

return Log
