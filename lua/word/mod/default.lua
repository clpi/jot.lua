local w = require("word")
local mod = w.mod

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
  name = "base",
  -- NON OPTIONAL
  path = "base.init",
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
    defined = {    -- The events that the init itself has defined
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



C.default_modules = require("word.mod").create_meta(
-- "treesitter",
  "encrypt",
  "agenda",
  "job",
  "tag",
  "autocmd",
  "notes",
  "maps",
  "cmd",
  "store",
  "code",
  "export",
  "preview",
  "icon",
  "pick",
  "lsp",
  'completion',
  'data',
  "resources",
  "metadata",
  "capture",
  "template",
  "track",
  "media",
  "snippets",
  "time",
  "run",
  "sync",
  "search",
  "todo",
  "ui",
  "calendar",
  "publish",
  "link"
)

C.base_modules = C.default_modules

return C
