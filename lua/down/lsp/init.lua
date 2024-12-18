local Lsp = {}

Lsp.attributes = {

}

Lsp.capabilities = {
  textDocumentSync = {
    save = {
      includeText = false
    }
  },
  definitionProvider = true,
  hoverProvider = true,
  workspace = {
    workspaceFolders = {
      supported = true,
      changeNotifications = true
    },
    fileOperations = {
      didRename = {
        filters = function()
          local filters = {}
          return filters
        end,
      }
    }
  },
  typeDefinitionProvider = true,
  implementationProvider = true,
  referencesProvider = true,
  workspaceSymbolProvider = true,
  codeLensProvider = {
    resolveProvider = true
  },
  executeCommandProvider = {
    commands = {
      "down.rename",
      "down.note.new",
      "down.workspace.change",
      "down.workspace.new",
      "down.workspace.delete",
      "down.file.remove",
      "down.file.new"
    }
  },
  codeActionProvider = {
    codeActionKinds = {
      '', 'quickfix',
      'refactor.rewrite',
      'refactor.extract',
    },
    resolveProvider = false
  },
  diagnosticProvider = {
    identifier = "down",
    interFileDependencies = true,
    workspaceDiagnostics = true,
  },
  inlayHintProvider = {
    resolveProvider = true
  },
  documentSymbolProvider = true,
  documentRangeFormattingProvider = true,
  foldingRangeProvider = true,

}
Lsp.info = {
  serverInfo = { name = "down", version = "0.1.2-alpha" },
  capabilities = Lsp.capabilities
}

Lsp.register = function(method)
  return function(attr)
    Lsp.attributes[method] = attr
  end
end

Lsp.register "initialize" {
  function(params)
    if params.rootUri then

    end
    if params.workspaceFolders then

    end
    print "Server init"
    return Lsp.info
  end
}

Lsp.register "initialized" {
  ---@async
  function(params)
    local _ = {}
    local registrations = {}
    print "Server initialized"
    return true
  end
}

Lsp.register "exit" {
  function()
    print "Server exit"
    os.exit(0, true)
  end
}

Lsp.register "shutdown" {
  function()
    print "Server shutdown"
    return true
  end
}
Lsp.register "workspace/didChangeConfiguration" {
  ---@async
  function(params)

  end
}
Lsp.register "textDocument/completion" {
  ---@async
  function(params)
  end
}
Lsp.register "completionItem/resolve" {
  ---@async
  function(params)
  end
}
Lsp.register "textDocument/codeAction" {
  ---@async
  function(params)
  end
}
Lsp.register "textDocument/codeLens" {
  ---@async
  function(params)
    local lenses = {}
    return lenses
  end
}
Lsp.register "workspace/executeCommand" {
  ---@async
  function(params)

  end
}
Lsp.register "codeLens/resolve" {
  ---@async
  function(params)
  end
}
Lsp.register "textDocument/inlayHint" {
  ---@async
  function(params)
    local hints = {}
    return hints
  end
}
Lsp.register "inlayHint/resolve" {
  ---@async
  function(params)
  end
}
return Lsp
