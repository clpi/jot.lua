local mod = require("down.mod")
local Tag = require("down.mod.data.tag.tag")
local M = require("down.mod").new("data.tag")

---@return down.mod.Setup
M.setup = function()
  -- mod.await("cmd", function(cmd)
  --   cmd.add_commands_from_table({
  --     tag = {
  --       subcommands = {
  --         delete = {
  --           args = 0,
  --           name = 'data.tag.delete'
  --         },
  --         new = {
  --           args = 0,
  --           name = 'data.tag.new'
  --         },
  --         list = {
  --           name = 'data.tag.list',
  --           args = 0,
  --         },
  --       },
  --       name = 'tag'
  --     }
  --   })
  -- end)
  return {
    loaded = true,
    requires = { "workspace", "cmd" },
  }
end

---@class down.mod.data.tag.Data
M.data = {
  tags = {
    global = {

    },
    workspace = {

    },
    document = {

    }
  }
}

--- Parse a single line for tag instances
--- @param ln string
--- @return string[]
M.data.parse_ln = function(ln)
  local tags = {}
  for tag in ln:gmatch("#%S+") do
    table.insert(tags, tag)
  end
  print(tags)
  return tags
end

M.data.parse = function(text)
  tags = {}
  for ln in text:gmatch("[^\n]+") do
    M.data.parse_ln(ln)
  end
end

---@class down.mod.data.tag.Config
M.config = {}

---@class down.mod.data.tag.Subscribed
M.subscribed = {
  cmd = {
    ["data.tag.delete"] = true,
    ["data.tag.new"] = true,
    ["data.tag.list"] = true,
  },
}

M.handle = function(e) end

return M
