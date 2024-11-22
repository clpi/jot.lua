--[[
    file: link
    title: Find link/target in the buffer
    description: Utility M to handle link/link targets in the buffer
    internal: true
    ---

This M provides utility functions that are used to find link and their targets in the buffer.
--]]

local word = require("word")
local lib, mod, u = word.lib, word.mod, word.utils

local M = mod.create("link")
u.ns("word-link")

M.setup = function()
  return {
    success = true,
    requires = {
      "workspace",
      "data"
    }
  }
end

---@class base.link
M.public = {
  -- TS query strings for different link targets
  ---@param link_type "generic" | "definition" | "footnote" | string
  get_link_target_query_string = function(link_type)
    return lib.match(link_type)({
      generic = [[
                [(_
                  [(strong_carryover_set
                     (strong_carryover
                       name: (tag_name) @tag_name
                       (tag_parameters) @title
                       (#eq? @tag_name "name")))
                   (weak_carryover_set
                     (weak_carryover
                       name: (tag_name) @tag_name
                       (tag_parameters) @title
                       (#eq? @tag_name "name")))]?
                  title: (paragraph_segment) @title)
                 (inline_link_target
                   (paragraph) @title)]
            ]],

      [{ "definition", "footnote" }] = string.format(
        [[
                (%s_list
                    (strong_carryover_set
                          (strong_carryover
                            name: (tag_name) @tag_name
                            (tag_parameters) @title
                            (#eq? @tag_name "name")))?
                    .
                    [(single_%s
                       (weak_carryover_set
                          (weak_carryover
                            name: (tag_name) @tag_name
                            (tag_parameters) @title
                            (#eq? @tag_name "name")))?
                       (single_%s_prefix)
                       title: (paragraph_segment) @title)
                     (multi_%s
                       (weak_carryover_set
                          (weak_carryover
                            name: (tag_name) @tag_name
                            (tag_parameters) @title
                            (#eq? @tag_name "name")))?
                        (multi_%s_prefix)
                          title: (paragraph_segment) @title)])
                ]],
        lib.reparg(link_type, 5)
      ),
      _ = string.format(
        [[
                    (%s
                      [(strong_carryover_set
                         (strong_carryover
                           name: (tag_name) @tag_name
                           (tag_parameters) @title
                           (#eq? @tag_name "name")))
                       (weak_carryover_set
                         (weak_carryover
                           name: (tag_name) @tag_name
                           (tag_parameters) @title
                           (#eq? @tag_name "name")))]?
                      (%s_prefix)
                      title: (paragraph_segment) @title)
                ]],
        lib.reparg(link_type, 2)
      ),
    })
  end,
}

M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      preview = {
        name = "link",
        subcommands = {
          update = {
            args = 0,
            name = "link.new"
          },
          insert = {
            name = "link.backlinks",
            args = 0,
          },
        },
      }
    })
  end)
end
M.events.subscribed = {
  cmd = {
    ["link.new"] = true,
    ["link.backlinks"] = true,
  },
}

return M
