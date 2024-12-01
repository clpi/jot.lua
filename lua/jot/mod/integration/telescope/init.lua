local M             = Mod.create("integration.telescope")
local k             = vim.keymap.set

M.setup             = function()
  return {
    success = true,
    requires = { "cmd", "workspace" }
  }
end

M.private           = {
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
M.pickers           = function()
  local r = {}
  for _, pic in ipairs(M.private.picker_names) do
    local ht, te = pcall(require, "telescope._extensions.jot.picker." .. pic)
    if ht then
      r[pic] = te
    end
    r[pic] = require("telescope._extensions.jot.picker." .. pic)
  end
  return r
end
M.events.subscribed = {
  cmd = {
    ["cmd.integration.telescope.find.files"] = true,
    ["cmd.integration.telescope.find.workspace"] = true,
  }
}
M.load              = function()
  Mod.await("cmd", function(cmd)
    cmd.add_commands_from_table {
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

        }
      }

    }
  end)
  local hast, t = pcall(require, "telescope")
  assert(hast, t)
  t.load_extension("jot")
  for _, pic in ipairs(M.private.picker_names) do
    -- t.load_extension(pic)
    k("n", "<plug>jot.telescope." .. pic .. "", M.pickers()[pic])
  end
end

M.on_event          = function(event)
  if event.type == "cmd.events.integration.telescope.find.files" then
    vim.cmd [[Telescope jot find_jot]]
  elseif event.type == "cmd.events.integration.telescope.find.workspace" then
    vim.cmd [[Telescope jot workspace]]
    require("telescope._extensions.jot.picker.workspace")()
  end
end

return M
