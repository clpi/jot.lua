---@brief lsp
local log = require("jot.util.log")

local M = Mod.create("lsp", {
  "notebook",
  "refactor",
  "signature",
  "command",
  "semantic",
  "action",
  "file",
  "hover",
  "command",
  "moniker",
  "hint",
  "workspace",
  "document",
  "completion",
})

M.setup = function()
  return {
    success = true,
    requires = {
      "integration.treesitter",
      "data",
      "workspace",
      "cmd",
      "ui.popup",
      "lsp.workspace.diagnostic",
      "lsp.file",
      "lsp.workspace.fileops",
      "lsp.workspace.folders",
      "lsp.workspace.config",
      "lsp.workspace.edit",
      "lsp.workspace.symbol",
      "lsp.workspace.lens",
      "lsp.document.diagnostic",
      "lsp.document.hl",
      "lsp.document.link",
      "lsp.command",
      "lsp.document.symbol",
      "lsp.document.color",
      "lsp.document.format",
      "lsp.document.lens",
      "lsp.document",
      "lsp.completion.inline",
      "lsp.semantic",
      "lsp.refactor",
      "lsp.action",
      "lsp.hint",
      "lsp.hover",
      "lsp.signature",
      "lsp.workspace",
      "lsp.completion",
    },
  }
end

---@type lsp.completion
M.public.completion = Mod.get_mod("lsp.completion")
---@type lsp.workspace.lens
M.public.wl = Mod.get_mod("lsp.workspace.lens")
---@type lsp.document.lens
M.public.dl = Mod.get_mod("lsp.document.lens")
---@type lsp.hint
M.public.hint = Mod.get_mod("lsp.hint")
---@type lsp.hover
M.public.hover = Mod.get_mod("lsp.hover")
---@type lsp.refactor
M.public.refactor = Mod.get_mod("lsp.refactor")
---@type lsp.workspace.file_operations
M.public.wf = Mod.get_mod("lsp.workspace.fileops")
---@type lsp.workspace.config
M.public.wc = Mod.get_mod("lsp.workspace.config")
---@type lsp.workspace.diagnostic
M.public.wd = Mod.get_mod("lsp.workspace.diagnostic")
---@type lsp.document.diagnostic
M.public.dd = Mod.get_mod("lsp.document.diagnostic")
---@type lsp.workspace.symbol
M.public.ws = Mod.get_mod("lsp.workspace.symbol")
---@type lsp.document.symbol
M.public.ds = Mod.get_mod("lsp.document.symbol")
---@type lsp.document.format
M.public.format = Mod.get_mod("lsp.document.format")
---@type lsp.document.highlight
M.public.format = Mod.get_mod("lsp.document.hl")
---@type lsp.document.link
M.public.format = Mod.get_mod("lsp.document.link")
---@type lsp.action
M.public.action = Mod.get_mod("lsp.action")
---@type lsp.semantic
M.public.semantic = Mod.get_mod("lsp.semantic")

---@class jot.lsp
M.config.public = {
  diagnostic = { enable = true },
  format = { enable = true },
  actions = {
    enable = true,
  },
  lens = { enable = true },
  hint = { enable = true },
  semantic = {
    enable = true,
  },
  signature = {
    enable = true,
  },
  completion = {
    -- Enable or disable the completion provider
    enable = true,

    -- Try to complete categories provided by jot SE
    categories = false,
  },
}

local workspace ---@type lsp.workspace
local wcfg ---@type lsp.workspace.config
local doc ---@type lsp.document
local wsd ---@type lsp.workspace.diagnostic
local dod ---@type lsp.document.diagnostic
local fmt ---@type lsp.document.format
local len ---@type lsp.document.lens
local refactor ---@type lsp.refactor
local format ---@type lsp.format
local ts ---@type treesitter
local cmp ---@type lsp.completion
local semantic ---@type lsp.semantic
local sig ---@type lsp.signature
local act ---@type lsp.actions
local hov ---@type lsp.hover
local hint ---@type lsp.hint

