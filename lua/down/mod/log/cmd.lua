return {
  log = {
    min_args = 1,
    max_args = 2,
    name = 'log',
    callback = function(e)
      log.trace 'log'
    end,
    subcommands = {
      index = {
        args = 0,
        name = 'log.index',
        callback = M.data.open_index,
      },
      month = {
        max_args = 1,
        name = 'log.month',
        callback = M.data.open_month,
      },
      tomorrow = {
        args = 0,
        name = 'log.tomorrow',
        callback = M.data.log_tomorrow,
      },
      yesterday = {
        args = 0,
        callback = M.data.log_yesterday,
        name = 'log.yesterday',
      },
      new = {
        args = 0,
        callback = M.data.log_new,
        name = 'log.new',
      },
      custom = {
        callback = M.data.calendar_months,
        max_args = 1,
        name = 'log.custom',
      }, -- format :yyyy-mm-dd
      template = {
        args = 0,
        name = 'log.template',
        callback = M.data.create_template,
      },
    },
  },
}
