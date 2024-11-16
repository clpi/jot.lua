--[[
    file: Tangling
    title: From Code Blocks to Files
    description: The `base.code` module exports code blocks within a `.dorm` file straight to a file of your choice.
    summary: An Advanced Code Block Exporter.
    ---
The goal of this module is to allow users to spit out the contents of code blocks into
many different files. This is the primary component required for a literate configuration in dorm,
where the configuration is annotated and described in a `.dorm` document, and the actual code itself
is thrown out into a file that can then be normally consumed by e.g. an application.

The `code` module currently provides a single command:
- `:dorm code current-file` - performs all possible tangling operations on the current file

### Usage Tutorial
By base, *zero* code blocks are coded. You must provide where you'd like to code each code
block manually (global configuration will be discussed later). To do so, add a `#code
<output-file>` tag above the code block you'd wish to export, where <output-file> is relative to the
current file. For example:

```dorm
#code init.lua
@code lua
print("Hello World!")
@end
```
The above snippet will *only* code that single code block to the desired output file: `init.lua`.

#### Global Tangling for Single Files
Apart from tangling a single or a set of code blocks, you can declare a global output file in the document's metadata:
```dorm
@document.meta
code: ./init.lua
@end
```

This will code all `lua` code blocks to `init.lua`, *unless* the code block has an explicit `#code` tag associated with it, in which case
the `#code` tag takes precedence.

#### Global Tangling for Multiple Files
Apart from a single filepath, you can provide many in an array:
```dorm
@document.meta
code: [
    ./init.lua
    ./output.hs
]
@end
```

The above snippet tells the dorm tangling engine to code all `lua` code blocks to `./init.lua` and all `haskell` code blocks to `./output.hs`.
As always if any of the code blocks have a `#code` tag then that takes precedence.

#### Ignoring Code Blocks
Sometimes when tangling you may want to omit some code blocks. For this you may use the `#code.none` tag:
```dorm
#code.none
@code lua
print("I won't be coded!")
@end
```

#### Global Tangling with Extra Options
But wait, it doesn't stop there! You can supply a string to `code`, an array to `code`, but also an object!
It looks like this:
```dorm
@document.meta
code: {
    languages: {
        lua: ./output.lua
        haskell: my-haskell-file
    }
    delimiter: heading
    scope: all
}
@end
```

The `language` option determines which filetype should go into which file.
It's a simple language-filepath mapping, but it's especially useful when the output file's language type cannot be inferred from the name or shebang.
It is also possible to use the name `_` as a catchall to direct output for all files not otherwise listed.

The `delimiter` option determines how to delimit code blocks that export to the same file.
The following variations are allowed:

* `heading` -- Try to determine the filetype of the code block and insert any headings from the original document as a comment in the coded output.
  If filetype detection fails, `newline` will be used instead.
* `file-content` -- Try to determine the filetype of the codeblock and insert the dorm file content as a delimiter.
  If filetype detection fails, `none` will be used instead.
* `newline` -- Use an extra newline between coded blocks.
* `none` -- Do not add any delimiter. This implies that the code blocks are inserted into the code target as-is.

The `scope` option is discussed below.

#### Tangling Scopes
What you've seen so far is the coder operating in `all` mode. This means it captures all code blocks of a certain type unless that code block is tagged
with `#code.none`. There are two other types: `tagged` and `main`.

##### The `tagged` Scope
When in this mode, the coder will only code code blocks that have been `tagged` with a `#code` tag.
Note that you don't have to always provide a filetype, and that:
```dorm
#code
@code lua
@end
```
Will use the global output file for that language as defined in the metadata. I.e., if I do:
```dorm
@document.meta
code: {
    languages: {
        lua: ./output.lua
    }
    scope: tagged
}
@end

@code lua
print("Hello")
@end

#code
@code lua
print("Sup")
@end

#code other-file.lua
@code lua
print("Ayo")
@end
```
The first code block will not be touched, the second code block will be coded to `./output.lua` and the third code block will be coded to `other-file.lua`. You
can probably see that this system can get expressive pretty quick.

##### The `main` scope
This mode is the opposite of the `tagged` one in that it will only code code blocks to files that are defined in the document metadata. I.e. in this case:
```dorm
@document.meta
code: {
    languages: {
        lua: ./output.lua
    }
    scope: main
}
@end

@code lua
print("Hello")
@end

#code
@code lua
print("Sup")
@end

#code other-file.lua
@code lua
print("Ayo")
@end
```
The first code block will be coded to `./output.lua`, the second code block will also be coded to `./output.lua` and the third code block will be ignored.
--]]

