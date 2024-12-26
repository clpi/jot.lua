local mod = require("down.mod")
local M = mod.new("tool.telescope")
local tok, t = pcall(require, "telescope")

local k = vim.keymap.set

---@return down.mod.Setup
M.setup = function()
  if tok then
    return {
      loaded = true,
      requires = { "cmd", "workspace" },
    }
  else
    return {
      loaded = false,
    }
  end
end

---@class down.mod.Data
M.data = {
  picker_names = {
    "files",
    "tags",
    "links",
    -- "insert_link",
    -- "insert_file_link",
    -- "search_headings",
    -- "find_project_tasks",
    -- "find_aof_project_tasks",
    -- "find_aof_tasks",
    -- "find_context_tasks",
    "workspace",
    -- "backlinks.file_backlinks",
    -- "backlinks.header_backlinks",
  },
}
---@class down.mod.Config
M.config = {
  enabled = {
    ['backlinks'] = true,
    ['workspace'] = true,
    ['files'] = true,
    ['tags'] = true,
    ['links'] = true,
    ['grep'] = true
  }
}

M.data.pickers = function()
  local r = {}
  for _, pic in ipairs(M.data.picker_names) do
    local ht, te = pcall(require, "telescope._extensions.down.picker." .. pic)
    if ht then
      r[pic] = te
    end
    r[pic] = require("telescope._extensions.down.picker." .. pic)
  end
  return r
end
M.subscribed = {
  cmd = {
    ["find.files"] = true,
    ["find"] = true,
    ["find.links"] = true,
    ["find.tags"] = true,
    ["find.workspace"] = true,
  },
}
M.load = function()
  if tok then
    mod.await("cmd", function(cmd)
      cmd.add_commands_from_table({
        find = {
          args = 0,
          name = "find",
          subcommands = {
            links = {
              name = "find.links",
              args = 0,
            },
            tags = {
              name = "find.tags",
              args = 0,
            },
            files = {
              name = "find.files",
              args = 0,
            },
            workspace = {
              name = "find.workspace",
              args = 0,
            },
          },
        },
      })
    end)
    assert(tok, t)
    t.load_extension("down")
    for _, pic in ipairs(M.data.picker_names) do
      k("n", "<plug>down.telescope." .. pic .. "", M.data.pickers()[pic])
    end
  else
    return
  end
end

M.on = function(event)
  if (event.split[1] == "cmd") then
    if (event.split[2] == "find") then
      require("telescope._extensions.down.picker.files")()
    elseif (event.split[2] == "find.files") then
      if M.config.enabled['files'] ~= nil then
        require("telescope._extensions.down.picker.files")()
      end
    elseif (event.split[2] == "find.tags") then
      if M.config.enabled['tags'] ~= nil then
        require("telescope._extensions.down.picker.tags")()
      end
    elseif (event.split[2] == "find.links") then
      if M.config.enabled['links'] ~= nil then
        require("telescope._extensions.down.picker.links")()
      end
    elseif (event.split[2] == "find.workspace") then
      if M.config.enabled['workspace'] ~= nil then
        require("telescope._extensions.down.picker.workspace")()
      end
    end
  end
end

return M
