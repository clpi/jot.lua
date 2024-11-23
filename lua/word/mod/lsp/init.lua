---@brief lsp

local mod = require("word.mod")
local log = require('word.util.log')

local M = mod.create("lsp", {
  "refactor",
  "signature",
  "lens",
  "format",
  "semantic",
  "action",
  "hint",
  "diagnostic",
  "completion",
})

M.setup = function()
  return {
    success = true,
    requires = {
      "integration.treesitter",
      "workspace",
      "cmd",
      "ui.popup",
      "lsp.refactor",
      "lsp.lens",
      "lsp.action",
      "lsp.hint",
      "lsp.format",
      "lsp.completion",
    },
  }
end

M.config.public = {
  completion = {
    -- Enable or disable the completion provider
    enable = true,

    -- Try to complete categories provided by word SE
    categories = false,
  },
}

local workspace ---@type workspace
local refactor ---@type lsp.refactor
local format ---@type lsp.format
local ts ---@type query
local lsp_completion ---@type lsp.completion

M.load = function()
  M.required["cmd"].add_commands_from_table({
    lsp = {
      min_args = 0,
      max_args = 1,
      name = "lsp",
      condition = "markdown",
      subcommands = {
        command = {
          args = 0,
          name = "lsp.command"
        },
        action = {
          args = 0,
          name = "lsp.action"
        },
        lens = {
          args = 0,
          name = "lsp.lens"
        },
        hint = {
          args = 0,
          name = "lsp.hint"
        },
        diagnostic = {
          args = 0,
          name = "lsp.diagnostic"
        },
        format = {
          name = "lsp.format"
        },
        refactor = {
          args = 1,
          name = "lsp.refactor"
        },
        rename = {
          args = 1,
          name = "lsp.rename",
          subcommands = {
            file = {
              min_args = 0,
              max_args = 1,
              name = "lsp.rename.file",
            },
            heading = {
              args = 0,
              name = "lsp.rename.heading",
            },
          },
        },
      },
    },
  })
  ts = M.required["integration.treesitter"]
  workspace = M.required["workspace"]
  refactor = M.required["lsp.refactor"]
  format = M.required["lsp.format"]
  lsp_completion = M.required["lsp.completion"]

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = M.private.start_lsp,
  })
end