local dorm = require("dorm")
local lib, mod, utils, log = dorm.lib, dorm.mod, dorm.utils, dorm.log

local module = mod.create("code")
local Path = require("pathlib")

module.setup = function()
    return {
        requires = {
            "treesitter",
            "cmd",
        },
    }
end

module.load = function()
    mod.await("cmd", function(cmd)
        cmd.add_commands_from_table({
            code = {
                args = 1,
                condition = "dorm",

                subcommands = {
                    ["current-file"] = {
                        args = 0,
                        name = "code.current-file",
                    },
                    -- directory = {
                    --     max_args = 1,
                    --     name = "code.directory",
                    -- }
                },
            },
        })
    end)

    if module.config.public.code_on_write then
        local augroup = vim.api.nvim_create_augroup("dorm_auto_code", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePost", {
            desc = "code the current file on write",
            pattern = "*.dorm",
            group = augroup,
            command = "dorm code current-file",
        })
    end
end

local function get_comment_string(language)
    local cur_buf = vim.api.nvim_get_current_buf()
    local tmp_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(tmp_buf)
    vim.bo.filetype = language
    local commentstring = vim.bo.commentstring
    vim.api.nvim_set_current_buf(cur_buf)
    vim.api.nvim_buf_delete(tmp_buf, { force = true })
    return commentstring
end

