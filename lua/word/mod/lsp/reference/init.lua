local I = require("word.mod").create("lsp.reference")

function I.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.reference
I.data = {
  ---@type lsp.ReferenceClientCapabilities
  capabilities = {
    dynamicRegistration = true,
  },
  ---@type lsp.ReferenceOptions
  opts = {
    workDoneProgress = true,
  },
}
return I
