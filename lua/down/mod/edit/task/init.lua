local down = require('down')
local util = require 'down.util'
local log, mod = down.log, down.mod

---@type down.Mod
local M = mod.new('edit.task')

---@type down.mod.Setup
M.setup = function()
  return {
    loaded = true,
    requires = { 'tool.treesitter' },
  }
end

M.load = function()
  for _, task in ipairs({
    'done',
    'undone',
    'pending',
    'on-hold',
    'cancelled',
    'important',
    'recurring',
    'ambiguous',
    'cycle',
    'cycle-reverse',
  }) do
    vim.keymap.set(
      '',
      string.format('<Plug>(down.insert.task.task.task-%s)', task),
      M.data['task-' .. task]
    )
  end
end

---@class down.edit.task.Config
M.config = {
  -- The default order of task item cycling when cycling via
  -- `<C-Space>`.
  --
  -- Defaults to the following order: `undone`, `done`, `pending`.
  order = {
    { 'undone', ' ' },
    { 'done', 'x' },
    { 'pending', '-' },
  },

  -- The default order of task item cycling when the item
  -- has nested children with task items.
  --
  -- When cycling through task items with children it's not
  -- always sensible to follow the same schema as the `order` table.
  --
  -- Defaults to the following order: `undone`, `done`.
  order_with_children = {
    { 'undone', ' ' },
    { 'done', 'x' },
  },

  -- When set to `true`, will automatically convert parent
  -- items to tasks whenever a child item's task state is updated.
  --
  -- For instance, given the following example:
  -- ```markdown
  -- - Text
  -- -- ( ) Child text
  -- ```
  --
  -- When this option is `true` and the child's state is updated to e.g.
  -- `(x)` via the `<LocaLeader>td` keybind, the new output becomes:
  -- ```markdown
  -- - (x) Text
  -- -- (x) Child text
  -- ```
  create_task_parents = false,

  -- When `true`, will automatically create a task extension for an item
  -- if it does not exist and an operation is performed on that item.
  --
  -- Given the following example:
  -- ```markdown
  -- - Test Item
  -- ```
  -- With this option set to true, performing an operation (like pressing `<C-space>`
  -- or what have you) will convert the non-task item into one:
  -- ```markdown
  -- - ( ) Test Item
  -- ```
  create_tasks = true,
}

---@alias taskItemType "undone"
---|"pending"
---|"done"
---|"cancelled"
---|"recurring"
---|"on_hold"
---|"urgent"
---|"uncertain"

data = {}

local function task_set(character, name)
  return util.wrap_dotrepeat(function()
    local buffer = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)

    local task_at_cursor = M.data.data.get_task_from_cursor(buffer, cursor[1] - 1)

    if not task_at_cursor then
      return
    end

    M.data.data.make_all(buffer, task_at_cursor, name, character)
  end)
end

