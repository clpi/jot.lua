--[[
    file: User-keys
    title: The Language of word
    description: `base.keys` manages mappings for operations on or in `.word` files.
    summary: init for managing keybindings with word mode support.
    ---
The `base.keys` init configures an out-of-the-box Neovim experience by providing a base
set of keys.

To disable base keys, see the next section. To remap the existing keys, see [here](https://github.com/nvim-word/word/wiki/User-keys#remapping-keys).

To find common problems, consult the [FAQ](https://github.com/nvim-word/word/wiki/User-keys#faq).

### Disabling base keys

By base when you load the `base.keys` init all keys will be enabled. If you would like to change this, be sure to set `base_keys` to `false`:
```lua
["keys"] = {
    config = {
        base_keys = false,
    },
}
```

### Remapping Keys

To understand how to effectively remap keys, one must understand how keys are set.
word binds actions to various `<Plug>` mappings that look like so: `<Plug>(word...`.

To remap a key, simply map an action somewhere in your configuration:

```lua
vim.keymap.set("n", "my-key-here", "<Plug>(word.pivot.list.toggle)", {})
```

word will recognize that the key has been bound by you and not bind its own key.

#### Binding Keys for word Files Only

This approach has a downside - all of word's keys are set on a per-buffer basis
so that keys don't "overflow" into buffers you don't want them active in.

When you map a key using `vim.keymap.set`, you set a global key which is always active, even in non-word
files. There are two ways to combat this:
- Create a file under `<your-configuration>/ftplugin/word.lua`:
  ```lua
  vim.keymap.set("n", "my-key-here", "<Plug>(word.pivot.list.toggle)", { buffer = true })
  ```
- Create an autocommand using `vim.api.nvim_create_autocmd`:
  ```lua
  vim.api.nvim_create_autocmd("Filetype", {
      pattern = "word",
      callback = function()
          vim.keymap.set("n", "my-key-here", "<Plug>(word.pivot.list.toggle)", { buffer = true })
      end,
  })
  ```

Notice that in both situations a `{ buffer = true }` was supplied to the function.
This way, your remapped keys will never interfere with other files.

### Discovering Keys

A comprehensive list of all keys can be found on [this page!](https://github.com/nvim-word/word/wiki/base-keys)

## FAQ

### Some (or all) keys do not work

word refuses to bind keys when it knows they'll interfere with your configuration.
Run `:checkhealth word` to see a full list of what keys word has considered "conflicted"
or "rebound".

If you see that *all* of your keys are in conflict, you're likely using a plugin that is mapping to your
local leader key. This is a known issue with older versions of `which-key.nvim`. Since version `3.0` of which-key the issue has been fixed - we
recommend updating to the latest version to resolve the errors.

--]]

local word = require("word")
local mod = word.mod

local init = mod.create("keys")

local bound_keys = {}

init.load = function()
    if init.config.public.base_keys then
        local preset = init.private.presets[init.config.public.preset]
        assert(preset, string.format("keybind preset `%s` does not exist!", init.config.public.preset))

        init.public.set_keys_for(false, preset.all)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "word",
            callback = function(ev)
                init.public.set_keys_for(ev.buf, preset.word)
            end,
        })
    end
end

init.config.public = {
    -- Whether to enable the base keys.
    base_keys = true,

    -- Which keybind preset to use.
    -- Currently allows only a single value: `"word"`.
    preset = "word",
}

---@class base.keys
init.public = {
    --- Adds a set of base keys for word to bind.
    --- Should be used exclusively by external mod wanting to provide their own base keys.
    ---@param name string The name of the preset to extend (allows for providing base keys for various presets)
    ---@param preset word.keys.preset The preset data itself.
    extend_preset = function(name, preset)
        local original_preset = assert(init.private.presets[name], "provided preset doesn't exist!")

        local function extend(a, b)
            for k, v in pairs(b) do
                if type(v) == "table" then
                    if vim.islist(v) then
                        vim.list_extend(a[k], v)
                    else
                        extend(a[k], v)
                    end
                end

                a[k] = v
            end
        end

        extend(original_preset, preset)
        init.public.bind_word_keys(vim.api.nvim_get_current_buf())
    end,

    ---@param buffer number|boolean
    ---@param preset_subdata table
    set_keys_for = function(buffer, preset_subdata)
        for mode, keys in pairs(preset_subdata) do
            bound_keys[mode] = bound_keys[mode] or {}

            for _, keybind in ipairs(keys) do
                if
                    vim.fn.hasmapto(keybind[2], mode, false) == 0
                    and vim.fn.mapcheck(keybind[1], mode, false):len() == 0
                then
                    local opts = vim.tbl_deep_extend("force", { buffer = buffer }, keybind.opts or {})
                    vim.keymap.set(mode, keybind[1], keybind[2], opts)

                    bound_keys[mode][keybind[1]] = true
                end
            end
        end
    end,

    --- Checks the health of keys. Returns all remaps and all conflicts in a table.
    ---@return { preset_exists: boolean, remaps: table<string, string>, conflicts: table<string, string> }
    health = function()
        local preset = init.private.presets[init.config.public.preset]

        if not preset then
            return {
                preset_exists = false,
            }
        end

        local remaps = {}
        local conflicts = {}

        local function check_keys_for(data)
            for mode, keys in pairs(data) do
                for _, keybind in ipairs(keys) do
                    if not bound_keys[mode] or not bound_keys[mode][keybind[1]] then
                        if vim.fn.hasmapto(keybind[2], mode, false) ~= 0 then
                            remaps[keybind[1]] = keybind[2]
                        elseif vim.fn.mapcheck(keybind[1], mode, false):len() ~= 0 then
                            conflicts[keybind[1]] = keybind[2]
                        end
                    end
                end
            end
        end

        check_keys_for(preset.all)
        check_keys_for(preset.word)

        return {
            preset_exists = true,
            remaps = remaps,
            conflicts = conflicts,
        }
    end,
}

init.private = {

    -- TODO: Move these to the "vim" preset
    -- { "gd", "<Plug>(word.esupports.hop.hop-link)", opts = { desc = "[word] Jump to Link" } },
    -- { "gf", "<Plug>(word.esupports.hop.hop-link)", opts = { desc = "[word] Jump to Link" } },
    -- { "gF", "<Plug>(word.esupports.hop.hop-link)", opts = { desc = "[word] Jump to Link" } },
    presets = {
        ---@class word.keys.preset
        word = {
            all = {
                n = {
                    -- Create a new `.word` file to take notes in
                    -- ^New Note
                    {
                        "<LocalLeader>nn",
                        "<Plug>(word.workspace.new-note)",
                        opts = { desc = "[word] Create New Note" },
                    },
                },
            },
            word = {
                n = {
                    -- Mark the task under the cursor as "undone"
                    -- ^mark Task as Undone
                    {
                        "<LocalLeader>tu",
                        "<Plug>(word.qol.todo-items.todo.task-undone)",
                        opts = { desc = "[word] Mark as Undone" },
                    },

                    -- Mark the task under the cursor as "pending"
                    -- ^mark Task as Pending
                    {
                        "<LocalLeader>tp",
                        "<Plug>(word.qol.todo-items.todo.task-pending)",
                        opts = { desc = "[word] Mark as Pending" },
                    },

                    -- Mark the task under the cursor as "done"
                    -- ^mark Task as Done
                    {
                        "<LocalLeader>td",
                        "<Plug>(word.qol.todo-items.todo.task-done)",
                        opts = { desc = "[word] Mark as Done" },
                    },

                    -- Mark the task under the cursor as "on-hold"
                    -- ^mark Task as on Hold
                    {
                        "<LocalLeader>th",
                        "<Plug>(word.qol.todo-items.todo.task-on-hold)",
                        opts = { desc = "[word] Mark as On Hold" },
                    },

                    -- Mark the task under the cursor as "cancelled"
                    -- ^mark Task as Cancelled
                    {
                        "<LocalLeader>tc",
                        "<Plug>(word.qol.todo-items.todo.task-cancelled)",
                        opts = { desc = "[word] Mark as Cancelled" },
                    },

                    -- Mark the task under the cursor as "recurring"
                    -- ^mark Task as Recurring
                    {
                        "<LocalLeader>tr",
                        "<Plug>(word.qol.todo-items.todo.task-recurring)",
                        opts = { desc = "[word] Mark as Recurring" },
                    },

                    -- Mark the task under the cursor as "important"
                    -- ^mark Task as Important
                    {
                        "<LocalLeader>ti",
                        "<Plug>(word.qol.todo-items.todo.task-important)",
                        opts = { desc = "[word] Mark as Important" },
                    },

                    -- Mark the task under the cursor as "ambiguous"
                    -- ^mark Task as Ambiguous
                    {
                        "<LocalLeader>ta",
                        "<Plug>(word.qol.todo-items.todo.task-ambiguous)",
                        opts = { desc = "[word] Mark as Ambigous" },
                    },

                    -- Switch the task under the cursor between a select few states
                    {
                        "<C-Space>",
                        "<Plug>(word.qol.todo-items.todo.task-cycle)",
                        opts = { desc = "[word] Cycle Task" },
                    },

                    -- Hop to the destination of the link under the cursor
                    { "<CR>", "<Plug>(word.esupports.hop.hop-link)", opts = { desc = "[word] Jump to Link" } },

                    -- Same as `<CR>`, except open the destination in a vertical split
                    {
                        "<M-CR>",
                        "<Plug>(word.esupports.hop.hop-link.vsplit)",
                        opts = { desc = "[word] Jump to Link (Vertical Split)" },
                    },

                    -- Promote an object non-recursively
                    {
                        ">.",
                        "<Plug>(word.promo.promote)",
                        opts = { desc = "[word] Promote Object (Non-Recursively)" },
                    },
                    -- Demote an object non-recursively
                    { "<,",   "<Plug>(word.promo.demote)",           opts = { desc = "[word] Demote Object (Non-Recursively)" } },

                    -- Promote an object recursively
                    {
                        ">>",
                        "<Plug>(word.promo.promote.nested)",
                        opts = { desc = "[word] Promote Object (Recursively)" },
                    },
                    -- Demote an object recursively
                    {
                        "<<",
                        "<Plug>(word.promo.demote.nested)",
                        opts = { desc = "[word] Demote Object (Recursively)" },
                    },

                    -- Toggle a list from ordered <-> unordered
                    -- ^List Toggle
                    {
                        "<LocalLeader>lt",
                        "<Plug>(word.pivot.list.toggle)",
                        opts = { desc = "[word] Toggle (Un)ordered List" },
                    },

                    -- Invert all items in a list
                    -- Unlike `<LocalLeader>lt`, inverting a list will respect mixed list
                    -- items, instead of snapping all list types to a single one.
                    -- ^List Invert
                    {
                        "<LocalLeader>li",
                        "<Plug>(word.pivot.list.invert)",
                        opts = { desc = "[word] Invert (Un)ordered List" },
                    },

                    -- Insert a link to a date at the given position
                    -- ^Insert Date
                    { "<LocalLeader>id", "<Plug>(word.time.insert-date)", opts = { desc = "[word] Insert Date" } },

                    -- Magnifies a code block to a separate buffer.
                    -- ^Code Magnify
                    {
                        "<LocalLeader>cm",
                        "<Plug>(word.looking-glass.magnify-code-block)",
                        opts = { desc = "[word] Magnify Code Block" },
                    },
                },

                i = {
                    -- Promote an object recursively
                    {
                        "<C-t>",
                        "<Plug>(word.promo.promote)",
                        opts = { desc = "[word] Promote Object (Recursively)" },
                    },

                    -- Demote an object recursively
                    { "<C-d>",  "<Plug>(word.promo.demote)",         opts = { desc = "[word] Demote Object (Recursively)" } },

                    -- Create an iteration of e.g. a list item
                    { "<M-CR>", "<Plug>(word.itero.next-iteration)", opts = { desc = "[word] Continue Object" } },

                    -- Insert a link to a date at the current cursor position
                    -- ^Date
                    {
                        "<M-d>",
                        "<Plug>(word.time.insert-date.insert-mode)",
                        opts = { desc = "[word] Insert Date" },
                    },
                },

                v = {
                    -- Promote objects in range
                    { ">", "<Plug>(word.promo.promote.range)", opts = { desc = "[word] Promote Objects in Range" } },
                    -- Demote objects in range
                    { "<", "<Plug>(word.promo.demote.range)",  opts = { desc = "[word] Demote Objects in Range" } },
                },
            },
        },
    },
}

return init
