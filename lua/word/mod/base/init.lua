local Mod = {}

local mod = require("word.mod")

Mod.base_modules = mod.create_meta(
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
  -- "icon",
  "preview",
  "pick",
  -- "icon",
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

return Mod
