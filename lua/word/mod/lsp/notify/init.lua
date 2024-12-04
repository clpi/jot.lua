local N = require("word.mod").create("lsp.notify")

N.setup = function()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.notify.Data
N.data = {
}

return N