M.load = function()
  M.required.cmd.add_commands_from_table({
    rename = {
      args = 1,
      name = "rename",
      subcommands = {
        file = {
          min_args = 0,
          max_args = 1,
          name = "rename.file",
        },
        heading = {
          args = 0,
          name = "rename.heading",
        },
      },
    },
    lsp = {
      min_args = 0,
      max_args = 1,
      name = "lsp",
      condition = "markdown",
      subcommands = {
        start = {
          args = 0,
          name = "lsp.workspace",
          subcommands = {
            config = {
              args = 0,
              name = "lsp.workspace.config",
            },
            folders = {
              args = 0,
              name = "lsp.workspace.folders",
            },
          },
        },
        start = {
          args = 0,
          name = "lsp.start",
        },
        restart = {
          args = 0,
          name = "lsp.restart",
        },
        stop = {
          args = 0,
          name = "lsp.stop",
        },
        info = {
          args = 0,
          name = "lsp.info",
        },
        definition = {
          args = 0,
          name = "lsp.definition",
        },
        typeDefinition = {
          args = 0,
          name = "lsp.typeDefinition",
        },
        delaration = {
          args = 0,
          name = "lsp.declaration",
        },
        command = {
          args = 0,
          name = "lsp.command",
        },
        action = {
          args = 0,
          name = "lsp.action",
        },
        lens = {
          args = 0,
          name = "lsp.lens",
        },
        hint = {
          args = 0,
          name = "lsp.hint",
        },
        semantic = {
          args = 0,
          name = "lsp.semantic",
        },
        diagnostic = {
          args = 0,
          name = "lsp.diagnostic",
        },
        format = {
          args = 0,
          name = "lsp.format",
        },
        references = {
          args = 1,
          name = "lsp.references",
        },
        refactor = {
          args = 1,
          name = "lsp.refactor",
        },
      },
    },
  })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = M.public.start_lsp,
  })
end
M.public.ts = Mod.get_mod("integration.treesitter")
M.public.workspace_fo = Mod.get_mod("lsp.workspace.fileops")
M.public.workspace = Mod.get_mod("workspace")
M.public.lsp_ws = Mod.get_mod("lsp.workspace")
M.public.lsp_doc = Mod.get_mod("lsp.workspace")
M.public.refactor = Mod.get_mod("lsp.refactor")
M.public.format = Mod.get_mod("lsp.format")
M.public.cmp = Mod.get_mod("lsp.completion")
M.public.semantic = Mod.get_mod("lsp.semantic")
M.public.sig = Mod.get_mod("lsp.signature")
M.public.hov = Mod.get_mod("lsp.hover")
M.public.hint = Mod.get_mod("lsp.hint")
M.public.act = Mod.get_mod("lsp.actions")


---@type lsp._anonym1.serverInfo
M.public.serverInfo = {
  name = "jot",
  version = "0.1.0-alpha.1",
}
---@return lsp.InitializeResult
M.public.init_result = function()
  -- ---@type lsp.InitializeResult
  -- local initRes = M.public.init_result()
  -- ---@type lsp.ServerCapabilities
  -- local cap = initRes.capabilities

  -- if not M.config.public.completion.enable then
  --   cap.completionProvider = nil
  -- elseif not M.config.public.format.enable then
  --   cap.documentFormattingProvider = nil
  -- elseif not M.config.public.hover.enable then
  --   cap.hoverProvider = nil
  -- elseif not M.config.public.lens.enable then
  --   cap.codeLensProvider = nil
  -- elseif not M.config.public.actions.enable then
  --   cap.codeActionProvider = nil
  -- else
  -- end
  return {
    serverInfo = M.public.serverInfo,
    capabilities = M.public.capabilities,
  }
end

