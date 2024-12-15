local M = Mod.create("lsp.document.action")

function M.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class lsp.document.action.Config
M.config = { enable = true }

---@class lsp.document.action.Data
M.data = {

  ---@type lsp.CodeActionRegistrationOptions
  registration = {
    resolveProvider = true,
    workDoneProgress = true,
    codeActionKinds = {
      "quickfix",
      "refactor",
      "refactor.extract",
      "refactor.inline",
      "refactor.rewrite",
      "source",
      "source.fixAll",
      "source.organizeImports",
    },
    documentSelector = {
      scheme = "file",
      language = "markdown",
    },
  },
  ---@type lsp.CodeActionClientCapabilities
  capabililities = {
    dynamicRegistration = true,
    honorsChangeAnnotations = true,
    codeActionLiteralSupport = {
      codeActionKind = {
        valueSet = {
          "quickfix",
          "refactor",
          "refactor.extract",
          "refactor.inline",
          "refactor.rewrite",
          "source",
          "source.fixAll",
          "source.organizeImports",
        },
      },
    },
    dataSupport = true,
    disabledSupport = true,
    isPreferredSupport = true,
    resolveSupport = {
      properties = {
        "edit",
        "command",
        "data",
        "workspaceEdit",
        "fileChanges",
        "resourceOperations",
        "command",
        "createFile",
        "renameFile",
        "deleteFile",
      },
    },
  },
  ---@type lsp.CodeActionContext
  context = {
    ---@type lsp.CodeActionKind[]
    only = {
      "refactor.rewrite",
      "refactor.inline",
    },
    ---@type lsp.Diagnostic[]
    diagnostics = {},
    ---@type lsp.CodeActionTriggerKind
    triggerKind = 2,
  },

  ---@param param lsp.CodeActionParams
  ---@param callback fun(action: lsp.CodeAction):nil
  ---@param notify_reply_callback fun():nil
  ---@return nil
  handle = function(param, callback, notify_reply_callback)
    -- param.context.
    ---@type lsp.CodeAction
    local ca = {
      ---@type lsp.CodeActionKind
      kind = "refactor.inline",
      title = "inline refactor",
      ---@type lsp.Command
      command = {
        command = "test",
        title = "test",
        arguments = {
          "test",
        },
      },
      ---@type lsp.WorkspaceEdit
      edit = {
        ---@type lsp.TextDocumentEdit[]
        documentChanges = {
          {
            textDocument = {
              uri = "test",
            },
            edits = {
              {
                newText = "newtest",
                ---@type lsp.Range
                range = {
                  start = {
                    line = 1,
                    character = 1,
                  },
                  ["end"] = {
                    line = 1,
                    character = 1,
                  },
                },
              },
            },
          },
        },
        ---@type lsp.Diagnostic[]
        diagnostics = {},
        data = {
          test = "test",
        },
        arguments = {
          "test",
        },
        ---@type lsp.ChangeAnnotation[]
        changeAnnotations = {
          {
            description = "test",
            needsConfirmation = false,
            detail = "test",
            label = "test",
          },
        },
        ---@type lsp.TextEdit[]
        changes = {
          {
            newText = "newtest",
            ---@type lsp.Range
            range = {
              start = {
                line = 1,
                character = 1,
              },
              ["end"] = {
                line = 1,
                character = 1,
              },
            },
          },
        },
      },
      disabled = {
        reason = "test",
      },
      isPreferred = true,
    }
    return callback(ca)
  end,

  ---@type lsp.CodeActionOptions
  opts = {
    resolveProvider = true,
    workDoneProgress = true,
    ---@type lsp.CodeActionKind[]
    codeActionKinds = {
      "quickfix",
      "refactor",
      "refactor.extract",
      "refactor.inline",
      "refactor.rewrite",
      "source",
      "source.fixAll",
      "source.organizeImports",
    },
  },
  ---@type lsp.CodeActionClientCapabilities
  capabilities = {},
}

return M
