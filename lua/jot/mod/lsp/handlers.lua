local H = {}

H = {
  ---@type lsp.TextDocumentClientCapabilities
  textDocument = {
    codeLens = {
      dynamicRegistration = true,
    },
    inlineCompletion = {
      dynamicRegistration = true,
    },
    codeAction = {
      resolveSupport = {
        properties = {},
      },
    },
    signatureHelp = {
      contextSupport = true,
    },
  },
}

return H