---@type lsp.ServerCapabilities
M.public.capabilities = {
  workspace = {
    workspaceFolders = Mod.get_mod("lsp.workspace.folders").server.capabilities,
    fileOperations = Mod.get_mod("lsp.workspace.fileops").opts,
    workspaceSymbolProvider = Mod.get_mod("lsp.workspace.symbol").opts,
  },
  signatureHelpProvider = Mod.get_mod("lsp.signature").opts,
  renameProvider = Mod.get_mod("lsp.refactor").rename.opts,
  referencesProvider = {
    workDoneProgress = true,
  },
  colorProvider = Mod.get_mod("lsp.document.color").opts,
  diagnosticProvider = Mod.get_mod("lsp.workspace.diagnostic").opts,
  workspaceSymbolProvider = Mod.get_mod("lsp.workspace.symbol").opts,
  -- documentOnTypeFormattingProvider = Mod.get_mod("lsp.document.format").opts,
  -- documentRangeFormattingProvider = Mod.get_mod("lsp.document.format").opts,
  foldingRangeProvider = Mod.get_mod("lsp.document.fold").opts,
  documentSymbolProvider = Mod.get_mod("lsp.document.symbol").opts,
  documentLinkProvider = Mod.get_mod("lsp.document.link").opts,
  documentColorProvider = Mod.get_mod("lsp.document.color").opts,
  hoverProvider = Mod.get_mod("lsp.hover").opts,
  inlineCompletionProvider = Mod.get_mod("lsp.completion.inline").opts,
  executeCommandProvider = Mod.get_mod("lsp.command").opts,
  inlayHintProvider = Mod.get_mod("lsp.hint").opts,
  monikerProvider = Mod.get_mod("lsp.moniker").opts,
  notebookDocumentSync = Mod.get_mod("lsp.notebook").sync.opts,
  semanticTokensProvider = Mod.get_mod("lsp.semantic").opts,
  inlineValueProvider = Mod.get_mod("lsp.completion.inline.value").opts,
  -- textDocument = Mod.get_mod("lsp.document").opts,
  textDocumentSync = Mod.get_mod("lsp.document").sync.opts,
  codeActionProvider = Mod.get_mod("lsp.action").opts,
  codeLensProvider = Mod.get_mod("lsp.workspace.lens").opts,
  documentFormattingProvider = Mod.get_mod("lsp.document.format").opts,
  documentHighlightProvider = Mod.get_mod("lsp.document.hl").opts,
  definitionProvider = true,
  declarationProvider = true,
  ---@type lsp.LSPAny
  experimental = true,
  callHierarchyProvider = true,
  implementationProvider = true,
  linkedEditingRangeProvider = true,
  positionEncoding = "utf-8",
  selectionRangeProvider = true,
  typeDefinitionProvider = true,
  typeHierarchyProvider = true,
  ---@type lsp.InlayHintOptions
  inlayHintsProvider = Mod.get_mod("lsp.hint").opts,
  completionProvider = Mod.get_mod("lsp.completion").opts,
}

---@type lsp.InitializeResult
M.public.initializeResult = {

  serverInfo = {
    name = "jot",
    version = "0.0.1",
  },
  capabilities = M.public.capabilities,
}

