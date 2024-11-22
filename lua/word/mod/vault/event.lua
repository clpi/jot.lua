local vault_utils = require("word.mod.vault.utils")
local mod = require("word").mod
local log = require("word").log
local utils = require("word").utils
local Path = require("pathlib")
M = {}
M.on_event = function(event)
  -- If somebody has executed the :word vault command then
  if event.type == "cmd.events.vault.vault" then
    -- Have we supplied an argument?
    if event.content[1] then
      M.public.open_vault(event.content[1])

      vim.schedule(function()
        local new_vault = M.public.get_vault(event.content[1])

        if not new_vault then
          return
        end

        utils.notify("New vault: " .. event.content[1] .. " -> " .. new_vault)
      end)
    else -- No argument supplied, simply print the current vault
      -- Query the current vault
      local current_ws = M.public.get_current_vault()
      -- Nicely print it. We schedule_wrap here because people with a configured logger will have this message
      -- silenced by other trace logs
      vim.schedule(function()
        utils.notify("Current vault: " .. current_ws[1] .. " -> " .. current_ws[2])
      end)
    end
  end

  -- If somebody has executed the :word index command then
  if event.type == "cmd.events.vault.index" then
    local current_ws = M.public.get_current_vault()

    local index_path = current_ws[2] / M.public.get_index()

    if vim.fn.filereadable(index_path:tostring("/")) == 0 then
      if current_ws[1] == "base" then
        utils.notify(table.concat({
          "Index file cannot be created in 'base' vault to avoid confusion.",
          "If this is intentional, manually create an index file beforehand to use this command.",
        }, " "))
        return
      end
      if not index_path:touch(Path.const.o644, true) then
        utils.notify(
          table.concat({
            "Unable to create '",
            M.public.get_index(),
            "' in the current vault - are your filesystem permissions set correctly?",
          }),
          vim.log.levels.WARN
        )
        return
      end
    end

    vault_utils.edit_file(index_path:cmd_string())
    return
  end
end

M.events.defined = {
  vault_changed = mod.define_event(M, "vault_changed"),
  vault_added = mod.define_event(M, "vault_added"),
  vault_cache_empty = mod.define_event(M, "vault_cache_empty"),
  file_created = mod.define_event(M, "file_created"),
}

M.events.subscribed = {
  ["vault"] = {
    vault_changed = true,
  },
  cmd = {
    ["vault.vault"] = true,
    ["vault.index"] = true,
  },
}
return M
