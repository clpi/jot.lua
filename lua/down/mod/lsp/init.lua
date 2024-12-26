local Path = require("pathlib")
local mod, log = require("down.mod"), require("down.util.log")
local tsu = require("nvim-treesitter.ts_utils")
local tq, vl = vim.treesitter.query, vim.lsp
local ll, lu, lb = vl.log, vl.util, vl.buf

---@type down.Mod
local M = require 'down.mod'.create("lsp", {
  "notebook",
  "reference",
  "window",
  "refactor",
  "definition",
  "reference",
  "command",
  "implementation",
  "type",
  "command",
  "moniker",
  "workspace",
  "document",
  "declaration",
  "completion",
})


M.opts = function() end

M.maps = function()
  local bufnr = require("down.util.buf").buf()
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  -- vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = 0 })
  vim.keymap.set("n", ",.", function()
    vim.lsp.util.open_floating_preview(
      vim.api.nvim_buf_get_lines(0, 0, 10, false),
      "markdown",
      {
        wrap = true,
        focusable = false,
      }
    )
  end, {})
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = 0 })
  vim.keymap.set("n", "gR", vim.lsp.buf.references, { buffer = 0 })
  vim.keymap.set("n", "gr", vim.lsp.buf.rename, { buffer = 0 })
  -- vim.keymap.set("n", "gf", vim.lsp.buf.formatting, { buffer = 0 })
  vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { buffer = 0 })
  vim.keymap.set("n", ",a", vim.lsp.buf.code_action, { buffer = 0 })
  vim.keymap.set("n", "en", vim.diagnostic.goto_next, { buffer = 0 })
  vim.keymap.set("n", "ep", vim.diagnostic.goto_prev, { buffer = 0 })
end
M.setup = function()
  return {
    loaded = true,
    requires = {
      "tool.treesitter",
      "data",
      "workspace",
      "cmd",
      "ui.popup",
      "data.code.snippet",
      "data.template",
      "ui.win",
      "lsp.workspace.diagnostic",
      "lsp.notebook",
      "lsp.reference",
      "lsp.workspace.folders",
      "lsp.workspace.config",
      "lsp.implementation",
      "lsp.workspace.edit",
      "lsp.workspace.symbol",
      "lsp.workspace.lens",
      "lsp.document.diagnostic",
      "lsp.document.highlight",
      "lsp.document.link",
      "lsp.command",
      "lsp.document.fold",
      "lsp.document.symbol",
      "lsp.document.color",
      "lsp.document.format",
      "lsp.document.lens",
      "lsp.document",
      "lsp.workspace.file",
      "lsp.document.semantic",
      "lsp.refactor",
      "lsp.document.action",
      "lsp.moniker",
      "lsp.document.hint",
      "lsp.document.hover",
      "lsp.completion.documentation",
      "lsp.completion.inline",
      "lsp.completion.signature",
      "lsp.workspace",
      "lsp.window",
      "lsp.completion",
    },
  }
end

---@class down.mod.lsp.Data
M.data = {
  experimentalCapabilities = {
    followLinks = true,
    statusNotification = true,
    codeLensFindReferences = true,
  },
  ---@type lsp.moniker
  moniker = Mod.get_mod("lsp.moniker"),
  ---@type lsp.command
  command = Mod.get_mod("lsp.command"),
  ---@type lsp.document.fold
  doc_fold = Mod.get_mod("lsp.document.fold"),
  ---@type lsp.notebook
  notebook = Mod.get_mod("lsp.notebook"),
  ---@type lsp.completion.signature.Data
  signature = Mod.get_mod("lsp.completion.signature"),
  ---@type lsp.completion.Data
  completion = Mod.get_mod("lsp.completion"),
  ---@type lsp.workspace.lens
  ws_lens = Mod.get_mod("lsp.workspace.lens"),
  ---@type lsp.document.lens
  doc_lens = Mod.get_mod("lsp.document.lens"),
  ---@type lsp.hint
  hint = Mod.get_mod("lsp.document.hint"),
  ---@type lsp.hover
  hover = Mod.get_mod("lsp.document.hover"),
  ---@type lsp.refactor
  refactor = Mod.get_mod("lsp.refactor"),
  ---@type lsp.workspace.file
  ws_file = Mod.get_mod("lsp.workspace.file"),
  ---@type lsp.workspace.edit
  ws_edit = Mod.get_mod("lsp.workspace.edit"),
  ---@type lsp.workspace.diagnostic
  ws_diagnostic = Mod.get_mod("lsp.workspace.diagnostic"),
  ---@type lsp.document.diagnostic
  doc_diagnostic = Mod.get_mod("lsp.document.diagnostic"),
  ---@type lsp.workspace.symbol
  ws_symbol = Mod.get_mod("lsp.workspace.symbol"),
  ---@type lsp.document.symbol
  doc_symbol = Mod.get_mod("lsp.document.symbol"),
  ---@type lsp.document.format
  doc_format = Mod.get_mod("lsp.document.format"),
  ---@type lsp.document.highlight
  doc_highlight = Mod.get_mod("lsp.document.highlight"),
  ---@type lsp.document.link
  doc_link = Mod.get_mod("lsp.document.link"),
  ---@type lsp.document.action.Data
  action = Mod.get_mod("lsp.document.action"),
  ---@type lsp.semantic
  semantic = Mod.get_mod("lsp.document.semantic"),
  ---@type lsp.workspace.config
  ws_config = Mod.get_mod("lsp.workspace.config"),
  ---@type lsp.workspace.folders
  ws_folders = Mod.get_mod("lsp.workspace.folders"),
}

