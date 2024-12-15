local M      = Mod.create("integration.telescope")
local k      = vim.keymap.set

M.setup      = function()
  return {
    loaded = true,
    requires = { "cmd", "workspace" }
  }
end

M.data.data    = {
  picker_names = {
    "linkable",
    "lsp",
    "link",
    "todo",
    "actions",
    "note",
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
M.pickers    = function()
  local r = {}
  for _, pic in ipairs(M.data.data.picker_names) do
    local ht, te = pcall(require, "telescope._extensions.word.picker."..pic)
    if ht then
      r[pic] = te
    end
    r[pic] = require("telescope._extensions.word.picker."..pic)
  end
  return r
end
M.subscribed = {
  cmd = {
    ["integration.telescope.lsp"] = true,
    ["integration.telescope.workspace"] = true,
    ["integration.telescope.note"] = true,
    ["integration.telescope"] = true,
    ["integration.telescope.files"] = true,
    ["integration.telescope.actions"] = true,
    ["integration.telescope.commands"] = true,
    ["integration.telescope.todo"] = true,
    ["integration.telescope.linkable"] = true,
    ["integration.telescope.link"] = true,
  }
}
M.load       = function()
  Mod.await("cmd", function(cmd)
    cmd.add_commands_from_table {
      telescope = {
        args = 0,
        name = "integration.telescope",
        subcommands = {
          commands = {
            name = "integration.telescope.commands",
            args = 0,

          },
          actions = {
            name = "integration.telescope.actions",
            args = 0,

          },
          link = {
            name = "integration.telescope.link",
            args = 0,

          },
          todo = {
            name = "integration.telescope.todo",
            args = 0,

          },
          linkable = {
            name = "integration.telescope.linkable",
            args = 0,

          },
          files = {
            name = "integration.telescope.files",
            args = 0,

          },
          lsp = {
            name = "integration.telescope.lsp",
            args = 0,

          },
          note = {
            name = "integration.telescope.note",
            args = 0,

          },
          workspace = {
            name = "integration.telescope.workspace",
            args = 0,

          },

        }
      }

    }
  end)
  local hast, t = pcall(require, "telescope")
  assert(hast, t)
  t.load_extension("word")
  for _, pic in ipairs(M.data.data.picker_names) do
    -- t.load_extension(pic)
    k("n", "<plug>word.telescope."..pic.."", M.pickers()[pic])
  end
end

M.on   = function(event)
  if event.type == "integration.telescope" then
  elseif event.type == "integration.telescope.link" then
    vim.cmd [[Telescope word find_word]]
  elseif event.type == "integration.telescope.workspace" then
    vim.cmd [[Telescope word find_word]]
  elseif event.type == "integration.telescope.actions" then
    vim.cmd [[Telescope word find_word]]
  elseif event.type == "integration.telescope.commands" then
    vim.cmd [[Telescope word find_word]]
  elseif event.type == "integration.telescope.todo" then
    vim.cmd [[Telescope word find_word]]
  elseif event.type == "integration.telescope.lsp" then
    vim.cmd [[Telescope word find_word]]
  elseif event.type == "integration.telescope.files" then
    vim.cmd [[Telescope word find_word]]
    require("telescope._extensions.word.picker.files")()
  elseif event.type == "integration.telescope.workspace" then
    vim.cmd [[Telescope word workspace]]
    require("telescope._extensions.word.picker.workspace")()
  end
end

return M
