--[[
    file: LSP-Completion
    title: Completions without a completion plugin
    summary: Provide an LSP Completion source for Neorg
    internal: true
    ---
This mod works with the [`completion`](@completion) mod to attempt to provide
intelligent completions.

After setting up `completion` with the `engine` set to `lsp-completion`. Then you can get
neorg completions the same way you get completions from other language servers.
--]]

local word = require("word")
local mod, utils = word.mod, word.utils

local mod = mod.create("lsp.completion")
local ts ---@type treesitter
local search

M.setup = function()
  return {
    success = true,
    requires = {
      "treesitter",
    },
  }
end

M.mod =function()
  ts = mod.required["treesitter"]
end

M.private = {
  ---Query neorg SE for a list of categories, and format them into completion items
  make_category_suggestions = function()
    if not search then
      mod.private.mod_search()
    end

    local categories = search.get_categories()
    return vim.iter(categories)
        :map(function(c)
          return { label = c, kind = 12 } -- 12 == "Value"
        end)
        :totable()
  end,

  load_search = function()
    if mod.mod_mod("search") then
      search = mod.get_mod("search")
    end
  end,
}

---@class lsp.completion : neorg.completion_engine
M.public = {
  create_source = function()
    -- these numbers come from: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItemKind
    mod.private.completion_item_mapping = {
      Directive = 14,
      Tag = 14,
      Language = 10,
      TODO = 23,
      Property = 10,
      Format = 10,
      Embed = 10,
      Reference = 18,
      File = 17,
    }

    function mod.public.completion_handler(request, callb, _)
      local abstracted_context = mod.public.create_abstracted_context(request)

      local completion_cache = mod.public.invoke_completion_engine(abstracted_context)

      if completion_cache.options.pre then
        completion_cache.options.pre(abstracted_context)
      end

      local completions = vim.deepcopy(completion_cache.items)

      for index, element in ipairs(completions) do
        local insert_text = nil
        local label = element
        if type(element) == "table" then
          insert_text = element[1]
          label = element.label
        end
        completions[index] = {
          label = label,
          insertText = insert_text,
          kind = mod.private.completion_item_mapping[completion_cache.options.type],
        }
      end

      callb(nil, completions)
    end
  end,

  ---Provide categories as a completion source,
  category_completion = function()
    local markdown_query = utils.ts_parse_query(
      "markdown",
      [[
                (document
                  (ranged_verbatim_tag
                    ((tag_name) @tag_name (#eq? @tag_name "document.meta"))
                    (ranged_verbatim_tag_content) @tag_content
                  )
                )
            ]]
    )

    local markdown_parser, iter_src = ts.get_ts_parser(0)
    if not markdown_parser then
      return {}
    end
    local markdown_tree = markdown_parser:parse()[1]
    if not markdown_tree then
      return {}
    end

    local meta_node
    for id, node in markdown_query:iter_captures(markdown_tree:root(), iter_src) do
      if markdown_query.captures[id] == "tag_content" then
        meta_node = node
      end
    end

    if not meta_node then
      return {}
    end

    local meta_source = ts.get_node_text(meta_node, iter_src)
    local markdown_meta_parser = vim.treesitter.get_string_parser(meta_source, "markdown_meta")
    local markdown_meta_tree = markdown_meta_parser:parse()[1]
    if not markdown_meta_tree then
      return {}
    end

    local meta_query = utils.ts_parse_query(
      "markdown_meta",
      [[
                (metadata
                  (pair
                    ((key) @key (#eq? @key "categories"))
                    (value) @value
                  ) @pair
                )
            ]]
    )

    for id, node in meta_query:iter_captures(markdown_meta_tree:root(), meta_source) do
      if meta_query.captures[id] == "pair" then
        local range = ts.get_node_range(node)
        local meta_range = ts.get_node_range(meta_node)
        range.row_start = range.row_start + meta_range.row_start
        range.row_end = range.row_end + meta_range.row_start

        local cursor = vim.api.nvim_win_get_cursor(0)
        if cursor[1] - 1 >= range.row_start and cursor[1] - 1 <= range.row_end then
          return mod.private.make_category_suggestions()
        end
      end
    end
  end,

  -- {
  --   before_char = "@",
  --   buffer = 12,
  --   char = 4,
  --   column = 5,
  --   full_line = "   @",
  --   line = "   @",
  --   line_number = 32,
  --   previous_context = {
  --     column = 4,
  --     line = "   ",
  --     start_offset = 5
  --   },
  --   start_offset = 5
  -- }
  -- textDocument/completion
  -- {
  --   context = {
  --     triggerCharacter = "@",
  --     triggerKind = 2
  --   },
  --   position = {
  --     character = 4,
  --     line = 32
  --   },
  --   textDocument = {
  --     uri = "file:///home/benlubas/notes/test1.markdown"
  --   }
  -- }

  create_abstracted_context = function(request)
    local line_num = request.position.line
    local col_num = request.position.character
    local buf = vim.uri_to_bufnr(request.textDocument.uri)
    local full_line = vim.api.nvim_buf_get_lines(buf, line_num, line_num + 1, false)[1]

    local before_char = (request.context and request.context.triggerCharacter) or full_line:sub(col_num, col_num)

    return {
      start_offset = col_num + 1,
      char = col_num,
      before_char = before_char,
      line_number = request.position.line,
      column = col_num + 1,
      buffer = buf,
      line = full_line:sub(1, col_num),
      -- this is never used anywhere, so it's probably safe to ignore
      -- previous_context = {
      --     line = request.context.prev_context.cursor_before_line,
      --     column = request.context.prev_context.cursor.col,
      --     start_offset = request.offset,
      -- },
      full_line = full_line,
    }
  end,

  invoke_completion_engine = function(context)
    error("`invoke_completion_engine` must be set from outside.")
    assert(context)
    return {}
  end,
}

return mod
