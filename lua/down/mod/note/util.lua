local U = {}

U.weekdays = {
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
}
U.months = {
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

U.dateformat = {
  week = "%V",
  hour24 = "%H:%M:%S",
  hour12 = "%I:%M:%S %p",
}

U.number_to_month = function(n)
  return U.months[n]
end
U.year = tonumber(os.date("%Y"))
U.month = tonumber(os.date("%m"))
U.day = tonumber(os.date("%d"))
U.timetable = {
  year = U.year,
  month = U.month,
  day = U.day,
  hour = 0,
  min = 0,
  sec = 0,
}
U.time = os.time()
U.weekday = tonumber(os.date("%w", os.time(U.timetable)))


function U.number_to_weekday(n)
  if n ~= nil then
    return U.weekday[n]
  end
end

return U
