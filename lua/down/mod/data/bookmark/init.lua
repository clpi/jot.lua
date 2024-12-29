---@class down.mod.data.Bookmark: down.Mod
local B = {}

---@class down.mod.data.bookmark.Config
B.config = {
  workspace = "default",

  file = "bookmark",
}

---@class down.mod.data.bookmark.Data
B.data = {
  bookmarks = {
    default = {

    }
  }
}

---@return down.mod.Setup
B.setup = function()
  return {
    loaded = true,
    requires = {
      'data',
      'workspace',
      'cmd',
    }
  }
end

B.load = function()
  B.required["cmd"].add_commands_from_table({
    bookmark = {
      args = 1,
      name = "bookmark",
      subcommands = {
        list = {
          name = "bookmark.list",
          args = 1,
        },
        add = {
          name = "bookmark.add",
          args = 1,
        },
        remove = {
          name = "bookmark.remove",
          args = 1,
        },
      }
    }
  })
end

B.handle = function(e)
  local es = e.split
  if es[2] == "bookmark" then
    print("es2")
  elseif es[2] == "bookmark.list" then
    print('es2 list')
  end
end

return B
