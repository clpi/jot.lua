---@class down.Mod
local M = require "down.mod".create("data.date", {
})

--- The date data structure.
--- @class down.data.date.Data Data
M.data = {

}

local d, t, dt = M.data.datetime.date, M.data.datetime.time, M.data.datetime

--- The date data structure.
--- @type down.Datetime The datetime data structure.
M.data.datetime = setmetatable({
  --- @type down.Date The datetime data structure.
  date = setmetatable({
    year = 0,
    month = 0,
    day = 0,
    week = 0,
    ---@param d down.Date The date part of the datetime.
    ---@param t? down.Time The date part of the datetime.
    ---@return osdateparam params The date part of the datetime.
    params = function(d, t)
      t = t or { hour = 0, minute = 0, second = 0 }
      return {
        hour = t.hour or 0,
        second = t.second or 0,
        minute = t.minute or 0,
        year = d.year,
        month = d.month,
        day = d.day,
        week = d.week,
      }
    end,
    date = function(d)
      return os.date("%Y-%m-%d", os.time(d))
    end,
    fmt = function(d, df)
      return string.format(df or "%04d-%02d-%02d", d.year, d.month, d.day)
    end
  }, {
    --- @param dt down.Date
    --- @param fmt? string
    --- @return string|osdate
    __call = function(dt, fmt)
      return os.date(fmt or "%02d:%02d:%02d", os.time(M.data.datetime.date.params(dt)))
    end,
    __tostring = function(d)
      return string.format("%04d-%02d-%02d", d.year, d.month, d.day)
    end
  }),
  --- @type down.Time
  time = setmetatable({
    hour = 0,
    minute = 0,
    second = 0,
    fmt = function(t, tf)
      return string.format(tf or "%02d:%02d:%02d", t.hour, t.minute, t.second)
    end,
    time = function(t)
      return os.time(t)
    end,
    ---@param d? down.Date The date part of the datetime.
    ---@param t down.Time The date part of the datetime.
    ---@return down.Datetime
    params = function(t, d)
      return {
        year = d.year or 0,
        month = d.month or 0,
        day = d.day or 0,
        week = d.week or 0,
        hour = t.hour or 0,
        min = t.minute or 0,
        sec = t.second or 0,
      }
    end,
  }, {
    --- @param dt down.Time
    --- @param fmt? string
    --- @return string|osdate
    __call = function(dt, fmt)
      return os.date(fmt or "%02d:%02d:%02d", os.time(M.data.datetime.time.params(dt)))
    end,
    __tostring = function(t)
      return string.format("%02d:%02d:%02d", t.hour, t.minute, t.second)
    end
  }),
  --- @param dt down.Time
  --- @param f? string
  --- @return string
  fmt = function(dt, f)
    return string.format(f or "%s %s", tostring(dt.date), tostring(dt.time))
  end,
  --- @param dt down.Datetime
  --- @return osdateparam
  params = function(dt)
    return {
      hour = dt.time.hour,
      minute = dt.time.minute,
      second = dt.time.second,
      year = dt.date.year,
      month = dt.date.month,
      day = dt.date.day,
      week = dt.date.week,
    }
  end,
}, {
  __tostring = function(dt)
    return tostring(dt.date) .. " " .. tostring(dt.time)
  end,
  ---@param d down.Datetime
  ---@param k string
  __index = function(d, k)
    if d.date[k] then
      return d.date[k]
    elseif d.time[k] then
      return d.time[k]
    end
  end,
  ---@param dt down.Datetime
  ---@param fmt string
  ---@return string|osdate
  __call = function(dt, fmt)
    return os.date("%02d:%02d:%02d", os.time(M.data.datetime.params(dt)))
  end,
})

---@class table<down.data.store.Store>
M.data.stores = {

}

---@class down.data.store.Config
M.config = {

  store = "data/stores"

}

---@return down.mod.Setup
M.setup = function()
  ---@type down.mod.Setup
  return {
    requires = {

    },
    loaded = true,
  }
end


return M
