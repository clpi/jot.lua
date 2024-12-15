local mod = require("word.mod")

local M = mod.create("data.metadata")

M.setup = function()
  -- mod.await("cmd", function(cmd)
  --   cmd.add_commands_from_table({
  --     meta = {
  --       subcommands = {
  --         clear = {
  --           args = 0,
  --           name = "data.metadata.clear",
  --         },
  --         update = {
  --           args = 0,
  --           name = "data.metadata.update",
  --         },
  --         insert = {
  --           name = "data.metadata.insert",
  --           args = 0,
  --         },
  --       },
  --       name = "metadata",
  --     },
  --   })
  -- end)
  return {
    loaded = true,
    required = {
      "cmd",
      "workspace",
    },
  }
end

---@class word.data.metadata.Config
M.config.public = {
  fields = {},
}

---@class word.data.metadata.Data
M.data = {
  buf_inject_frontmatter = function()
    local id = ""
    local title = ""
    local date = ""
    local tags = "#day #note"
    vim.api.nvim_buf_set_lines(0, 0, 0, true, {
      "---",
      "id: " .. id,
      "title: " .. title,
      "date: " .. date,
      "tags: " .. tags,
      "---",
      "# " .. title,
      " ",
    })
  end,
}

M.events.subscribed = {
  cmd = {
    ["data.metadata.insert"] = true,
    ["data.metadata.update"] = true,
  },
}

M.on = function() end

return M
