local M = Mod.create("integration.telescope")
local tok, t = pcall(require, "telescope")

local k = vim.keymap.set

M.setup = function()
  if tok then
    return {
      loaded = true,
      requires = { "cmd", "workspace" },
    }
  else
    return {
      loaded = false
    }
  end
end

M.data = {
    picker_names = {
      "linkable",
      "files",
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
M.config.public = {
}
M.data.pickers = function()
  local r = {}
  for _, pic in ipairs(M.data.picker_names) do
    local ht, te = pcall(require, "telescope._extensions.word.picker." .. pic)
    if ht then
      r[pic] = te
    end
    r[pic] = require("telescope._extensions.word.picker." .. pic)
  end
  return r
end
M.events.subscribed = {
  cmd = {
    ["cmd.integration.telescope.find.files"] = true,
    ["cmd.integration.telescope.find.workspace"] = true,
  },
}
M.load = function()
  if tok then
  Mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      find = {
        args = 0,
        name = "integration.telescope.find",
        subcommands = {
          files = {
            name = "cmd.integration.telescope.find.files",
            args = 0,
          },
          workspace = {
            name = "cmd.integration.telescope.find.workspace",
            args = 0,
          },
        },
      },
    })
  end)
  assert(tok, t)
  t.load_extension("word")
  for _, pic in ipairs(M.data.picker_names) do
    -- t.load_extension(pic)
    k("n", "<plug>word.telescope." .. pic .. "", M.data.pickers()[pic])
  end
  else
    return
  end
end

M.on_event = function(event)
  if event.type == "cmd.events.integration.telescope.find.files" then
    vim.cmd([[Telescope word find_word]])
  elseif event.type == "cmd.events.integration.telescope.find.workspace" then
    vim.cmd([[Telescope word workspace]])
    require("telescope._extensions.word.picker.workspace")()
  end
end

return M
