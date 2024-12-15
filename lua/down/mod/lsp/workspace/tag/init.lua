local M = require("down.mod").create("lsp.workspace.tag")

function M.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class down.lsp.workspace.tag.Data
M.data = {}

---@class down.lsp.workspace.tag.Config
M.config = {
  enable = true,
}

return M
