local M = require('down.mod').create('lsp.notebook')

---@class lsp.notebook
M.data = {

  ---@type lsp.NotebookDocumentClientCapabilities
  capabilities = {
    synchronization = true,
  },

  sync = {
    ---@type lsp.NotebookDocumentSyncClientCapabilities
    capabilities = {
      dynamicRegistration = true,
      executionSummarySupport = true,
    },
    ---@type lsp.NotebookDocumentSyncOptions
    opts = {
      save = true,
      notebookSelector = {
        include = {
          language = 'python',
        },
      },
    },
  },
  handle = {
    ---@param params lsp.DidSaveNotebookDocumentParams
    ---@param callback fun():nil
    ---@param notify_reply_callback fun():nil
    ---@return nil
    save = function(params, callback, notify_reply_callback)
      callback()
      notify_reply_callback()
    end,
    ---@param params lsp.DidOpenNotebookDocumentParams
    ---@param callback fun():nil
    ---@param notify_reply_callback fun():nil
    ---@return nil
    open = function(params, callback, notify_reply_callback)
      ---@type lsp.NotebookDocument
      local doc = {
        uri = params.uri,
        version = params.version,
        cells = {
          {
            source = "print('Hello, World!')",
            kind = lsp.CellKind.Code,
            language = 'python',
            outputs = {
              {
                outputKind = lsp.CellOutputKind.Rich,
                data = {
                  ['text/plain'] = 'Hello, World!',
                },
              },
            },
          },
        },
      }
      callback(doc)
      notify_reply_callback(doc)
    end,
    ---@param params lsp.DidCloseNotebookDocumentParams
    ---@param callback fun():nil
    ---@param notify_reply_callback fun():nil
    ---@return nil
    close = function(params, callback, notify_reply_callback)
      callback()
      notify_reply_callback()
    end,
    ---@param params lsp.DidChangeNotebookDocumentParams
    ---@param callback fun():nil
    ---@param notify_reply_callback fun():nil
    ---@return nil
    change = function(params, callback, notify_reply_callback)
      ---@type lsp.NotebookDocument
      local doc = {
        uri = params.textDocument.uri,
        version = params.textDocument.version,
        cells = {
          {
            source = "print('Hello, World!')",
            kind = lsp.CellKind.Code,
            language = 'python',
            outputs = {
              {
                outputKind = lsp.CellOutputKind.Rich,
                data = {
                  ['text/plain'] = 'Hello, World!',
                },
              },
            },
          },
        },
      }
      callback(doc)
      notify_reply_callback(doc)
    end,
  },
}

return M
