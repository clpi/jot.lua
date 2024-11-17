--[[
    file: base
    summary: Metainit for storing the most necessary mod.
    internal: true
    ---
This file contains all of the most important mod that any user would want
to have a "just works" experience.

Individual entries can be disabled via the "disable" flag:
```lua
load = {
    ["base"] = {
        config = {
            disable = {
                -- init list goes here
                "autocmd",
                "itero",
            },
        },
    },
}
```
--]]

local word = require("word")
local mod = word.mod

return mod.create_meta(
-- "treesitter",

  "base",
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
  "snippets",
  "run",
  "sync",
  "search",
  "todo",
  "ui",
  "calendar",
  "publish",
  "link"
)
