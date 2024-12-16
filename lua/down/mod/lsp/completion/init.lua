local util = require("down.mod.lsp.completion.util")
local down = require("down")
local mod, utils, log = down.mod, down.utils, down.log
local ls = vim.lsp
local Path = require("pathlib")

local M = mod.create("lsp.completion", { "inline", "documentation", "signature" })
local ts ---@type treesitter
local search

local dirutils, dirman, link_utils, treesitter

---@class lsp.completion.Config
M.config = {
  enable = true

}
---@class lsp.completion.Data
M.data = {
  ---@param param lsp.CompletionParams
  ---@param callback fun(_, lsp.CompletionList):nil
  ---@param _ fun():nil
  ---@return nil
  handle = function(param, callback, notify_reply_callback)
    local uri = param.textDocument.uri
    local cl = {
      {
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
        command = {
          command = "test",
          title = "test",
          arguments = {
            "test",
          },
        },
      },
    }
    callback(cl)
  end,
  ---@type lsp.CompletionList
  list = {
    isIncomplete = false,
    items = {
      {
        title = "hi",
        data = {
          title = "hi",
          command = "echo",
          arguments = { "hi" },
        },

        command = {
          title = "ls",
          command = "ls",
          arguments = { "-l" },
        },
        ---@type lsp.CompletionItemKind
        kind = 1,
        detail = "hi",
        documentation = "documentation",
        commitCharacters = { ".", "(", "[" },
        additionalTextEdits = {
          {
            newText = "newText",
            range = {
              start = { line = 1, character = 1 },
              ["end"] = { line = 1, character = 1 },
            },
          },
        },
        insertText = "insertText",
        insertTextFormat = 1,
        filterText = "filterText",
        insertTextMode = 2,
        label = "label",
      },
    },
  },
  ---@type lsp.CompletionContext
  context = {
    triggerKind = 1,
    triggerCharacter = "/",
  },
  ---@type lsp.CompletionOptions
  opts = {
    resolveProvider = true,
    workDoneProgress = true,
    completionItem = {
      labelDetailsSupport = true,
    },
    triggerCharacters = { "/", "." },
    allCommitCharacters = {
      ".",
      "(",
      "[",
    },
  },

  ---@type lsp.CompletionClientCapabilities
  capabilities = {
    contextSupport = true,
    completionItem = {
      resolveSupport = {
        properties = { "documentation", "detail", "additionalTextEdits" },
      },
      commitCharactersSupport = true,
      documentationFormat = { "markdown", "plaintext" },
      deprecatedSupport = true,
      insertReplaceSupport = true,
      labelDetailsSupport = true,
      insertTextModeSupport = {
        valueSet = { 1, 2 },
      },
      snippetSupport = true,
      preselectSupport = true,
      tagSupport = {
        valueSet = { 1 },
      },
    },
    insertTextMode = 2,
    dynamicRegistration = true,
    completionItemKind = {
      valueSet = {
        1,
        2,
        3,
      },
    },
    completionList = M.data.list,
  },

  -- Define completions
  completions = {
    { -- Create a new completion (for `@|tags`)
      -- Define the regex that should match in order to proceed
      regex = "^%s*@(%w*)",

      -- If regex can be matched, this item then gets verified via TreeSitter's AST
      node = M.data.normal_markdown,

      -- The actual elements to show if the above tests were true
      complete = {
        "table",
        "code",
        "image",
        "embed",
        "document",
      },

      -- Additional options to pass to the completion engine
      options = {
        type = "Tag",
        completion_start = "@",
      },

      -- We might have matched the top level item, but can we match it with any
      -- more precision? Descend down the rabbit hole and try to more accurately match
      -- the line.
      descend = {
        -- The cycle continues
        {
          regex = "document%.%w*",

          complete = {
            "meta",
          },

          options = {
            type = "Tag",
          },

          descend = {},
        },
        {
          -- Define a regex (gets appended to parent's regex)
          regex = "code%s+%w*",
          -- No node variable, we don't need that sort of check here

          complete = utils.get_language_list(true),

          -- Extra options
          options = {
            type = "Language",
          },

          -- Don't descend any further, we've narrowed down our match
          descend = {},
        },
        {
          regex = "export%s+%w*",

          complete = utils.get_language_list(true),

          options = {
            type = "Language",
          },

          descend = {},
        },
        {
          regex = "tangle%s+%w*",

          complete = {
            "<none>",
          },

          options = {
            type = "Property",
          },
        },
        {
          regex = "image%s+%w*",

          complete = {
            "jpeg",
            "png",
            "svg",
            "jfif",
            "exif",
          },

          options = {
            type = "Format",
          },
        },
        {
          regex = "embed%s+%w*",

          complete = {
            "video",
            "image",
          },

          options = {
            type = "Embed",
          },
        },
      },
    },
    { -- `#|tags`
      regex = "^%s*%#(%w*)",

      complete = {
        "comment",
        "ordered",
        "time.due",
        "time.start",
        "contexts",
        "waiting.for",
      },

      options = {
        type = "Tag",
      },

      descend = {},
    },
    { -- `@|end` tags
      regex = "^%s*@e?n?",
      node = function(_, previous)
        if not previous then
          return false
        end

        return previous:type() == "tag_parameters"
            or previous:type() == "tag_name"
      end,

      complete = {
        "end",
      },

      options = {
        type = "Directive",
        completion_start = "@",
      },
    },
    { -- Detached Modifier Extensions `- (`, `* (`, etc.
      regex = "^%s*[%-*$~^]+%s+%(",

      complete = {
        { "[ ] ", label = "[ ] (undone)" },
        { "[-] ", label = "[-] (pending)" },
        { "[x] ", label = "[x] (done)" },
        { "[_] ", label = "[_] (cancelled)" },
        { "[!] ", label = "[!] (important)" },
        { "[+] ", label = "[+] (recurring)" },
        { "[=] ", label = "[=] (on hold)" },
        { "[?] ", label = "[?] (uncertain)" },
      },

      options = {
        type = "TODO",
        pre = function()
          local sub =
              vim.api.nvim_get_current_line():gsub("^(%s*%-+%s+%(%s*)%)", "%1")

          if sub then
            vim.api.nvim_set_current_line(sub)
          end
        end,

        completion_start = "-",
      },
    },
    { -- links for file paths `{:|`
      regex = "^.*{:([^:}]*)",

      node = M.data.normal_markdown,

      complete = M.data.generate_file_links,

      options = {
        type = "File",
        completion_start = "{",
      },
    },
    { -- links that have a file path, suggest any heading from the file `{:...:#|}`
      regex = "^.*{:(.*):#[^}]*",

      complete = M.data.foreign_generic_links,

      node = M.data.normal_markdown,

      options = {
        type = "Reference",
        completion_start = "#",
      },
    },
    { -- links that have a file path, suggest direct headings from the file `{:...:*|}`
      regex = "^.*{:(.*):(%*+)[^}]*",

      complete = M.data.foreign_heading_links,

      node = M.data.normal_markdown,

      options = {
        type = "Reference",
        completion_start = "*",
      },
    },
    { -- # links to headings in the current file `{#|}`
      regex = "^.*{#[^}]*",

      -- complete = M.data.generate_local_heading_links,
      complete = M.data.local_link_targets,

      node = M.data.normal_markdown,

      options = {
        type = "Reference",
        completion_start = "#",
      },
    },
    { -- * links to headings in current file `{*|}`
      regex = "^(.*){(%*+)[^}]*",
      -- the first capture group is a nothing group so that match[2] is reliably the heading
      -- level or nil if there's no heading level.

      complete = M.data.local_heading_links,

      node = M.data.normal_markdown,

      options = {
        type = "Reference",
        completion_start = "*",
      },
    },
    { -- ^ footnote links in the current file `{^|}`
      regex = "^(.*){%^[^}]*",

      complete = M.data.local_footnote_links,

      node = M.data.normal_markdown,

      options = {
        type = "Reference",
        completion_start = "^",
      },
    },
    { -- ^ footnote links in another file `{:path:^|}`
      regex = "^(.*){:(.*):%^[^}]*",

      complete = M.data.foreign_footnote_links,

      node = M.data.normal_markdown,

      options = {
        type = "Reference",
        completion_start = "^",
      },
    },
    { -- foreign link name suggestions `{:path:target}[|]`
      regex = "^(.*){:([^:]*):[#$*%^]* ([^}]*)}%[",

      complete = M.data.foreign_link_names,

      node = M.data.normal_markdown,

      options = {
        type = "Reference",
        completion_start = "[",
      },
    },
    { -- local link name suggestions `{target}[|]` for `#`, `$`, `^`, `*` link targets
      regex = "^(.*){[#$*%^]+ ([^}]*)}%[",

      complete = M.data.local_link_names,

      node = M.data.normal_markdown,

      options = {
        type = "Reference",
        completion_start = "[",
      },
    },
    { -- complete anchor names that exist in the current buffer ` [|`
      regex = {
        "^(.*)[^}]%[",
        "^%[",
      },

      complete = M.data.anchor_suggestions,

      node = M.data.normal_markdown,

      options = {
        type = "Reference",
        completion_start = "[",
      },
    },
  },

  --- Parses the public completion table and attempts to find all valid matches
  ---@param context table #The context provided by the tool engine
  ---@param prev table? #The previous table of completions - used for descent
  ---@param saved string? #The saved regex in the form of a string, used to concatenate children nodes with parent nodes' regexes
  complete = function(context, prev, saved)
    -- If the save variable wasn't passed then set it to an empty string
    saved = saved or ""

    -- If we haven't defined any explicit table to read then read the public completions table
    local completions = prev or M.data.completions

    -- Loop through every completion
    for _, completion_data in ipairs(completions) do
      -- If the completion data has a regex variable
      if completion_data.regex then
        local regexes

        if type(completion_data.regex) == "string" then
          regexes = { completion_data.regex }
        elseif type(completion_data.regex) == "table" then
          ---@diagnostic disable-next-line: cast-local-type
          regexes = completion_data.regex
        else
          break
        end

        local match = {}
        -- Attempt to match the current line before the cursor with any of the regex
        -- expressions in the list, first one to succeed is used
        ---@diagnostic disable-next-line: param-type-mismatch
        for _, regex in ipairs(regexes) do
          match = { context.line:match(saved .. regex .. "$") }
          if not vim.tbl_isempty(match) then
            break
          end
        end

        -- If our match was successful
        if not vim.tbl_isempty(match) then
          -- Construct a variable that will be returned on a successful match
          local items = type(completion_data.complete) == "table"
              and completion_data.complete
              or completion_data.complete(context, prev, saved, match)
          local ret_completions =
          { items = items, options = completion_data.options or {} }

          -- Set the match variable for the tool M
          ret_completions.match = match

          -- If the completion data has a node variable then attempt to match the current node too!
          if completion_data.node then
            -- Grab the treesitter utilities
            local ts = treesitter.get_ts_utils()

            -- If the type of completion data we're dealing with is a string then attempt to parse it
            if type(completion_data.node) == "string" then
              -- Split the completion node string down every pipe character
              local split =
                  vim.split(completion_data.node --[[@as string]], "|")
              -- Check whether the first character of the string is an exclamation mark
              -- If this is present then it means we're looking for a node that *isn't* the one we specify
              local negate = split[1]:sub(0, 1) == "!"

              -- If we are negating then remove the leading exclamation mark so it doesn't interfere
              if negate then
                split[1] = split[1]:sub(2)
              end

              -- If we have a second split (i.e. in the string "tag_name|prev" this would be the "prev" string)
              if split[2] then
                -- Is our other value "prev"? If so, compare the current node in the syntax tree with the previous node
                if split[2] == "prev" then
                  -- Get the previous node
                  local current_node = ts.get_node_at_cursor()

                  if not current_node then
                    return { items = {}, options = {} }
                  end

                  local previous_node =
                      ts.get_previous_node(current_node, true, true)

                  -- If the previous node is nil
                  if not previous_node then
                    -- If we have specified a negation then that means our tag type doesn't match the previous tag's type,
                    -- which is good! That means we can return our completions
                    if negate then
                      return ret_completions
                    end

                    -- Otherwise continue on with the loop
                    goto continue
                  end

                  -- If we haven't negated and the previous node type is equal to the one we specified then return completions
                  if not negate and previous_node:type() == split[1] then
                    return ret_completions
                    -- Otherwise, if we want to negate and if the current node type is not equal to the one we specified
                    -- then also return completions - it means the match was successful
                  elseif negate and previous_node:type() ~= split[1] then
                    return ret_completions
                  else -- Otherwise just continue with the loop
                    goto continue
                  end
                  -- Else if our second split is equal to "next" then it's time to inspect the next node in the AST
                elseif split[2] == "next" then
                  -- Grab the next node
                  local current_node = ts.get_node_at_cursor()

                  if not current_node then
                    return { items = {}, options = {} }
                  end

                  local next_node = ts.get_next_node(current_node, true, true)

                  -- If it's nil
                  if not next_node then
                    -- If we want to negate then return completions - the comparison was unsuccessful, which is what we wanted
                    if negate then
                      return ret_completions
                    end

                    -- Or just continue
                    goto continue
                  end

                  -- If we are not negating and the node values match then return completions
                  if not negate and next_node:type() == split[1] then
                    return ret_completions
                    -- If we are negating and then values don't match then also return completions
                  elseif negate and next_node:type() ~= split[1] then
                    return ret_completions
                  else
                    -- Else keep look through the completion table to see whether we can find another match
                    goto continue
                  end
                end
              else -- If we haven't defined a split (no pipe was found) then compare the current node
                if ts.get_node_at_cursor():type() == split[1] then
                  -- If we're not negating then return completions
                  if not negate then
                    return ret_completions
                  else -- Else continue
                    goto continue
                  end
                end
              end
              -- If our completion data type is not a string but rather it is a function then
            elseif type(completion_data.node) == "function" then
              -- Grab all the necessary variables (current node, previous node, next node)
              local current_node = ts.get_node_at_cursor()

              -- The file is blank, return completions
              if not current_node then
                return ret_completions
              end

              local next_node = ts.get_next_node(current_node, true, true)
              local previous_node =
                  ts.get_previous_node(current_node, true, true)

              -- Execute the callback function with all of our parameters.
              -- If it returns true then that means the match was successful, and so return completions
              if
                  completion_data.node(current_node, previous_node, next_node, ts)
              then
                return ret_completions
              end

              -- If no completions were found, try looking whether we can descend any further down the syntax tree.
              -- Maybe we can find something extra there?
              if completion_data.descend then
                -- Recursively call complete() with the nested table
                local descent = M.data.complete(
                  context,
                  completion_data.descend,
                  saved .. completion_data.regex
                )

                -- If the returned completion items actually hold some data (i.e. a match was found) then return those matches
                if not vim.tbl_isempty(descent.items) then
                  return descent
                end
              end

              -- Else just don't bother and continue
              goto continue
            end
          end

          -- If none of the checks matched, then we can conclude that only the regex variable was defined,
          -- and since that was matched properly, we can return all completions.
          return ret_completions
          -- If the regex for the current line wasn't matched then attempt to descend further down,
          -- similarly to what we did earlier
        elseif completion_data.descend then
          -- Recursively call function with new parameters
          local descent = M.data.complete(
            context,
            completion_data.descend,
            saved .. completion_data.regex
          )

          -- If we had some completions from that function then return those completions
          if not vim.tbl_isempty(descent.items) then
            return descent
          end
        end
      end
      ::continue::
    end

    -- If absolutely no matches were found return empty data (no completions)
    return {
      items = {
        {
          label = "bye",
          documentation = "there",
        },
        {
          label = "hi",
          documentation = "there",
        },
      },
      options = {},
    }
  end,
}

M.config = {
  enable = true,
  engine = nil,

  -- The identifier for the down source.
  name = "[wd]",
}

M.setup = function()
  return {
    loaded = true,
    requires = {
      "workspace",
      "tool.treesitter",
      "edit.link",
    },
  }
end

---@class down.completion_engine
---@field create_source function

M.data = {
  ---@type down.completion_engine
  engine = nil,

  --- Get a list of all markdown files in current workspace. Returns { workspace_path, markdown_files }
  --- @return { [1]: PathlibPath, [2]: PathlibPath[]|nil }|nil
  get_markdown_files = function()
    local current_workspace = dirman.get_current_workspace()
    local markdown_files = dirman.get_markdown_files(current_workspace[1])
    return { current_workspace[2], markdown_files }
  end,

  --- Get the closing characters for a link completion
  --- @param context table
  --- @param colon boolean should there be a closing colon?
  --- @return string "", ":", or ":}" depending on what's needed
  get_closing_chars = function(context, colon)
    local offset = 1
    local closing_colon = ""
    if colon then
      closing_colon = ":"
      if
          string.sub(
            context.full_line,
            context.char + offset,
            context.char + offset
          ) == ":"
      then
        closing_colon = ""
        offset = 2
      end
    end

    local closing_brace = "}"
    if
        string.sub(
          context.full_line,
          context.char + offset,
          context.char + offset
        ) == "}"
    then
      closing_brace = ""
    end

    return closing_colon .. closing_brace
  end,

  --- query all the linkable items in a given buffer/file for a given link type
  ---@param source number | string | PathlibPath bufnr or file path
  ---@param link_type "generic" | "definition" | "footnote" | string
  get_linkables = function(source, link_type)
    local query_str = link_utils.get_link_target_query_string(link_type)
    local markdown_parser, iter_src = treesitter.get_ts_parser(source)
    if not markdown_parser then
      return {}
    end
    local markdown_tree = markdown_parser:parse()[1]
    local query = vim.treesitter.query.parse("markdown", query_str)
    local links = {}
    for id, node in query:iter_captures(markdown_tree:root(), iter_src, 0, -1) do
      local capture = query.captures[id]
      if capture == "title" then
        local original_title = treesitter.get_node_text(node, iter_src)
        if original_title then
          local title = original_title:gsub("\\", "")
          title = title:gsub("%s+", " ")
          title = title:gsub("^%s+", "")
          table.insert(links, {
            original_title = original_title,
            title = title,
            node = node,
          })
        end
      end
    end
    return links
  end,

  generate_file_links = function(context, _prev, _saved, _match)
    local res = {}
    local files = M.data.get_markdown_files()
    if not files or not files[2] then
      return {}
    end

    local closing_chars = M.data.get_closing_chars(context, true)
    for _, file in pairs(files[2]) do
      if not file:samefile(Path.new(vim.api.nvim_buf_get_name(0))) then
        local rel = file:relative_to(files[1], false)
        if rel and rel:len() > 0 then
          local link = "$/" .. rel:with_suffix(""):tostring() .. closing_chars
          table.insert(res, link)
        end
      end
    end

    return res
  end,

  --- Generate list of autocompletion suggestions for links
  --- @param context table
  --- @param source number | string | PathlibPath
  --- @param node_type string
  --- @return string[]
  suggestions = function(context, source, node_type)
    local leading_whitespace = " "
    if context.before_char == " " then
      leading_whitespace = ""
    end
    local links = M.data.get_linkables(source, node_type)
    local closing_chars = M.data.get_closing_chars(context, false)
    return vim
        .iter(links)
        :map(function(x)
          return leading_whitespace .. x.title .. closing_chars
        end)
        :totable()
  end,

  --- All the things that you can link to (`{#|}` completions)
  local_link_targets = function(context, _prev, _saved, _match)
    return M.data.suggestions(context, 0, "generic")
  end,

  local_heading_links = function(context, _prev, _saved, match)
    local heading_level = match[2] and #match[2]
    return M.data.suggestions(
      context,
      0,
      ("heading%d"):format(heading_level)
    )
  end,

  foreign_heading_links = function(context, _prev, _saved, match)
    local file = match[1]
    local heading_level = match[2] and #match[2]
    if file then
      file = dirutils.expand_pathlib(file)
      return M.data.suggestions(
        context,
        file,
        ("heading%d"):format(heading_level)
      )
    end
    return {}
  end,

  foreign_generic_links = function(context, _prev, _saved, match)
    local file = match[1]
    if file then
      file = dirutils.expand_pathlib(file)
      return M.data.suggestions(context, file, "generic")
    end
    return {}
  end,

  local_footnote_links = function(context, _prev, _saved, _match)
    return M.data.suggestions(context, 0, "footnote")
  end,

  foreign_footnote_links = function(context, _prev, _saved, match)
    local file = match[2]
    if match[2] then
      file = dirutils.expand_pathlib(file)
      return M.data.suggestions(context, file, "footnote")
    end
    return {}
  end,

  --- The node context for normal markdown (ie. not in a code block)
  normal_markdown = function(current, previous, _, _)
    -- If no previous node exists then try verifying the current node instead
    if not previous then
      return current
          and (current:type() ~= "translation_unit" or current:type() == "document")
          or false
    end

    -- If the previous node is not tag parameters or the tag name
    -- (i.e. we are not inside of a tag) then show auto completions
    return previous:type() ~= "tag_parameters" and previous:type() ~= "tag_name"
  end,
}

---Suggest common link names for the given link. Suggests:
--- - target name if the link point to a heading/fnoter/etc.
--- - metadata `title` field
--- - file description
---@return string[]
M.data.foreign_link_names = function(_context, _prev, _saved, match)
  local file, target = match[2], match[3]
  local path = dirutils.expand_pathlib(file)
  local meta = treesitter.get_document_metadata(path)
  local suggestions = {}
  if meta then
    table.insert(suggestions, meta.title)
    table.insert(suggestions, meta.description)
  end
  if target ~= "" then
    table.insert(suggestions, target)
  end
  return suggestions
end

---provide suggestions for anchors that are already defined in the document
---@return string[]
M.data.anchor_suggestions = function(_context, _prev, _saved, _match)
  local suggestions = {}

  local anchor_query_string = [[
        (anchor_definition
            (link_description
              text: (paragraph) @anchor_name ))
    ]]

  treesitter.execute_query(
    anchor_query_string,
    function(query, id, node, _metadata)
      local capture_name = query.captures[id]
      if capture_name == "anchor_name" then
        table.insert(suggestions, treesitter.get_node_text(node, 0))
      end
    end,
    0
  )
  return suggestions
end

--- suggest the link target name
---@return string[]
M.data.local_link_names = function(_context, _prev, _saved, match)
  local target = match[2]
  if target then
    target = target:gsub("^%s+", "")
    target = target:gsub("%s+$", "")
  end
  return { target }
end

---@class core.completion
M.data = {}

M.load = function()
  -- If we have not defined an engine then bail
  if not M.config.engine then
    log.error("No engine specified, aborting...")
    return
  end

  -- check if a custom completion M is provided
  if
      type(M.config.engine) == "table"
      and M.config.engine["mod_name"]
  then
    local completion_mod = M.config.engine == "nvim-compe"
        and Mod.load_mod("core.tools.nvim-compe")
    mod.load_mod_as_dependency("core.tools.nvim-compe", M.name, {})
    M.data.engine = mod.get_mod("core.tools.nvim-compe")
  elseif
      M.config.engine == "nvim-cmp"
      and mod.load_mod("core.tools.nvim-cmp")
  then
    mod.load_mod_as_dependency("core.tools.nvim-cmp", M.name, {})
    M.data.engine = mod.get_mod("core.tools.nvim-cmp")
  elseif
      M.config.engine == "coq_nvim"
      and mod.load_mod("core.tools.coq_nvim")
  then
    mod.load_mod_as_dependency("core.tools.coq_nvim", M.name, {})
    M.data.engine = mod.get_mod("core.tools.coq_nvim")
  else
    log.error(
      "Unable to load completion M -",
      M.config.engine,
      "is not a recognized engine."
    )
    return
  end

  dirutils = M.required["core.dirman.utils"]
  dirman = M.required["core.dirman"]
  link_utils = M.required["core.links"]
  treesitter = M.required["core.tools.treesitter"]

  -- Set a special function in the tool M to allow it to communicate with us
  M.data.engine.invoke_completion_engine = function(context) ---@diagnostic disable-line
    return M.data.complete(context) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
  end

  -- Create the tool engine's source
  M.data.engine.create_source({
    completions = M.config.completions,
  })
  -- ts = mod.required["tool.treesitter"]
end

M.data = {
  ---Query down SE for a list of categories, and format them into completion items
  make_category_suggestions = function()
    if not search then
      M.data.load_search()
    end

    local categories = search.get_categories()
    return vim
        .iter(categories)
        :map(function(c)
          return { label = c, kind = 12 } -- 12 == "Value"
        end)
        :totable()
  end,

  load_search = function()
    if mod.load_mod("search") then
      search = mod.get_mod("search")
    end
  end,
}

---@class lsp.completion : down.completion_engine
M.data = {
  create_source = function()
    -- these numbers come from: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItemKind
    M.data.completion_item_mapping = {
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

    function M.data.handler(request, callback, _)
      local abstracted_context = M.data.create_abstracted_context(request)

      local completion_cache =
          M.data.invoke_completion_engine(abstracted_context)

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
          kind = M.data.completion_item_mapping[completion_cache.options.type],
        }
      end

      callback(nil, completions)
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
    local markdown_inline_parser =
        vim.treesitter.get_string_parser(meta_source, "markdown_inline")
    local markdown_inline_tree = markdown_inline_parser:parse()[1]
    if not markdown_inline_tree then
      return {}
    end

    local meta_query = utils.ts_parse_query(
      "markdown_inline",
      [[
                (metadata
                  (pair
                    ((key) @key (#eq? @key "categories"))
                    (value) @value
                  ) @pair
                )
            ]]
    )

    for id, node in
    meta_query:iter_captures(markdown_inline_tree:root(), meta_source)
    do
      if meta_query.captures[id] == "pair" then
        local range = ts.get_node_range(node)
        local meta_range = ts.get_node_range(meta_node)
        range.row_start = range.row_start + meta_range.row_start
        range.row_end = range.row_end + meta_range.row_start

        local cursor = vim.api.nvim_win_get_cursor(0)
        if
            cursor[1] - 1 >= range.row_start and cursor[1] - 1 <= range.row_end
        then
          return M.data.make_category_suggestions()
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
    local full_line =
        vim.api.nvim_buf_get_lines(buf, line_num, line_num + 1, false)[1]

    local before_char = (request.context and request.context.triggerCharacter)
        or full_line:sub(col_num, col_num)

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

return M
