---@brief lsp

local mod = require("word.mod")
local log = require('word.util.log')

local module = mod.create("lsp")

module.setup = function()
  return {
    success = true,
    requires = {
      "treesitter",
      "vault",
      "vault.utils",
      "cmd",
      "ui.text_popup",
      "lsp.refactor",
      "lsp.completion",
    },
  }
end

module.config.public = {
  completion_provider = {
    -- Enable or disable the completion provider
    enable = true,

    -- Try to complete categories provided by word SE
    categories = false,
  },
}

local vault ---@type vault
local refactor ---@type external.refactor
local ts ---@type treesitter
local lsp_completion ---@type external.lsp-completion

module.mod =function()
  module.required["cmd"].add_commands_from_table({
    lsp = {
      min_args = 0,
      max_args = 1,
      name = "lsp",
      condition = "word",
      subcommands = {
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
  ts = module.required["treesitter"]
  vault = module.required["vault"]
  refactor = module.required["external.refactor"]
  lsp_completion = module.required["external.lsp-completion"]

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "word",
    callb = module.private.start_lsp,
  })
end

module.private.handlers = {
  ["initialize"] = function(_params, callb, _notify_reply_callb)
    local initializeResult = {
      capabilities = {
        renameProvider = {
          prepareProvider = true,
        },
        vault = {
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
        name = "lsp",
        version = "0.0.1",
      },
    }

    if module.config.public.completion_provider.enable then
      initializeResult.capabilities.completionProvider = {
        triggerCharacters = { "@", "-", "(", " ", ".", ":", "#", "*", "^", "[" },
        resolveProvider = false,
        completionItem = {
          labelDetailsSupport = true,
        },
      }
    end

    callb(nil, initializeResult)
  end,

  ["textDocument/completion"] = function(p, c, _)
    -- Attempt to hijack completion for categories completions
    if module.config.public.completion_provider.categories then
      local cats = lsp_completion.category_completion()
      if cats and not vim.tbl_isempty(cats) then
        c(nil, lsp_completion.category_completion())
        return
      end
    end
    lsp_completion.completion_handler(p, c, _)
  end,

  ["textDocument/prepareRename"] = function(params, callb, _notify_reply_callb)
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
      callb(nil, { range = range, placeholder = heading_line })
    end
  end,

  ["textDocument/rename"] = function(params, _callb, _notify_reply_callb)
    refactor.rename_heading(params.position.line + 1, params.newName)
  end,

  ["vault/willRenameFiles"] = function(params, _callb, _notify_reply_callb)
    for _, files in ipairs(params.files) do
      local old = vim.uri_to_fname(files.oldUri)
      local new = vim.uri_to_fname(files.newUri)
      refactor.rename_file(old, new)
    end
  end,
}

module.private.start_lsp = function()
  -- setup and attach the shell LSP for file renaming
  -- https://github.com/jmbuhr/otter.nvim/pull/137/files
  vim.lsp.start({
    name = "lsp",
    -- capabilities = vim.lsp.protocol.make_client_capabilities(),
    cmd = function(_dispatchers)
      local members = {
        trace = "messages",
        request = function(method, params, callb, notify_reply_callb)
          if module.private.handlers[method] then
            module.private.handlers[method](params, callb, notify_reply_callb)
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
    root_dir = tostring(vault.get_current_vault()[2]),
  })
end

module.events.subscribed = {
  ["cmd"] = {
    ["lsp.rename.file"] = true,
    ["lsp.rename.heading"] = true,
  },
}

module.on_event = function(event)
  if module.private[event.split_type[2]] then
    module.private[event.split_type[2]](event)
  end
end

module.private["lsp.rename.file"] = function(event)
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

module.private["lsp.rename.heading"] = function(event)
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

return module
