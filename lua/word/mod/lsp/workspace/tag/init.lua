local M = require("word.mod").create("lsp.workspace.tag")

function M.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class word.lsp.workspace.tag.Data
M.data = {}

---@class word.lsp.workspace.tag.Config
M.config.public = {
  enable = true,
}

return M