---@class down.mod.lsp.Config
M.config = {
  diagnostic = { enable = true },
  format = { enable = true },
  actions = {
    enable = true,
  },
  lens = { enable = true },
  hint = { enable = true },
  moniker = { enable = true },
  semantic = {
    enable = true,
  },
  signature = mod.mod_config("lsp.completion.signature"),
  completion = {
    -- Enable or disable the completion provider
    enable = true,

    -- Try to complete categories provided by down SE
    categories = false,
  },
}

local workspace ---@type lsp.workspace.Data
local wcfg ---@type lsp.workspace.config
local doc ---@type lsp.document
local wsd ---@type lsp.workspace.diagnostic
local dod ---@type lsp.document.diagnostic
local fmt ---@type lsp.document.format
local len ---@type lsp.document.lens
local refactor ---@type lsp.refactor
local format ---@type lsp.document.format.Data
local ts ---@type treesitter
local cmp ---@type lsp.completion
local semantic ---@type lsp.document.semantic.Data
local sig ---@type lsp.completion.signature.Data
local act ---@type lsp.document.action
local hov ---@type lsp.document.hover
local hint ---@type lsp.document.hint

M.load = function()
  -- M.maps()
  M.required.cmd.add_commands_from_table({
    rename = {
      args = 1,
      name = "rename",
      condition = "markdown",
      subcommands = {
        workspace = {
          min_args = 0,
          max_args = 1,
          name = "rename.workspace",
        },
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
        type = {
          args = 0,
          name = "lsp.type",
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
    callback = M.data.start_lsp,
  })
end
M.data.ts = Mod.get_mod("tool.treesitter")
M.data.workspace_file = Mod.get_mod("lsp.workspace.file")
M.data.workspace = Mod.get_mod("workspace")
M.data.lsp_ws = Mod.get_mod("lsp.workspace")
M.data.lsp_doc = Mod.get_mod("lsp.document")
M.data.refactor = Mod.get_mod("lsp.refactor")
M.data.format = Mod.get_mod("lsp.document.format")
M.data.cmp = Mod.get_mod("lsp.completion")
M.data.semantic = Mod.get_mod("lsp.document.semantic")
M.data.sig = Mod.get_mod("lsp.completion.signature")
M.data.hov = Mod.get_mod("lsp.document.hover")
M.data.hint = Mod.get_mod("lsp.hint")
M.data.act = Mod.get_mod("lsp.document.actions")

---@type lsp._anonym1.serverInfo
M.data.serverInfo = {
  name = "down",
  version = "0.1.0-alpha.1",
}
---@return lsp.InitializeResult
M.data.initResult = function()
  -- ---@type lsp.InitializeResult
  -- local initRes = M.data.init_result()
  -- ---@type lsp.ServerCapabilities
  -- local cap = initRes.capabilities

  -- if not M.config.completion.enable then
  --   cap.completionProvider = nil
  -- elseif not M.config.format.enable then
  --   cap.documentFormattingProvider = nil
  -- elseif not M.config.hover.enable then
  --   cap.hoverProvider = nil
  -- elseif not M.config.lens.enable then
  --   cap.codeLensProvider = nil
  -- elseif not M.config.actions.enable then
  --   cap.codeActionProvider = nil
  -- else
  -- end
  return {
    serverInfo = M.data.serverInfo,
    capabilities = M.data.capabilities,
  }
end

M.data.handle = function(method, err, result, ctx)
  return function(err, result, ctx) end
end

---@type lsp.ServerCapabilities
M.data.capabilities = {
  workspace = {
    ---@type lsp.FileOperationOptions
    fileOperations = Mod.get_mod("lsp.workspace.file").opts,
    workspaceFolders = Mod.get_mod("lsp.workspace.folders").server.capabilities,
    -- workspaceSymbolProvider = Mod.get_mod("lsp.workspace.symbol").opts,
  },
  signatureHelpProvider = Mod.get_mod("lsp.completion.signature").opts,
  renameProvider = Mod.get_mod("lsp.refactor").rename.opts,
  referencesProvider = {
    workDoneProgress = true,
  },
  colorProvider = Mod.get_mod("lsp.document.color").opts,
  -- diagnosticProvider = Mod.get_mod("lsp.workspace.diagnostic").opts,
  -- workspaceSymbolProvider = Mod.get_mod("lsp.workspace.symbol").opts,
  -- documentOnTypeFormattingProvider = Mod.get_mod("lsp.document.format").opts,
  -- documentRangeFormattingProvider = Mod.get_mod("lsp.document.format").opts,
  -- foldingRangeProvider = Mod.get_mod("lsp.document.fold").opts,
  -- documentSymbolProvider = Mod.get_mod("lsp.document.symbol").opts,
  documentLinkProvider = Mod.get_mod("lsp.document.link").opts,
  documentColorProvider = Mod.get_mod("lsp.document.color").opts,
  hoverProvider = Mod.get_mod("lsp.document.hover").opts,
  inlineCompletionProvider = Mod.get_mod("lsp.completion.inline").opts,
  executeCommandProvider = Mod.get_mod("lsp.command").opts,
  inlayHintProvider = Mod.get_mod("lsp.document.hint").opts,
  -- monikerProvider = Mod.get_mod("lsp.moniker").opts,
  -- notebookDocumentSync = Mod.get_mod("lsp.notebook").sync.opts,
  -- semanticTokensProvider = Mod.get_mod("lsp.semantic").opts,
  -- inlineValueProvider = Mod.get_mod("lsp.completion.inline.value").opts,
  -- textDocument = Mod.get_mod("lsp.document").opts,
  -- textDocumentSync = Mod.get_mod("lsp.document").sync.opts,
  codeActionProvider = Mod.get_mod("lsp.document.action").opts,
  codeLensProvider = Mod.get_mod("lsp.workspace.lens").opts,
  -- documentFormattingProvider = Mod.get_mod("lsp.document.format").opts,
  -- documentHighlightProvider = Mod.get_mod("lsp.document.hl").opts,
  -- definitionProvider = true,
  -- declarationProvider = true,
  -- textDocument = {
  --   diagnostic = {
  --     markupMessageSupport = true,
  --   },
  -- },
  -- documentHighlightProvider = Mod.get_mod("lsp.document.highlight").opts,
  ---@type lsp.LSPAny
  -- experimental = true,
  -- callHierarchyProvider = false,
  -- implementationProvider = Mod.get_mod("lsp.implementation").opts,
  linkedEditingRangeProvider = true,
  -- positionEncoding = "utf-8",
  selectionRangeProvider = true,
  typeDefinitionProvider = true,
  typeHierarchyProvider = true,
  ---@type lsp.InlayHintOptions
  inlayHintsProvider = Mod.get_mod("lsp.document.hint").opts,
  completionProvider = Mod.get_mod("lsp.completion").opts,
}

---@type lsp.InitializeResult
M.data.initializeResult = {

  serverInfo = M.data.serverInfo,
  capabilities = M.data.capabilities,
}

---@class lsp.handlers
M.data.handlers = {

  ---@param params lsp.InitializeParams: params
  ---@param callback fun(err: any, result: lsp.InitializeResult):nil
  ---@param notify_reply_callback fun(err: any, result: lsp.InitializeResult):nil
  ["exit"] = function(params, callback, notify_reply_callback) end,
  ---@param params lsp.InitializeParams: params
  ---@param callback fun(err: any, result: lsp.InitializeResult):nil
  ---@param notify_reply_callback fun(err: any, result: lsp.InitializeResult):nil
  ["window/showMessageRequest"] = function(
      params,
      callback,
      notify_reply_callback
  )
  end,
  ---@param params lsp.InitializeParams: params
  ---@param callback fun(err: any, result: lsp.InitializeResult):nil
  ---@param notify_reply_callback fun(err: any, result: lsp.InitializeResult):nil
  ["workspace/diagnostic/refresh"] = function(
      params,
      callback,
      notify_reply_callback
  )
  end,
  ---@param params lsp.InitializeParams: params
  ---@param callback fun(err: any, result: lsp.InitializeResult):nil
  ---@param notify_reply_callback fun(err: any, result: lsp.InitializeResult):nil
  ["workspace/didChangeConfiguration"] = function(
      params,
      callback,
      notify_reply_callback
  )
  end,
  ---@param params lsp.InitializeParams: params
  ---@param callback fun(err: any, result: lsp.InitializeResult):nil
  ---@param notify_reply_callback fun(err: any, result: lsp.InitializeResult):nil
  ["workspace/didChangeWorkspaceFolders"] = function(
      params,
      callback,
      notify_reply_callback
  )
  end,
  ---@param params lsp.InitializeParams: params
  ---@param callback fun(err: any, result: lsp.InitializeResult):nil
  ---@param notify_reply_callback fun(err: any, result: lsp.InitializeResult):nil
  ["initialized"] = function(params, callback, notify_reply_callback) end,
  ---@param params lsp.InitializeParams: params
  ---@param callback fun(err: any, result: lsp.InitializeResult):nil
  ---@param notify_reply_callback fun(err: any, result: lsp.InitializeResult):nil
  ["shutdown"] = function(params, callback, notify_reply_callback) end,
  ["initialize"] = function(params, callback, notify_reply_callback)
    ---@type lsp.InitializeResult
    local ir = M.data.initializeResult
    if not M.config.completion.enable then
      ir.capabilities.completionProvider = nil
    elseif not M.config.actions.enable then
      ir.capabilities.codeActionProvider = nil
    elseif not M.config.lens.enable then
      ir.capabilities.codeLensProvider = nil
    end

    callback(nil, ir)
  end,

  ["textDocument/didOpen"] = function(err, result, ctx) end,
  -- ["textDocument/didChange"]
  ["codeLens/resolve"] = function() end,
  ["inlayHint/resolve"] = function() end,
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
  ["documentLink/resolve"] = function(
      params,
      callback,
      notify_reply_callback
  )
  end,
  ["textDocument/declaration"] = function(
      params,
      callback,
      notify_reply_callback
  )
  end,
  ["textDocument/hover"] = function(params, callback, _notify_reply_callback)
    -- local buf = vim.uri_to_bufnr(params.textDocument.uri)
    -- local b = require("down.util.buf").buf()
    -- M.required["ui.win"].win("hi", "bro", "down note today")

    -- vim.lsp.buf.hover()
    -- local node = M.data.ts.get_first_node_on_line(b, params.position.line)
    -- if not node then
    --   return
    -- end
    --
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
    -- callback()
  end,

  ["textDocument/formatting"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    format.format_document(params.textDocument.uri, callback)
  end,

  ["textDocument/inlineValue/refresh"] = function(
      params,
      callback,
      _notify_reply_callback
  )
    callback()
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
  ["textDocument/completion"] = function(
      params,
      callback,
      notify_reply_callback
  )
    if M.config.completion.categories then
      local cats = cmp.category_completion()
      if cats and not vim.tbl_isempty(cats) then
        callback(nil, cmp.category_completion())
        return
      end
    end
    cmp.handler(params, callback, notify_reply_callback)
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
    local wspath = M.required["workspace"].get_current_workspace()[2]
    local nt = vim.treesitter.get_captures_at_cursor(0)
    local linenr = params.position.line
    local ln = vim.api.nvim_buf_get_lines(0, linenr, linenr + 1, false)
    local name = vim.api.nvim_buf_get_name(0)
    local references = {}
    -- callback(nil, references)
    return references

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
  ["textDocument/semanticTokens/full"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["textDocument/semanticTokens/refresh"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["textDocument/semanticTokens/delta"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
  ["textDocument/semanticTokens/range"] = function(
      params,
      _callback,
      _notify_reply_callback
  )
  end,
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
  ["completionItem/resolve"] = function() end,
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

  ["window/workDoneProgress/cancel"] = function() end,
  ["window/workDoneProgress/create"] = function() end,

  ["window/showMessage"] = function() end,
  ["window/logMessage"] = function() end,
  ["window/showDocument"] = function() end,
  ["workspace/diagnostic/refresh"] = function() end,
  ["textDocument/documentColor"] = function() end,
  ["textDocument/colorPresentation"] = function() end,
  ["textDocument/definition"] = function() end,
  ["workspace/didCreateFiles"] = function() end,
  ["workspace/didDeleteFiles"] = function() end,
  ["workspace/willCreateFiles"] = function() end,
  ["workspace/willDeleteFiles"] = function() end,
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

M.data.start_lsp = function()
  ---@type lsp.InitializeResult
  -- local ir = M.data.init_result()
  -- vim.lsp.start({
  --   name = "down-lsp",
  --   cmd = { "down-lsp", "serve" },
  -- })
  vim.lsp.start(
  ---@type vim.lsp.ClientConfig
    {
      name = "down",
      -- workspace_folders = {
      -- Mod.get_mod("workspace").get_current_workspace()
      -- },
      -- capabilities = M.data.initResult().capabilities,
      capabilities = vim.lsp.protocol.resolve_capabilities(M.data.capabilities)
          or M.data.capabilities,
      handlers = M.data.handlers,
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
            if M.data.handlers[method] then
              M.data.handlers[method](params, callback, notify_reply_callback)
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

M.subscribed = {
  cmd = {
    ["lsp.start"] = true,
    ["lsp.restart"] = true,
    ["lsp.stop"] = true,
    ["lsp.info"] = true,
    ["lsp.workspace"] = true,
    ["lsp.workspace.folders"] = true,
    ["lsp.workspace.config"] = true,
    ["lsp.document.actions"] = true,
    ["lsp.references"] = true,
    ["lsp.implementation"] = true,
    ["lsp.document.semantic"] = true,
    ["lsp.type"] = true,
    ["lsp.declaration"] = true,
    ["lsp.definition"] = true,
    ["lsp.document.lens"] = true,
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

M.on = function(event)
  if M.data[event.split_type[2]] then
    M.data[event.split_type[2]](event)
  end
end

M.data["lsp.stop"] = function(e)
  vim.lsp.stop_client(vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
    name = "down",
  }))
end
M.data["lsp.rename.file"] = function(event)
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
M.data["lsp.hint"] = function(event)
  vim.ui.input({
    prompt = "lsp.hint",
  }, function(selected)
    if selected then
      vim.notify("sdkfsjf")
    end
  end)
end
M.data["lsp.document.format"] = function(event)
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
M.data["lsp.command"] = function(event)
  vim.ui.select({})
end
M.data["lsp.msg"] = function(e)
  vim.lsp.log.info(e.content[1])
end
M.data["lsp.semantic"] = function(event) end
M.data["lsp.implementation"] = function(event) end
M.data["lsp.declaration"] = function(event) end
M.data["lsp.type"] = function(event) end
M.data["lsp.definition"] = function(event) end
M.data["lsp.workspace"] = function(event)
  M.data["lsp.workspace.lens"] = function(event) end
  M.data["lsp.document.lens"] = function(event) end
  vim.lsp.util.open_floating_preview({}, "markdown", {})
end
M.data["lsp.workspace.config"] = function(event)
  vim.lsp.util.open_floating_preview({}, "markdown", {})
end
M.data["lsp.workspace.folders"] = function(event)
  vim.lsp.util.open_floating_preview({}, "markdown", {})
end
M.data["lsp.document.action"] = function(event)
  vim.lsp.util.open_floating_preview({}, "markdown", {})
end
M.data["rename.heading"] = function(event)
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

M.data.down_lsp = function()
  vim.lsp.start({
    name = "down-lsp",
    cmd = { "down-lsp" },
    -- workspace_folders = M.required.workspace.get_dirs(),
    -- root_dir = tostring(M.required.workspace.get_current_workspace()[2]),
  })
end

return M
