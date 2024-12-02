local M = Mod.create("lsp.workspace.tag")

function M.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.workspace.symbol
M.data = {}
return M
