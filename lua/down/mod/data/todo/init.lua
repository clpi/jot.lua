local mod, map = require("down.mod"), require("down.util.maps")

local M = mod.create("data.task")

M.maps = function()
  map.nmap(",wt", "<CMD>Telescope down task<CR>")
end

---@class down.data.task.Data
M.data = {
  namespace = vim.api.nvim_create_namespace("down.data.task"),

  --- List of active buffers
  buffers = {},
}
---@class down.data.task.Config
M.config = {

  highlight_group = "Normal",

  counted_statuses = {
    "done",
    "pending",
    "undone",
    "urgent",
  },

  completed_statuses = {
    "done",
  },

  format = function(completed, total)
    return string.format(
      "[%d/%d] (%d%%)",
      completed,
      total,
      (total ~= 0 and math.floor((completed / total) * 100) or 0)
    )
  end,
}

M.setup = function()
  return {
    loaded = true,
    requires = { "tool.treesitter" },
  }
end

M.load = function()
  vim.api.nvim_create_autocmd("Filetype", {
    pattern = "markdown",
    desc = "Attaches the task introspector to any down buffer.",
    callback = function(ev)
      local buf = ev.buf

      if M.data.buffers[buf] then
        return
      end

      M.data.buffers[buf] = true
      -- M.public.attach_introspector(buf) -- task
    end,
  })
end

--- Attaches the introspector to a given down buffer.
--- Errors if the target buffer is not a down buffer.
---@param buffer number #The buffer ID to attach to.
function M.data.attach_introspector(buffer)
  if
      not vim.api.nvim_buf_is_valid(buffer)
      or vim.bo[buffer].filetype ~= "markdown"
  then
    error(
      string.format(
        "Could not attach to buffer %d, buffer is not a down file!",
        buffer
      )
    )
  end

  M.required["tool.treesitter"].execute_query(
    [[
    (_
      state: (detached_modifier_extension)) @item
    ]],
    function(query, id, node)
      if query.captures[id] == "item" then
        M.data.perform_introspection(buffer, node)
      end
    end,
    buffer
  )

  vim.api.nvim_buf_attach(buffer, false, {
    on_lines = vim.schedule_wrap(function(_, buf, _, first)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      -- If we delete the last line of a file `first` will point to a nonexistent line
      -- For this reason we fall back to the line count (accounting for 0-based indexing)
      -- whenever a change to the document is made.
      first = math.min(first, vim.api.nvim_buf_line_count(buf) - 1)

      ---@type TSNode?
      local node =
          M.required["tool.treesitter"].get_first_node_on_line(buf, first)

      if not node then
        return
      end

      vim.api.nvim_buf_clear_namespace(
        buffer,
        M.data.namespace,
        first + 1,
        first + 1
      )

      local function introspect(start_node)
        local parent = start_node

        while parent do
          local child = parent:named_child(1)

          if child and child:type() == "detached_modifier_extension" then
            M.data.perform_introspection(buffer, parent)
            -- NOTE: do not break here as we want the introspection to propagate all the way up the syntax tree
          end

          parent = parent:parent()
        end
      end

      introspect(node)

      local node_above =
          M.required["tool.treesitter"].get_first_node_on_line(
            buf,
            first - 1
          )

      do
        local task_status = node_above:named_child(1)

        if
            task_status and task_status:type() == "detached_modifier_extension"
        then
          introspect(node_above)
        end
      end
    end),

    on_detach = function()
      vim.api.nvim_buf_clear_namespace(buffer, M.data.namespace, 0, -1)
      M.data.buffers[buffer] = nil
    end,
  })
end

--- Aggregates task item counts from children.
---@param node TSNode
---@return number completed Total number of completed tasks
---@return number total Total number of counted tasks
function M.data.calculate_items(node)
  local counts = {}
  for _, status in ipairs(M.config.counted_statuses) do
    counts[status] = 0
  end

  local total = 0

  -- Go through all the children of the current task item node and count the amount of "done" children
  for child in node:iter_children() do
    if
        child:named_child(1)
        and child:named_child(1):type() == "detached_modifier_extension"
    then
      for status in child:named_child(1):iter_children() do
        if status:type():match("^task_item_") then
          local type = status:type():match("^task_item_(.+)$")

          if not counts[type] then
            break
          end

          counts[type] = counts[type] + 1
          total = total + 1
        end
      end
    end
  end

  local completed = 0
  for _, status in ipairs(M.config.completed_statuses) do
    if counts[status] then
      completed = completed + counts[status]
    end
  end

  return completed, total
end

--- Displays the amount of done items in the form of an extmark.
---@param buffer number
---@param node TSNode
function M.data.perform_introspection(buffer, node)
  local completed, total = M.data.calculate_items(node)

  local line, col = node:start()

  vim.api.nvim_buf_clear_namespace(buffer, M.data.namespace, line, line + 1)

  if total == 0 then
    return
  end

  vim.api.nvim_buf_set_extmark(buffer, M.data.namespace, line, col, {
    virt_text = {
      {
        M.config.format(completed, total),
        M.config.highlight_group,
      },
    },
    invalidate = true,
  })
end

return M