M.public.handlers = {

  ["exit"] = function() end,
  ---@param params lsp.InitializeParams
  ---@param callback fun(err: any, result: lsp.InitializeResult):nil
  ---@param notify_reply_callback fun(err: any, result: lsp.InitializeResult):nil
  ["initialize"] = function(params, callback, notify_reply_callback)
    ---@type lsp.InitializeResult
    local ir = M.public.initializeResult
    if not M.config.public.completion.enable then
      ir.capabilities.completionProvider = nil
    elseif not M.config.public.actions.enable then
      ir.capabilities.codeActionProvider = nil
    elseif not M.config.public.lens.enable then
      ir.capabilities.codeLensProvider = nil
    end

    callback(nil, ir)
  end,

  ["textDocument/moniker"] = function(
      params,
      callback,
      _notify_reply_callback
  )
  end,
  ["workspace/applyEdit"] = function(
      params,
      callback,
      _notify_reply_callback
  )
  end,
  ["textDocument/documentLink"] = function(
      params,
      callback,
      _notify_reply_callback
  )
  end,
  ["textDocument/hover"] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    -- vim.lsp.buf.hover()
    -- local node = ts.get_first_node_on_line(buf, params.position.line)
    -- if not node then
    --   return
    -- end

    -- local type = node:type()
    -- if type:match("^heading%d") then
    --   local heading_line = vim.api.nvim_buf_get_lines(
    --     buf,
    --     params.position.line,
    --     params.position.line + 1,
    --     true
    --   )[1]
    --   callback(nil, { contents = { { value = heading_line } } })
    -- end
    callback()
  end,

  ["textDocument/formatting"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    format.format_document(params.textDocument.uri, callback)
  end,

  ["textDocument/inlineValue"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    callback()
  end,
  ["textDocument/inlayHint"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    local hints = {}
    -- for _, node in ipairs(ts.get_nodes(buf)) do
    --   if node:type() == "heading1" then
    --     table.insert(hints, {
    --       range = {
    --         start = { line = node:range().start.line, character = 0 },
    --         ["end"] = { line = node:range().start.line, character = 0 },
    --       },
    --       kind = "Other",
    --       label = "Rename Heading",
    --     })
    --   end
    -- end
    _callback(nil, hints)
  end,
  ["textDocument/documentSymbol"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local symbols = {}
    -- for _, node in ipairs(ts.get_nodes(buf)) do
    --   if node:type() == "heading1" then
    --     table.insert(symbols, {
    --       name = vim.api.nvim_buf_get_lines(
    --         buf,
    --         node:range().start.line,
    --         node:range().start.line + 1,
    --         true
    --       )[1],
    --       kind = 1,
    --       range = {
    --         start = { line = node:range().start.line, character = 0 },
    --         ["end"] = { line = node:range().start.line, character = 0 },
    --       },
    --       selectionRange = {
    --         start = { line = node:range().start.line, character = 0 },
    --         ["end"] = { line = node:range().start.line, character = 0 },
    --       },
    --     })
    --   end
    -- end
    callback(nil, symbols)
  end,

  ["textDocument/linkedEditingRange"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    -- local node = ts.get_first_node_on_line(buf, params.position.line)
    -- if not node then
    --   return
    -- end

    -- local type = node:type()
    -- if type:match("^heading%d") then
    --   local range = {
    --     start = { line = params.position.line, character = 0 },
    --     ["end"] = { line = params.position.line + 1, character = 0 },
    --   }
    -- end
    callback(nil, range)
  end,
  ["textDocument/foldingRange"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local ranges = {}
    -- for _, node in ipairs(ts.get_nodes(buf)) do
    --   if node:type() == "heading1" then
    --     table.insert(ranges, {
    --       startLine = node:range().start.line,
    --       startCharacter = 0,
    --       endLine = node:range().start.line,
    --       endCharacter = 0,
    --       kind = "region",
    --     })
    --   end
    -- end
    callback(nil, ranges)
  end,
  ["textDocument/completion"] = function(p, c, _)
    -- Attempt to hijack completion for categories completions
    if M.config.public.completion.categories then
      local cats = cmp.category_completion()
      if cats and not vim.tbl_isempty(cats) then
        c(nil, cmp.category_completion())
        return
      end
    end
    cmp.completion_handler(p, c, _)
  end,

  ["textDocument/prepareRename"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    -- local node = ts.get_first_node_on_line(buf, params.position.line)
    -- if not node then
    --   return
    -- end

    -- local type = node:type()
    -- if type:match("^heading%d") then
    --   -- let the rename go through
    --   local range = {
    --     start = { line = params.position.line, character = 0 },
    --     ["end"] = { line = params.position.line + 1, character = 0 },
    --   }
    --   local heading_line = vim.api.nvim_buf_get_lines(
    --     buf,
    --     params.position.line,
    --     params.position.line + 1,
    --     true
    --   )[1]
    --   callback(nil, { range = range, placeholder = heading_line })
    -- end
  end,

  ["textDocument/codeLens"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local codeLens = {}
    -- for _, node in ipairs(ts.get_nodes(buf)) do
    --   if node:type() == "heading1" then
    --     table.insert(codeLens, {
    --       range = {
    --         start = { line = node:range().start.line, character = 0 },
    --         ["end"] = { line = node:range().start.line, character = 0 },
    --       },
    --       command = {
    --         title = "Rename Heading",
    --         command = "lsp.rename.heading",
    --         arguments = {
    --           line_content = vim.api.nvim_buf_get_lines(
    --             buf,
    --             node:range().start.line,
    --             node:range().start.line + 1,
    --             true
    --           )[1],
    --           cursor_position = { node:range().start.line, 0 },
    --         },
    --       },
    --     })
    --   end
    -- end
    callback(nil, codeLens)
  end,

  ["textDocument/references"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local references = {}
    -- for _, node in ipairs(ts.get_nodes(buf)) do
    --   if node:type() == "heading1" then
    --     table.insert(references, {
    --       uri = vim.uri_from_bufnr(buf),
    --       range = {
    --         start = { line = node:range().start.line, character = 0 },
    --         ["end"] = { line = node:range().start.line, character = 0 },
    --       },
    --     })
    --   end
    -- end
    callback(nil, references)
  end,

  ["workspace/inlayHint/refresh"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.uri)
    local hints = {}
    -- for _, node in ipairs(ts.get_nodes(buf)) do
    --   if node:type() == "heading1" then
    --     table.insert(hints, {
    --       range = {
    --         start = { line = node:range().start.line, character = 0 },
    --         ["end"] = { line = node:range().start.line, character = 0 },
    --       },
    --       kind = "Other",
    --       label = "Rename Heading",
    --     })
    --   end
    -- end
    _callback(nil, hints)
  end,

  ["typeHierarchy/subtypes"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["typeHierarchy/supertypes"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["textDocument/typeDefinition"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["workspace/configuration"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["workspace/executeCommand"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["workspace/workspaceFolders"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["workspace/symbol"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  -- ["textDocument/semanticTokens/full"] = function(params, _callback, _notify_reply_callback)
  -- end,
  -- ["textDocument/semanticTokens/full/delta"] = function(params, _callback, _notify_reply_callback)
  -- end,
  ["textDocument/publishDiagnostics"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["textDocument/prepareTypeHierarchy"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["textDocument/implementation"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    -- local node = ts.get_first_node_on_line(buf, params.position.line)
    -- if not node then
    --   return
    -- end

    -- local type = node:type()
    -- if type:match("^heading%d") then
    --   local range = {
    --     start = { line = params.position.line, character = 0 },
    --     ["end"] = { line = params.position.line + 1, character = 0 },
    --   }
    --   local heading_line = vim.api.nvim_buf_get_lines(
    --     buf,
    --     params.position.line,
    --     params.position.line + 1,
    --     true
    --   )[1]
    --   callback(nil, { range = range, placeholder = heading_line })
    -- end
  end,
  ["textDocument/rename"] = function(params, _callback, _notify_reply_callback)
    refactor.rename_heading(params.position.line + 1, params.newName)
  end,

  ["textDocument/codeLens"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local codeLens = {}
    -- for _, node in ipairs(ts.get_nodes(buf)) do
    --   if node:type() == "heading1" then
    --     table.insert(codeLens, {
    --       range = {
    --         start = { line = node:range().start.line, character = 0 },
    --         ["end"] = { line = node:range().start.line, character = 0 },
    --       },
    --       command = {
    --         title = "Rename Heading",
    --         command = "lsp.rename.heading",
    --         arguments = {
    --           line_content = vim.api.nvim_buf_get_lines(
    --             buf,
    --             node:range().start.line,
    --             node:range().start.line + 1,
    --             true
    --           )[1],
    --           cursor_position = { node:range().start.line, 0 },
    --         },
    --       },
    --     })
    --   end
    -- end
    vim.lsp.codelens.display(codeLens, buf, params.textDocument.uri)
    callback(nil, codeLens)
  end,

  ["textDocument/documentHighlight"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    vim.lsp.buf.document_highlight()
  end,
  ["textDocument/signatureHelp"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    vim.lsp.buf.signature_help()
  end,
  ["textDocument/codeAction"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local actions = {}
    -- for _, node in ipairs(ts.get_nodes(buf)) do
    --   if node:type() == "heading1" then
    --     table.insert(actions, {
    --       title = "Rename Heading",
    --       command = {
    --         title = "Rename Heading",
    --         command = "lsp.rename.heading",
    --         arguments = {
    --           line_content = vim.api.nvim_buf_get_lines(
    --             buf,
    --             node:range().start.line,
    --             node:range().start.line + 1,
    --             true
    --           )[1],
    --           cursor_position = { node:range().start.line, 0 },
    --         },
    --       },
    --     })
    --   end
    -- end
    vim.notify("CODE ACTIONS")
    callback(nil, actions)
  end,

  ["workspace/willRenameFiles"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
    for _, files in ipairs(params.files) do
      local old = vim.uri_to_fname(files.oldUri)
      local new = vim.uri_to_fname(files.newUri)
      refactor.rename_file(old, new)
    end
  end,
}

M.public.start_lsp = function()
  ---@type lsp.InitializeResult
  -- local ir = M.public.init_result()
  vim.lsp.start(
  ---@type vim.lsp.ClientConfig
    {
      name = "jot",
      -- workspace_folders = {
      -- Mod.get_mod("workspace").get_current_workspace()
      -- },
      capabilities = M.public.init_result().capabilities,
      handlers = M.public.handlers,
      commands = {
        ls = {
          function()
            vim.lsp.buf.rename()
          end,
          description = "Rename",
        },
        rename = {
          function()
            vim.lsp.buf.rename()
          end,
          description = "Rename",
        },
      },
      cmd = function(_dispatchers)
        local members = {
          trace = "messages",
          request = function(method, params, callback, notify_reply_callback)
            if M.public.handlers[method] then
              M.public.handlers[method](params, callback, notify_reply_callback)
            else
              log.debug("Unexpected LSP method: " .. method)
            end
          end,
          notify = function(_method, _params) end,
          is_closing = function() end,
          terminate = function() end,
        }
        return members
      end,
      root_dir = tostring(Mod.get_mod("workspace").get_current_workspace()[2]),
    }
  )
  -- vim.api.nvim_create_autocmd('LspAttach', {
  --   callback = function(args)
  --     local client = vim.lsp.get_client_by_id(args.data.client_id)
  --     if client.supports_method('textDocument/implementation') then
  --       -- Create a keymap for vim.lsp.buf.implementation
  --     end
  --     if client.supports_method('textDocument/completion') then
  --       -- Enable auto-completion
  --       vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
  --     end
  --     if client.supports_method('textDocument/formatting') then
  --       -- Format the current buffer on save
  --       vim.api.nvim_create_autocmd('BufWritePre', {
  --         buffer = args.buf,
  --         callback = function()
  --           vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
  --         end,
  --       })
  --     end
  --   end,
  -- })
end

M.events.subscribed = {
  cmd = {
    ["lsp.start"] = true,
    ["lsp.restart"] = true,
    ["lsp.stop"] = true,
    ["lsp.info"] = true,
    ["lsp.workspace"] = true,
    ["lsp.workspace.folders"] = true,
    ["lsp.workspace.config"] = true,
    ["lsp.actions"] = true,
    ["lsp.references"] = true,
    ["lsp.implementation"] = true,
    ["lsp.semantic"] = true,
    ["lsp.typeDefinition"] = true,
    ["lsp.declaration"] = true,
    ["lsp.definition"] = true,
    ["lsp.lens"] = true,
    ["lsp.command"] = true,
    ["lsp.hint"] = true,
    ["lsp.diagnostic"] = true,
    ["lsp.format"] = true,
    ["lsp.refactor"] = true,
    ["rename"] = true,
    ["rename.file"] = true,
    ["rename.heading"] = true,
  },
}

M.on_event = function(event)
  if M.private[event.split_type[2]] then
    M.private[event.split_type[2]](event)
  end
end

M.private["lsp.stop"] = function(e)
  vim.lsp.stop_client(vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
    name = "jot",
  }))
end
M.private["lsp.rename.file"] = function(event)
  local new_path = event.content[1]
  local current = vim.api.nvim_buf_get_name(0)
  if new_path then
    refactor.rename_file(current, new_path)
  else
    vim.schedule(function()
      vim.ui.input({ prompt = "New Path: ", default = current }, function(text)
        refactor.rename_file(current, text)
        vim.cmd.e(text)
      end)
    end)
  end
end
M.private["lsp.hint"] = function(event)
  vim.ui.input({
    prompt = "lsp.hint",
  }, function(selected)
    if selected then
      vim.notify("sdkfsjf")
    end
  end)
end
M.private["lsp.document.format"] = function(event)
  vim.ui.select({
    "hi",
    "there",
    "big",
    "guy",
  }, {
    prompt = "Select a format",
  }, function(selected)
    if selected then
      format.format_document(vim.api.nvim_buf_get_name(0))
    end
  end)
end
M.private["lsp.command"] = function(event)
  vim.ui.select({})
end
M.private["lsp.semantic"] = function(event) end
M.private["lsp.implementation"] = function(event) end
M.private["lsp.declaration"] = function(event) end
M.private["lsp.typeDefinition"] = function(event) end
M.private["lsp.definition"] = function(event) end
M.private["lsp.workspace"] = function(event)
  M.private["lsp.workspace.lens"] = function(event) end
  M.private["lsp.document.lens"] = function(event) end
  vim.lsp.util.open_floating_preview({})
end
M.private["lsp.workspace.config"] = function(event)
  vim.lsp.util.open_floating_preview({})
end
M.private["lsp.workspace.folders"] = function(event)
  vim.lsp.util.open_floating_preview({})
end
M.private["lsp.action"] = function(event)
  vim.lsp.util.open_floating_preview({})
end
M.private["rename.heading"] = function(event)
  local line_number = event.cursor_position[1]
  local prefix = string.match(event.line_content, "^%s*%*+ ")
  if not prefix then -- this is a very very simple check that we're on a heading line. We use TS in the actual rename_heading function
    return
  end

  vim.schedule(function()
    vim.ui.input(
      { prompt = "New Heading: ", default = event.line_content },
      function(text)
        if not text then
          return
        end

        refactor.rename_heading(line_number, text)
      end
    )
  end)
end

M.run_dict = function()
  vim.lsp.start({
    name = "lsp.sh",
    cmd = { "lsp.sh" },
    workspace_folders = M.required.workspace.get_dirs(),
    root_dir = tostring(M.required.workspace.get_current_workspace()[2]),
  })
end

return M
