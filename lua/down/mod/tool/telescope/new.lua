local mod = require("word.mod")
local M = mod.new("tool.telescope")
local k = vim.keymap.set

M.setup = function()
  return {
    loaded = true,
    requires = { "cmd", "workspace" },
  }
end

M.data.data = {
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
M.pickers = function()
  local r = {}
  for _, pic in ipairs(M.data.data.picker_names) do
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
    ["tool.telescope.lsp"] = true,
    ["tool.telescope.workspace"] = true,
    ["tool.telescope.note"] = true,
    ["tool.telescope"] = true,
    ["tool.telescope.files"] = true,
    ["tool.telescope.actions"] = true,
    ["tool.telescope.commands"] = true,
    ["tool.telescope.todo"] = true,
    ["tool.telescope.linkable"] = true,
    ["tool.telescope.link"] = true,
  },
}
M.load = function()
  Mod.await("cmd", function(cmd)
    cmd.add_commands_from_table({
      telescope = {
        args = 0,
        name = "tool.telescope",
        subcommands = {
          commands = {
            name = "tool.telescope.commands",
            args = 0,
          },
          actions = {
            name = "tool.telescope.actions",
            args = 0,
          },
          link = {
            name = "tool.telescope.link",
            args = 0,
          },
          todo = {
            name = "tool.telescope.todo",
            args = 0,
          },
          linkable = {
            name = "tool.telescope.linkable",
            args = 0,
          },
          files = {
            name = "tool.telescope.files",
            args = 0,
          },
          lsp = {
            name = "tool.telescope.lsp",
            args = 0,
          },
          note = {
            name = "tool.telescope.note",
            args = 0,
          },
          workspace = {
            name = "tool.telescope.workspace",
            args = 0,
          },
        },
      },
    })
  end)
  local hast, t = pcall(require, "telescope")
  assert(hast, t)
  t.load_extension("down")
  for _, pic in ipairs(M.data.data.picker_names) do
    -- t.load_extension(pic)
    k("n", "<plug>down.telescope." .. pic .. "", M.pickers()[pic])
  end
end

M.on = function(event)
  if event.type == "tool.telescope" then
  elseif event.type == "tool.telescope.link" then
    vim.cmd([[Telescope down find_down]])
  elseif event.type == "tool.telescope.workspace" then
    vim.cmd([[Telescope down find_down]])
  elseif event.type == "tool.telescope.actions" then
    vim.cmd([[Telescope down find_down]])
  elseif event.type == "tool.telescope.commands" then
    vim.cmd([[Telescope down find_down]])
  elseif event.type == "tool.telescope.todo" then
    vim.cmd([[Telescope down find_down]])
  elseif event.type == "tool.telescope.lsp" then
    vim.cmd([[Telescope down find_down]])
  elseif event.type == "tool.telescope.files" then
    vim.cmd([[Telescope down find_down]])
    require("telescope._extensions.down.picker.files")()
  elseif event.type == "tool.telescope.workspace" then
    vim.cmd([[Telescope down workspace]])
    require("telescope._extensions.down.picker.workspace")()
  end
end

return M