---@class base.code
module.public = {
    code = function(buffer)
        ---@type base.treesitter
        local treesitter = module.required["treesitter"]
        local parsed_document_metadata = treesitter.get_document_metadata(buffer) or {}
        local code_settings = parsed_document_metadata.code or {}
        local options = {
            languages = code_settings.languages or code_settings,
            scope = code_settings.scope or "all", -- "all" | "tagged" | "main"
            delimiter = code_settings.delimiter or "newline", -- "newline" | "heading" | "file-content" | "none"
        }

        ---@diagnostic disable-next-line
        if vim.tbl_islist(options.languages) then
            options.filenames_only = options.languages
            options.languages = {}
        elseif type(options.languages) == "string" then
            options.languages = { _ = options.languages }
        end

        local document_root = treesitter.get_document_root(buffer)
        local filename_to_languages = {}
        local codes = {
            -- filename = { block_content }
        }

        local query_str = lib.match(options.scope)({
            _ = [[
                (ranged_verbatim_tag
                    name: (tag_name) @_name
                    (#eq? @_name "code")
                    (tag_parameters
                       .
                       (tag_param) @_language)) @tag
            ]],
            tagged = [[
                (ranged_verbatim_tag
                    [(strong_carryover_set
                        (strong_carryover
                          name: (tag_name) @_strong_carryover_tag_name
                          (#eq? @_strong_carryover_tag_name "code")))
                     (weak_carryover_set
                        (weak_carryover
                          name: (tag_name) @_weak_carryover_tag_name
                          (#eq? @_weak_carryover_tag_name "code")))]
                  name: (tag_name) @_name
                  (#eq? @_name "code")
                  (tag_parameters
                    .
                    (tag_param) @_language)) @tag
            ]],
        })

        local query = utils.ts_parse_query("dorm", query_str)
        local previous_headings = {}
        local commentstrings = {}
        local file_content_line_start = {}
        local buf_name = vim.api.nvim_buf_get_name(buffer)

        for id, node in query:iter_captures(document_root, buffer, 0, -1) do
            local capture = query.captures[id]

            if capture == "tag" then
                local ok, parsed_tag = pcall(treesitter.get_tag_info, node, true)
                if not ok then
                    if module.config.public.indent_errors == "print" then
                        print(parsed_tag)
                    else
                        log.error(parsed_tag)
                    end
                    goto skip_tag
                end

                if parsed_tag then
                    local declared_filetype = parsed_tag.parameters[1]
                    local block_content = parsed_tag.content

                    if parsed_tag.parameters[1] == "dorm" then
                        for i, line in ipairs(block_content) do
                            -- remove escape char
                            local new_line, _ = line:gsub("\\(.?)", "%1")
                            block_content[i] = new_line or ""
                        end
                    end

                    local file_to_code_to
                    for _, attribute in ipairs(parsed_tag.attributes) do
                        if attribute.name == "code.none" then
                            goto skip_tag
                        elseif attribute.name == "code" and attribute.parameters[1] then
                            if options.scope == "main" then
                                goto skip_tag
                            end
                            file_to_code_to = table.concat(attribute.parameters)
                        end
                    end

                    -- determine code file target
                    if not file_to_code_to then
                        if declared_filetype and options.languages[declared_filetype] then
                            file_to_code_to = options.languages[declared_filetype]
                        else
                            if options.filenames_only then
                                for _, filename in ipairs(options.filenames_only) do
                                    if
                                        declared_filetype
                                        == vim.filetype.match({ filename = filename, contents = block_content }) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
                                    then
                                        file_to_code_to = filename
                                        break
                                    end
                                end
                            end
                            if not file_to_code_to then
                                file_to_code_to = options.languages["_"]
                            end
                            if declared_filetype then
                                options.languages[declared_filetype] = file_to_code_to
                            end
                        end
                    end
                    if not file_to_code_to then
                        goto skip_tag
                    end

                    local path_lib_path = Path.new(file_to_code_to)
                    if path_lib_path:is_relative() then
                        local buf_path = Path.new(buf_name)
                        file_to_code_to = tostring(buf_path:parent():child(file_to_code_to):resolve())
                    end

                    local delimiter_content
                    if options.delimiter == "heading" or options.delimiter == "file-content" then
                        local language
                        if filename_to_languages[file_to_code_to] then
                            language = filename_to_languages[file_to_code_to]
                        else
                            language = vim.filetype.match({ filename = file_to_code_to, contents = block_content }) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
                            if not language and declared_filetype then
                                language = vim.filetype.match({
                                    filename = "___." .. declared_filetype,
                                    contents = block_content,
                                })
                            end
                            filename_to_languages[file_to_code_to] = language
                        end

                        -- Get commentstring from vim scratch buffer
                        if language and not commentstrings[language] then
                            commentstrings[language] = get_comment_string(language)
                        end

                        -- TODO(vhyrro): Maybe issue warnings to the user when the target
                        -- commentstring is not found by Neovim?
                        -- if not language or commentstrings[language] == "" then
                        --     No action
                        -- end
                        if options.delimiter == "heading" then
                            -- get current heading
                            local heading_string
                            local heading = treesitter.find_parent(node, "heading%d+")
                            if heading and heading:named_child(1) then
                                local srow, scol, erow, ecol = heading:named_child(1):range()
                                heading_string = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})[1]
                            end

                            -- don't reuse the same header more than once
                            if heading_string and language and previous_headings[language] ~= heading then
                                previous_headings[language] = heading
                                if codes[file_to_code_to] then
                                    delimiter_content = { "", commentstrings[language]:format(heading_string), "" }
                                else
                                    delimiter_content = { commentstrings[language]:format(heading_string), "" }
                                end
                            elseif codes[file_to_code_to] then
                                delimiter_content = { "" }
                            end
                        elseif options.delimiter == "file-content" then
                            if not file_content_line_start[file_to_code_to] then
                                file_content_line_start[file_to_code_to] = 0
                            end
                            local start = file_content_line_start[file_to_code_to]
                            local srow, _, erow, _ = node:range()
                            delimiter_content = vim.api.nvim_buf_get_lines(buffer, start, srow, true)
                            file_content_line_start[file_to_code_to] = erow + 1
                            for idx, line in ipairs(delimiter_content) do
                                if line ~= "" then
                                    delimiter_content[idx] = commentstrings[language]:format(line)
                                end
                            end
                        end
                    elseif options.delimiter == "newline" then
                        if codes[file_to_code_to] then
                            delimiter_content = { "" }
                        end
                    end

                    if not codes[file_to_code_to] then
                        codes[file_to_code_to] = {}
                    end

                    if delimiter_content then
                        vim.list_extend(codes[file_to_code_to], delimiter_content)
                    end
                    vim.list_extend(codes[file_to_code_to], block_content)
                end
            end
            ::skip_tag::
        end

        if options.delimiter == "file-content" then
            for filename, start in pairs(file_content_line_start) do
                local language = filename_to_languages[filename]
                local delimiter_content = vim.api.nvim_buf_get_lines(buffer, start, -1, true)
                for idx, line in ipairs(delimiter_content) do
                    if line ~= "" then
                        delimiter_content[idx] = commentstrings[language]:format(line)
                    end
                end
                vim.list_extend(codes[filename], delimiter_content)
            end
        end

        return codes
    end,
}

module.config.public = {
    -- Notify when there is nothing to code (INFO) or when the content is empty (WARN).
    report_on_empty = true,

    -- code all code blocks in the current dorm file on file write.
    code_on_write = false,

    -- When text in a code block is less indented than the block itself, dorm will not code that
    -- block to a file. Instead it can either print or vim.notify error. By base, vim.notify is
    -- loud and is more likely to create a press enter message.
    -- - "notify" - Throw a normal looking error
    -- - "print" - print the error
    indent_errors = "notify",
}

module.on_event = function(event)
    if event.type == "cmd.events.base.code.current-file" then
        local codes = module.public.code(event.buffer)

        if not codes or vim.tbl_isempty(codes) then
            if module.config.public.report_on_empty then
                utils.notify("Nothing to code!", vim.log.levels.INFO)
            end
            return
        end

        local file_count = vim.tbl_count(codes)
        local coded_count = 0

        for file, content in pairs(codes) do
            -- resolve upward relative path like `../../`
            local relative_file, upward_count = string.gsub(file, "%.%.[\\/]", "")
            if upward_count > 0 then
                local base_dir = vim.fn.expand("%:p" .. string.rep(":h", upward_count + 1)) --[[@as string]]
                file = vim.fs.joinpath(base_dir, relative_file)
            end

            vim.loop.fs_open(vim.fn.expand(file) --[[@as string]], "w", 438, function(err, fd)
                assert(not err and fd, lib.lazy_string_concat("Failed to open file '", file, "' for tangling: ", err))

                local write_content = table.concat(content, "\n")
                if module.config.public.report_on_empty and write_content:len() == 0 then
                    vim.schedule(function()
                        utils.notify(string.format("coded content for %s is empty.", file), vim.log.levels.WARN)
                    end)
                end

                vim.loop.fs_write(fd, write_content, 0, function(werr)
                    assert(not werr, lib.lazy_string_concat("Failed to write to '", file, "' for tangling: ", werr))
                    coded_count = coded_count + 1
                    file_count = file_count - 1
                    if file_count == 0 then
                        vim.schedule(
                            lib.wrap(
                                utils.notify,
                                string.format(
                                    "Successfully coded %d file%s!",
                                    coded_count,
                                    coded_count == 1 and "" or "s"
                                )
                            )
                        )
                    end
                end)
            end)
        end
    end
end

module.events.subscribed = {
    ["cmd"] = {
        ["code.current-file"] = true,
        ["code.directory"] = true,
    },
}

return module
