local workspace_utils = require("word.mod.workspace.utils")
local mod = require("word").mod
local log = require("word").log
local utils = require("word").utils
local Path = require("pathlib")
M = {}
M.on_event = function(event)
  -- If somebody has executed the :word workspace command then
  if event.type == "cmd.events.workspace.workspace" then
    -- Have we supplied an argument?
    if event.content[1] then
      M.public.open_workspace(event.content[1])

      vim.schedule(function()
        local new_workspace = M.public.get_workspace(event.content[1])

        if not new_workspace then
          return
        end

        utils.notify("New Workspace: " .. event.content[1] .. " -> " .. new_workspace)
      end)
    else -- No argument supplied, simply print the current workspace
      -- Query the current workspace
      local current_ws = M.public.get_current_workspace()
      -- Nicely print it. We schedule_wrap here because people with a configured logger will have this message
      -- silenced by other trace logs
      vim.schedule(function()
        utils.notify("Current Workspace: " .. current_ws[1] .. " -> " .. current_ws[2])
      end)
    end
  end

  -- If somebody has executed the :word index command then
  if event.type == "cmd.events.workspace.index" then
    local current_ws = M.public.get_current_workspace()

    local index_path = current_ws[2] / M.public.get_index()

    if vim.fn.filereadable(index_path:tostring("/")) == 0 then
      if current_ws[1] == "base" then
        utils.notify(table.concat({
          "Index file cannot be created in 'base' workspace to avoid confusion.",
          "If this is intentional, manually create an index file beforehand to use this command.",
        }, " "))
        return
      end
      if not index_path:touch(Path.const.o644, true) then
        utils.notify(
          table.concat({
            "Unable to create '",
            M.public.get_index(),
            "' in the current workspace - are your filesystem permissions set correctly?",
          }),
          vim.log.levels.WARN
        )
        return
      end
    end

    workspace_utils.edit_file(index_path:cmd_string())
    return
  end
end

M.events.defined = {
  workspace_changed = mod.define_event(M, "workspace_changed"),
  workspace_added = mod.define_event(M, "workspace_added"),
  workspace_cache_empty = mod.define_event(M, "workspace_cache_empty"),
  file_created = mod.define_event(M, "file_created"),
}

M.events.subscribed = {
  ["workspace"] = {
    workspace_changed = true,
  },
  cmd = {
    ["workspace.workspace"] = true,
    ["workspace.index"] = true,
  },
}
return M
