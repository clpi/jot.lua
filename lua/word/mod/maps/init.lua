--[[
    file: User-maps
    title: The Language of word
    description: `base.maps` manages mappings for operations on or in `.word` files.
    summary: init for managing keybindings with word mode support.
    ---
The `base.maps` init configures an out-of-the-box Neovim experience by providing a base
set of maps.

To disable base maps, see the next section. To remap the existing maps, see [here](https://github.com/nvim-word/word/wiki/User-maps#remapping-maps).

To find common problems, consult the [FAQ](https://github.com/nvim-word/word/wiki/User-maps#faq).

### Disabling base maps

By base when you load the `base.maps` init all maps will be enabled. If you would like to change this, be sure to set `base_maps` to `false`:
```lua
["maps"] = {
    config = {
        base_maps = false,
    },
}
```

### Remapping maps

To understand how to effectively remap maps, one must understand how maps are set.
word binds actions to various `<Plug>` mappings that look like so: `<Plug>(word...`.

To remap a key, simply map an action somewhere in your configuration:

```lua
vim.keymap.set("n", "my-key-here", "<Plug>(word.pivot.list.toggle)", {})
```

word will recognize that the key has been bound by you and not bind its own key.

#### Binding maps for word Files Only

This approach has a downside - all of word's maps are set on a per-buffer basis
so that maps don't "overflow" into buffers you don't want them active in.

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
This way, your remapped maps will never interfere with other files.

### Discovering maps

A comprehensive list of all maps can be found on [this page!](https://github.com/nvim-word/word/wiki/base-maps)

## FAQ

### Some (or all) maps do not work

word refuses to bind maps when it knows they'll interfere with your configuration.
Run `:checkhealth word` to see a full list of what maps word has considered "conflicted"
or "rebound".

If you see that *all* of your maps are in conflict, you're likely using a plugin that is mapping to your
local leader key. This is a known issue with older versions of `which-key.nvim`. Since version `3.0` of which-key the issue has been fixed - we
recommend updating to the latest version to resolve the errors.

--]]

local word = require("word")
local mod = word.mod

local M = M.create("maps")

local bound_maps = {}

M.load = function()
  if M.config.public.base_maps then
    local preset = M.private.presets[M.config.public.preset]
    assert(preset, string.format("keybind preset `%s` does not exist!", M.config.public.preset))

    M.public.set_maps_for(false, preset.all)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        M.public.set_maps_for(ev.buf, preset.word)
      end,
    })
  end
end

M.config.public = {
  -- Whether to enable the base maps.
  base_maps = true,

  -- Which keybind preset to use.
  -- Currently allows only a single value: `"word"`.
  preset = "word",
}

---@class base.maps
M.public = {
  --- Adds a set of base maps for word to bind.
  --- Should be used exclusively by external mod wanting to provide their own base maps.
  ---@param name string The name of the preset to extend (allows for providing base maps for various presets)
  ---@param preset word.maps.preset The preset data itself.
  extend_preset = function(name, preset)
    local original_preset = assert(M.private.presets[name], "provided preset doesn't exist!")

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
    M.public.bind_word_maps(vim.api.nvim_get_current_buf())
  end,

  ---@param buffer number|boolean
  ---@param preset_subdata table
  set_maps_for = function(buffer, preset_subdata)
    for mode, maps in pairs(preset_subdata) do
      bound_maps[mode] = bound_maps[mode] or {}

      for _, keybind in ipairs(maps) do
        if
            vim.fn.hasmapto(keybind[2], mode, false) == 0
            and vim.fn.mapcheck(keybind[1], mode, false):len() == 0
        then
          local opts = vim.tbl_deep_extend("force", { buffer = buffer }, keybind.opts or {})
          vim.keymap.set(mode, keybind[1], keybind[2], opts)

          bound_maps[mode][keybind[1]] = true
        end
      end
    end
  end,

  --- Checks the health of maps. Returns all remaps and all conflicts in a table.
  ---@return { preset_exists: boolean, remaps: table<string, string>, conflicts: table<string, string> }
  health = function()
    local preset = M.private.presets[M.config.public.preset]

    if not preset then
      return {
        preset_exists = false,
      }
    end

    local remaps = {}
    local conflicts = {}

    local function check_maps_for(data)
      for mode, maps in pairs(data) do
        for _, keybind in ipairs(maps) do
          if not bound_maps[mode] or not bound_maps[mode][keybind[1]] then
            if vim.fn.hasmapto(keybind[2], mode, false) ~= 0 then
              remaps[keybind[1]] = keybind[2]
            elseif vim.fn.mapcheck(keybind[1], mode, false):len() ~= 0 then
              conflicts[keybind[1]] = keybind[2]
            end
          end
        end
      end
    end

    check_maps_for(preset.all)
    check_maps_for(preset.word)

    return {
      preset_exists = true,
      remaps = remaps,
      conflicts = conflicts,
    }
  end,
}

M.private = {

  -- TODO: Move these to the "vim" preset
  -- { "gd", "<Plug>(word.esupports.hop.hop-link)", opts = { desc = "[word] Jump to Link" } },
  -- { "gf", "<Plug>(word.esupports.hop.hop-link)", opts = { desc = "[word] Jump to Link" } },
  -- { "gF", "<Plug>(word.esupports.hop.hop-link)", opts = { desc = "[word] Jump to Link" } },
  presets = {
    ---@class word.maps.preset
    word = {
      all = {
        n = {
          -- Create a new `.word` file to take notes in
          -- ^New Note
          {
            "<LocalLeader>nn",
            "<Plug>(word.vault.new-note)",
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
