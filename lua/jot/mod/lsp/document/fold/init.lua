local M = Mod.create("lsp.document.fold")

M.setup = function()
  return {
    success = true,
  }
end

M.load = function() end

---@class lsp.document.fold
M.public = {
  ---@type lsp.FoldingRangeOptions
  opts = {
    workDoneProgress = true
  },
  ---@type lsp.FoldingRangeRegistrationOptions
  registration = {
    workDoneProgress = true,
    documentSelector = {
      scheme = "file",
      language = "markdown"
    },
    id = "lua-folding"

  },
  ---@type lsp.FoldingRangeClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    foldingRange = {
      lineFoldingOnly = true,
      rangeLimit = 1000
    },
    foldingRangeKind = {
      valueSet = {
        "comment",
        "imports",
        "region"
      }
    },
    tagSupport = {
      valueSet = {
        "comment",
        "imports",
        "region"
      }
    },
    lineFoldingOnly = true,
    rangeLimit = 1000
  },
  workspace = {
    ---@type lsp.FoldingRangeWorkspaceClientCapabilities
    capabilities = {
      refreshSupport = true
    }

  }
}

return M
