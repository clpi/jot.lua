local d = require("word")

local lib, mod, cfg, u = d.lib, d.mod, d.config, d.utils

u.ns("word-search")

local M = mod.create("search")

M.public = {

  files = function()
    local pop = require("nui.popup")
    local m = require("nui.menu")
    local e = require("nui.input")
    local d = require("nio.ui")

    e({
      position = "cursor",
      enter = true,
      focusable = true
    }, {
      default_value = "test",
      on_change = function()
        print("changed")
      end,
      on_submit = function()
        print("submitted")
      end,
      on_close = function()
        print("closed")
      end,
      prompt = "Enter a file name",
    })
    d.select({
      items = {
        {
          value = "test",
          display = "test"
        },
        {
          value = "test2",
          display = "test2"
        }
      }

    }, {
      format_item = function(item)
        return item.display
      end,
      kind = "file",
      prompt = "Select"

    })
  end
}

M.load = function()
  mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      search = {
        subcommands = {
          workspace = {
            args = 1,
            name = "search.workspace",
            subcommands = {
              current = {
                name = "search.workspace.current", -- Note default workspace
              },
              all = {
                args = 0,
                name = "search.workspace.all",
              }
            }
          },
          todos = {
            name = "search.todos",
            args = 0,
          },
          titles = {
            name = "search.titles",
            args = 0,
          },
        },
        name = "search"
      }
    })
  end)
end



M.setup = function()
  return {
    success = true,
    requires = {
      "workspace"
    }

  }
end

M.config.private = {

}
M.config.public = {

}
M.private = {

}
M.events = {}

M.events.defined = {

}

M.on_event = function(event)
  if event.type == "cmd.events.search.todos" then
    M.public["files"]()
  elseif event.type == "cmd.events.search.titles" then
    M.public["files"]()
  elseif event.type == "cmd.events.search.workspace.all" then
    M.public["files"]()
  elseif event.type == "cmd.events.search.workspace.current" then
    M.public["files"]()
  end
end

M.events.subscribed = {
  cmd = {
    ["search.workspace"] = true,
    ["search.workspace.current"] = true,
    ["search.workspace.all"] = true,
    ["search.todos"] = true,
    ["search.titles"] = true,
  },
}

return M
