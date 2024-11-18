local w = require("word")

C = {}

C.default_mod = {
  setup = function()
    return {
      success = true,
      requires = {},
      replaces = nil,
      replace_merge = false
    }
  end,
  load = function()
  end,
  on_event = function()
  end,
  word_post_load = function()
  end,
  -- NON OPTIONAL
  name = "",
  -- NON OPTIONAL
  path = "",
  private = {},
  public = {
    version = w.version
  },
  config = {
    private = {
    },
    public = {
    },
    custom = {},
  },
  events = {
    subscribed = { -- The events that the init is subscribed to
    },
    defined = { -- The events that the init itself has defined
    },
  },
  required = {
  },
  examples = {
  },
  imported = {
  },
  tests = function() 

  end,
}

return C