------@class down.edit.task.Data
M.data = {
  data = {

    --- Updates the parent task item for the current task item if it exists
    ---@param recursion_level number the index of the parent to change. The higher the number the more the code will traverse up the syntax tree.
    update_parent = function(buf, line, recursion_level)
      -- Force a reparse (this is required because otherwise some cached nodes will be incorrect)
      vim.treesitter.get_parser(buf, 'markdown'):parse()

      -- If present grab the item that is under the cursor
      local item_at_cursor = M.data.data.get_task_from_cursor(buf, line)

      if not item_at_cursor then
        return
      end

      -- If we set a recursion level then go through and traverse up the syntax tree `recursion_level` times
      for _ = 0, recursion_level do
        item_at_cursor = item_at_cursor:parent() ---@diagnostic disable-line -- task: type error workaround <pysan3>
      end

      -- If the final item does not exist or the target item is not a detached modifier
      -- (i.e. it does not have a "prefix" node) then it is not a node worth updating.
      if
        not item_at_cursor
        or not item_at_cursor:named_child(0)
        or not item_at_cursor:named_child(0):type():match('prefix')
      then
        return
      end

      local counts = {
        undone = 0,
        pending = 0,
        done = 0,
        cancelled = 0,
        recurring = 0,
        on_hold = 0,
        urgent = 0,
        uncertain = 0,
      }

      local counter = 0

      -- Go through all the children of the current task item node and count the amount of "done" children
      for node in item_at_cursor:iter_children() do
        if node:named_child(1) and node:named_child(1):type() == 'detached_modifier_extension' then
          for status in node:named_child(1):iter_children() do
            if status:type():match('^task_') then
              local type = status:type():match('^task_(.+)$')

              counts[type] = counts[type] + 1

              if type == 'cancelled' then
                break
              end

              counter = counter + 1
            end
          end
        end
      end

      -- [[
      --  Compare the counter to the amount of done items.
      --  If we have even one pending item then set the resulting char to `*`
      --  If the counter is the same as the done item count then that means all items are complete and we should display a done item in the parent.
      --  If the done item count is 0 then no task has been completed and we should set an undone item as the parent.
      --  If all other checks fail and the done item count is less than the total number of task items then set a pending item.
      -- ]]

      if counter == 0 then
        return
      end

      local resulting_char = ''

      if counts.uncertain > 0 and counts.done + counts.uncertain == counter then
        resulting_char = '='
      elseif counts.handle_hold > 0 and counts.done + counts.handle_hold + counts.uncertain == counter then
        resulting_char = '='
      elseif counts.pending > 0 then
        resulting_char = '-'
      elseif counter == counts.done then
        resulting_char = 'x'
      elseif counts.done == 0 then
        resulting_char = ' '
      elseif counts.done < counter then
        resulting_char = '-'
      end

      local first_status_extension =
        M.data.data.find_first_status_extension(item_at_cursor:named_child(1))

      -- task(vhyrro):
      -- Implement a toggleable behaviour where down can automatically convert this:
      --     * (@ Mon 5th Feb) Test
      --     ** ( ) Test
      -- To this:
      --     * (x|@ Mon 5th Feb) Test
      --     ** (x) Test
      if not first_status_extension then
        if not M.config.new_task_parents then
          return
        end

        local row, _, _, column = item_at_cursor:named_child(0):range()

        vim.api.nvim_buf_set_text(buf, row, column, row, column, { '(' .. resulting_char .. ') ' })

        M.data.data.update_parent(buf, line, recursion_level + 1)
        return
      end

      local range = M.required['tool.treesitter'].get_node_range(first_status_extension)

      -- Replace the line where the task item is situated
      vim.api.nvim_buf_set_text(
        buf,
        range.row_start,
        range.column_start,
        range.row_end,
        range.column_end,
        { resulting_char }
      )

      M.data.data.update_parent(buf, line, recursion_level + 1)
    end,

    --  modifier extension node.
    ---@param detached_modifier_extension_node userdata #A valid node of type `detached_modifier_extension`
    find_first_status_extension = function(detached_modifier_extension_node)
      if not detached_modifier_extension_node then
        return
      end

      for status in detached_modifier_extension_node:iter_children() do ---@diagnostic disable-line -- task: type error workaround <pysan3>
        if vim.startswith(status:type(), 'task_') then
          return status
        end
      end
    end,

    --- Tries to locate a task node under the cursor
    ---@return userdata? #The node if it was located, else nil
    get_task_from_cursor = function(buf, line)
      local node_at_cursor = M.required['tool.treesitter'].get_first_node_on_line(buf, line)

      if not node_at_cursor then
        return
      end

      -- This is done because sometimes the first node can be
      -- e.g `generic_list`, which only contains the top level list items and
      -- not their data. It doesn't cost us much to do this operation for other
      -- nodes anyway.
      if node_at_cursor:named_child(0) then
        node_at_cursor = node_at_cursor:named_child(0)
      end

      while true do
        if not node_at_cursor then
          log.trace('Could not find task item under cursor, aborting...')
          return
        end

        local first_named_child = node_at_cursor:named_child(0)

        if first_named_child and first_named_child:type():match('prefix') then
          break
        else
          node_at_cursor = node_at_cursor:parent()
        end
      end

      return node_at_cursor
    end,

    --- Returns the type of a task item (either "done", "pending" or "undone")
    ---@param task_node userdata #The task node to extract the data from
    ---@return taskItemType? #A task item type as a string, else nil
    get_task_type = function(task_node)
      if not task_node or not task_node:named_child(1) then ---@diagnostic disable-line -- task: type error workaround <pysan3>
        return
      end

      local task_type = M.data.data.find_first_status_extension(task_node:named_child(1)) ---@diagnostic disable-line -- task: type error workaround <pysan3>

      return task_type and task_type:type():sub(string.len('task_') + 1) or nil
    end,

    --- Converts the current node and all its children to a certain type
    ---@param buf number the current buffer number
    ---@param node userdata the node to modify
    ---@param task_type taskItemType #The task item type as a string
    ---@param char string the character to place within the square brackets of the task item (one of "x", "*" or " ")
    make_all = function(buf, node, task_type, char)
      if not node then
        return
      end

      local type = node:type():match('^(.+)%d+$') ---@diagnostic disable-line -- task: type error workaround <pysan3>

      -- If the type of the current task item differs from the one we want to change to then
      -- We do this because we don't want to be unnecessarily modifying a line that doesn't need changing
      if M.data.data.get_task_type(node) == task_type then
        return
      end

      local first_status_extension = M.data.data.find_first_status_extension(node:named_child(1)) ---@diagnostic disable-line -- task: type error workaround <pysan3>

      if not first_status_extension then
        if not M.config.new_tasks then
          return
        end

        local row, _, _, column = node:named_child(0):range() ---@diagnostic disable-line -- task: type error workaround <pysan3>

        vim.api.nvim_buf_set_text(buf, row, column, row, column, { '(' .. char .. ') ' })
      else
        local range = M.required['tool.treesitter'].get_node_range(first_status_extension)

        vim.api.nvim_buf_set_text(
          buf,
          range.row_start,
          range.column_start,
          range.row_end,
          range.column_end,
          { char }
        )
      end

      for child in node:iter_children() do ---@diagnostic disable-line -- task: type error workaround <pysan3>
        if type == child:type():match('^(.+)%d+$') then
          M.data.data.make_all(buf, child, task_type, char)
        end
      end
    end,

    task_cycle = function(buf, linenr, types, alternative_types)
      local task_at_cursor = M.data.data.get_task_from_cursor(buf, linenr - 1)

      if not task_at_cursor then
        return
      end

      local task_type = M.data.data.get_task_type(task_at_cursor)

      --- Gets the next item of a flat list based on the first item
      ---@param type_list table[] #A list of { "type", "char" } items
      ---@param item_type string #The `type` field from the `type_list` array
      ---@return number? #An index into the next item of `type_list`
      local function index(type_list, item_type)
        for i, element in ipairs(type_list) do
          if element[1] == item_type then
            if i >= #type_list then
              return 1
            else
              return i + 1
            end
          end
        end
      end

      if not task_type then
        if not M.config.new_tasks then
          return
        end

        M.data.data.make_all(buf, task_at_cursor, types[1][1], types[1][2])
        M.data.data.update_parent(buf, linenr - 1, 0)
        return
      end

      local index = index(types, task_type)

      local next = types[index] or types[1]

      for child in task_at_cursor:iter_children() do
        if M.data.data.get_task_type(child) then
          next = alternative_types[index(alternative_types, task_type)] or alternative_types[1]
          break
        end
      end

      M.data.data.make_all(buf, task_at_cursor, next[1], next[2])
      M.data.data.update_parent(buf, linenr - 1, 0)
    end,
  },
  ['task-done'] = task_set('x', 'done'),
  ['task-undone'] = task_set(' ', 'undone'),
  ['task-pending'] = task_set('-', 'pending'),
  ['task-on-hold'] = task_set('=', 'on_hold'),
  ['task-cancelled'] = task_set('_', 'cancelled'),
  ['task-important'] = task_set('!', 'important'),
  ['task-recurring'] = task_set('+', 'recurring'),
  ['task-ambiguous'] = task_set('?', 'ambiguous'),
  ['task-cycle'] = function()
    local buffer = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)

    M.data.data.task_cycle(buffer, cursor[1], M.config.order, M.config.order_with_children)
  end,
  ['task-cycle-reverse'] = function()
    local buffer = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)

    M.data.data.task_cycle(
      buffer,
      cursor[1],
      vim.fn.reverse(M.config.order),
      vim.fn.reverse(M.config.order_with_children)
    )
  end,
}

return M
