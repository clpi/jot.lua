local M = Mod.create("lsp.document.semantic")

---@alias lsp.document.semantic.Kind lsp.SemanticTokenTypes
---@alias lsp.document.semantic.Modifier lsp.SemanticTokenModifiers

function M.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.semantic
M.data = {

  delta = {
    ---@type lsp.SemanticTokensDelta
    opts = {
      edits = {
        {
          start = 1,
          deleteCount = 1,
          data = {
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
          },
        },
      },
      resultId = "1",
    },
  },

  ---@type lsp.SemanticTokensOptions
  opts = {
    workDoneProgress = true,
    full = {
      delta = true,
    },
    legend = true,
    range = true,
  },
  ---@type lsp.SemanticTokensClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    requests = {
      range = true,
      full = {
        delta = true,
      },
    },
    augmentsSyntaxTokens = true,
    tokenTypes = {
      1,
      2,
      3,
      4,
    },
    tokenModifiers = {
      1,
      2,
      3,
      4,
    },

    formats = {
      {
        tokenType = 1,
        tokenModifiers = {
          1,
          2,
          3,
          4,
        },
      },
    },
    multilineTokenSupport = true,
    overlappingTokenSupport = true,
    serverCancelSupport = true,
  },

  ---@param param lsp.SemanticTokensParams
  ---@return lsp.SemanticTokens
  handle = function(param)
    ---@type lsp.SemanticTokens
    local h = {
      resultId = "1",
      data = {
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
      },
    }
    return h
  end,
}

return M
