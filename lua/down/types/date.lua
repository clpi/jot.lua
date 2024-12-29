--- @meta down.ids.date
---
--- The time part of the datetime.
--- @class (exact) down.Time Time
---   @field public hour? integer|string Hours
---   @field public minute? integer|string Minutes
---   @field public second? integer|string Seconds
---   @field public fmt fun(t: down.Time, tf: string): string Format the time part of the datetime.
---   @field public time fun(t: down.Time): integer Get the time part of the datetime.
---   @field public params fun(t: down.Time): osdateparam Get the time part of the datetime.
---
--- The datetime data structure.
--- @class (exact) down.Datetime
---   @field public date? down.Date The date part of the datetime.
---   @field public time? down.Time The time part of the datetime.
---   @field public params fun(t: down.Datetime): osdateparam Get the time part of the datetime.
---   @field public fmt fun(t: down.Datetime, f: string): string Format the time part of the datetime.
---
--- The date part of the datetime.
--- @class (exact) down.Date
---   @field public day integer|string Hours
---   @field public week integer|string Minutes
---   @field public month integer|string Seconds
---   @field public year integer|string Seconds
---   @field public fmt fun(t: down.Date, tf: string|nil): string Format the time part of the datetime.
---   @field public date fun(t: down.Date): integer Get the time part of the datetime.
---   @field public params fun(t: down.Date, d: down.Time|nil): osdateparam Get the time part of the datetime.