M.private.handlers = {
  ["initialize"] = function(_params, callback, _notify_reply_callback)
    local initializeResult = {
      capabilities = {
        renameProvider = {
          prepareProvider = true,
        },
        workspace = {
          fileOperations = {
            willRename = {
              filters = {
                {
                  pattern = {
                    matches = "file",
                    glob = "**/*.md",
                  },
                },
              },
            },
            didRename = true,
          },
        },
      },
      serverInfo = {
        name = "wordls",
        version = "0.0.1",
      },
    }

    if M.config.public.completion.enable then
      initializeResult.capabilities.completionProvider = {
        triggerCharacters = { "@", "/", "|", "-", "(", " ", ".", ":", "#", "*", "^", "[" },
        resolveProvider = false,
        completionItem = {
          tagSupport = {
            valueSet = { 1 },
          },
          snippetSupport = true,
          preselectSupport = true,
          deprecatedSupport = true,
          commitCharactersSupport = true,
          labelDetailsSupport = true,
        },
      }
    end

    callback(nil, initializeResult)
  end,

  ["textDocument/hover"] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local node = ts.get_first_node_on_line(buf, params.position.line)
    if not node then
      return
    end

    local type = node:type()
    if type:match("^heading%d") then
      local heading_line = vim.api.nvim_buf_get_lines(buf, params.position.line, params.position.line + 1, true)[1]
      callback(nil, { contents = { { value = heading_line } } })
    end
  end,

  ["textDocument/formatting"] = function(params, callback, _notify_reply_callback)
    format.format_document(params.textDocument.uri, callback)
  end,

  ["textDocument/inlayHint"] = function(params, _callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local hints = {}
    for _, node in ipairs(ts.get_nodes(buf)) do
      if node:type() == "heading1" then
        table.insert(hints, {
          range = {
            start = { line = node:range().start.line, character = 0 },
            ["end"] = { line = node:range().start.line, character = 0 },
          },
          kind = "Other",
          label = "Rename Heading",
        })
      end
    end
    _callback(nil, hints)
  end,
  ['textDocument/documentSymbol'] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local symbols = {}
    for _, node in ipairs(ts.get_nodes(buf)) do
      if node:type() == "heading1" then
        table.insert(symbols, {
          name = vim.api.nvim_buf_get_lines(buf, node:range().start.line, node:range().start.line + 1, true)[1],
          kind = 1,
          range = {
            start = { line = node:range().start.line, character = 0 },
            ["end"] = { line = node:range().start.line, character = 0 },
          },
          selectionRange = {
            start = { line = node:range().start.line, character = 0 },
            ["end"] = { line = node:range().start.line, character = 0 },
          },
        })
      end
    end
    callback(nil, symbols)
  end,




  ['textDocument/linkedEditingRange'] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local node = ts.get_first_node_on_line(buf, params.position.line)
    if not node then
      return
    end

    local type = node:type()
    if type:match("^heading%d") then
      local range = {
        start = { line = params.position.line, character = 0 },
        ["end"] = { line = params.position.line + 1, character = 0 },
      }
      callback(nil, range)
    end
  end,
  ['textDocument/foldingRange'] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local ranges = {}
    for _, node in ipairs(ts.get_nodes(buf)) do
      if node:type() == "heading1" then
        table.insert(ranges, {
          startLine = node:range().start.line,
          startCharacter = 0,
          endLine = node:range().start.line,
          endCharacter = 0,
          kind = "region",
        })
      end
    end
    callback(nil, ranges)
  end,
  ["textDocument/rename"] = function(params, _callback, _notify_reply_callback)
    refactor.rename_heading(params.position.line + 1, params.newName)
  end,

  ["textDocument/completion"] = function(p, c, _)
    -- Attempt to hijack completion for categories completions
    if M.config.public.completion.categories then
      local cats = lsp_completion.category_completion()
      if cats and not vim.tbl_isempty(cats) then
        c(nil, lsp_completion.category_completion())
        return
      end
    end
    lsp_completion.completion_handler(p, c, _)
  end,

  ["textDocument/prepareRename"] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local node = ts.get_first_node_on_line(buf, params.position.line)
    if not node then
      return
    end

    local type = node:type()
    if type:match("^heading%d") then
      -- let the rename go through
      local range = {
        start = { line = params.position.line, character = 0 },
        ["end"] = { line = params.position.line + 1, character = 0 },
      }
      local heading_line =
          vim.api.nvim_buf_get_lines(buf, params.position.line, params.position.line + 1, true)[1]
      callback(nil, { range = range, placeholder = heading_line })
    end
  end,


  ['textDocument/codeLens'] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local codeLens = {}
    for _, node in ipairs(ts.get_nodes(buf)) do
      if node:type() == "heading1" then
        table.insert(codeLens, {
          range = {
            start = { line = node:range().start.line, character = 0 },
            ["end"] = { line = node:range().start.line, character = 0 },
          },
          command = {
            title = "Rename Heading",
            command = "lsp.rename.heading",
            arguments = {
              line_content = vim.api.nvim_buf_get_lines(buf, node:range().start.line, node:range().start.line + 1, true)
                  [1],
              cursor_position = { node:range().start.line, 0 },
            },
          },
        })
      end
    end
    callback(nil, codeLens)
  end,

  ['textDocument/references'] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local references = {}
    for _, node in ipairs(ts.get_nodes(buf)) do
      if node:type() == "heading1" then
        table.insert(references, {
          uri = vim.uri_from_bufnr(buf),
          range = {
            start = { line = node:range().start.line, character = 0 },
            ["end"] = { line = node:range().start.line, character = 0 },
          },
        })
      end
    end
    callback(nil, references)
  end,

  ["workspace/inlayHint/refresh"] = function(params, _callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.uri)
    local hints = {}
    for _, node in ipairs(ts.get_nodes(buf)) do
      if node:type() == "heading1" then
        table.insert(hints, {
          range = {
            start = { line = node:range().start.line, character = 0 },
            ["end"] = { line = node:range().start.line, character = 0 },
          },
          kind = "Other",
          label = "Rename Heading",
        })
      end
    end
    _callback(nil, hints)
  end,

  ["typeHierarchy/subtypes"] = function(params, _callback, _notify_reply_callback)
  end,
  ["typeHierarchy/supertypes"] = function(params, _callback, _notify_reply_callback)
  end,
  ["textDocument/typeDefinition"] = function(params, _callback, _notify_reply_callback)
  end,
  ["workspace/configuration"] = function(params, _callback, _notify_reply_callback)
  end,
  ["workspace/executeCommand"] = function(params, _callback, _notify_reply_callback)
  end,
  ["workspace/workspaceFolders"] = function(params, _callback, _notify_reply_callback)
  end,
  ["workspace/symbol"] = function(params, _callback, _notify_reply_callback)
  end,
  ["textDocument/semanticTokens/full"] = function(params, _callback, _notify_reply_callback)
  end,
  ["textDocument/semanticTokens/full/delta"] = function(params, _callback, _notify_reply_callback)
  end,
  ["textDocument/publishDiagnostics"] = function(params, _callback, _notify_reply_callback)
  end,
  ["textDocument/prepareTypeHierarchy"] = function(params, _callback, _notify_reply_callback)
  end,
  ["textDocument/implementation"] = function(params, _callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local node = ts.get_first_node_on_line(buf, params.position.line)
    if not node then
      return
    end

    local type = node:type()
    if type:match("^heading%d") then
      local range = {
        start = { line = params.position.line, character = 0 },
        ["end"] = { line = params.position.line + 1, character = 0 },
      }
      local heading_line =
          vim.api.nvim_buf_get_lines(buf, params.position.line, params.position.line + 1, true)[1]
      callback(nil, { range = range, placeholder = heading_line })
    end
  end,
  ["textDocument/rename"] = function(params, _callback, _notify_reply_callback)
    refactor.rename_heading(params.position.line + 1, params.newName)
  end,

  ['textDocument/codeLens'] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local codeLens = {}
    for _, node in ipairs(ts.get_nodes(buf)) do
      if node:type() == "heading1" then
        table.insert(codeLens, {
          range = {
            start = { line = node:range().start.line, character = 0 },
            ["end"] = { line = node:range().start.line, character = 0 },
          },
          command = {
            title = "Rename Heading",
            command = "lsp.rename.heading",
            arguments = {
              line_content = vim.api.nvim_buf_get_lines(buf, node:range().start.line, node:range().start.line + 1, true)
                  [1],
              cursor_position = { node:range().start.line, 0 },
            },
          },
        })
      end
    end
    callback(nil, codeLens)
  end,

  ['textDocument/codeAction'] = function(params, callback, _notify_reply_callback)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local actions = {}
    for _, node in ipairs(ts.get_nodes(buf)) do
      if node:type() == "heading1" then
        table.insert(actions, {
          title = "Rename Heading",
          command = {
            title = "Rename Heading",
            command = "lsp.rename.heading",
            arguments = {
              line_content = vim.api.nvim_buf_get_lines(buf, node:range().start.line, node:range().start.line + 1, true)
                  [1],
              cursor_position = { node:range().start.line, 0 },
            },
          },
        })
      end
    end
    callback(nil, actions)
  end,


  ["workspace/willRenameFiles"] = function(params, _callback, _notify_reply_callback)
    for _, files in ipairs(params.files) do
      local old = vim.uri_to_fname(files.oldUri)
      local new = vim.uri_to_fname(files.newUri)
      refactor.rename_file(old, new)
    end
  end,
}

M.private.start_lsp = function()
  -- setup and attach the shell LSP for file renaming
  -- https://github.com/jmbuhr/otter.nvim/pull/137/files
  vim.lsp.start({
    name = "wordls",
    handlers = M.private.handlers,
    cmd = function(_dispatchers)
      local members = {
        trace = "messages",
        request = function(method, params, callback, notify_reply_callback)
          if M.private.handlers[method] then
            M.private.handlers[method](params, callback, notify_reply_callback)
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
    filetypes = { "markdown" },
    root_dir = tostring(workspace.get_current_workspace()[2]),
  })
end

M.events.subscribed = {
  cmd = {
    ["lsp.actions"] = true,
    ["lsp.references"] = true,
    ["lsp.implementations"] = true,
    ["lsp.typedefinition"] = true,
    ["lsp.lens"] = true,
    ["lsp.commands"] = true,
    ["lsp.hint"] = true,
    ["lsp.diagnostic"] = true,
    ["lsp.format"] = true,
    ["lsp.refactor"] = true,
    ["lsp.rename"] = true,
    ["lsp.rename.file"] = true,
    ["lsp.rename.heading"] = true,
  },
}

M.on_event = function(event)
  if M.private[event.split_type[2]] then
    M.private[event.split_type[2]](event)
  end
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

M.private["lsp.rename.heading"] = function(event)
  local line_number = event.cursor_position[1]
  local prefix = string.match(event.line_content, "^%s*%*+ ")
  if not prefix then -- this is a very very simple check that we're on a heading line. We use TS in the actual rename_heading function
    return
  end

  vim.schedule(function()
    vim.ui.input({ prompt = "New Heading: ", default = event.line_content }, function(text)
      if not text then
        return
      end

      refactor.rename_heading(line_number, text)
    end)
  end)
end

return M
