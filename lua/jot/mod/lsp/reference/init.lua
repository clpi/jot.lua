local I = require("jot.mod").create("lsp.reference")

---@class lsp.reference
I.public = {
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
