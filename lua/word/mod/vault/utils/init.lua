--[[
    file: vault-Utils
    summary: A set of utilities for the `base.vault` init.
    internal: true
    ---
This internal subinit implements some basic utility functions for [`base.vault`](@base.vault).
Currently the only exposed API function is `expand_path`, which takes a path like `$name/my/location` and
converts `$name` into the full path of the vault called `name`.
--]]

local Path = require("pathlib")

local word = require("word")
local log, mod = word.log, word.mod

local init = word.mod.create("vault.utils")

---@class base.vault.utils
init.public = {
  ---Resolve `$<vault>/path/to/file` and return the real path
  ---@param path string | PathlibPath # path
  ---@param raw_path boolean? # If true, returns resolved path, otherwise, returns resolved path
  ---and append ".word"
  ---@param host_file string | PathlibPath | nil file the link resides in, if the link is
  ---relative, this file is used instead of the current file
  ---@return PathlibPath?, boolean? # Resolved path. If path does not start with `$` or not absolute, adds
  ---relative from current file.
  expand_pathlib = function(path, raw_path, host_file)
    local relative = false
    if not host_file then
      host_file = vim.fn.expand("%:p")
    end
    local filepath = Path(path)
    -- Expand special chars like `$`
    local custom_vault_path = filepath:match("^%$([^/\\]*)[/\\]")
    if custom_vault_path then
      ---@type base.vault
      local ws = mod.get_mod("vault")
      if not vault then
        log.error(table.concat({
          "Unable to jump to link with custom vault: `default.vault` is not loaded.",
          "Please load the init in order to get vault support.",
        }, " "))
        return
      end
      -- If the user has given an empty vault name (i.e. `$/myfile`)
      if custom_vault_path:len() == 0 then
        filepath = ws.get_current_vault()[2] / filepath:relative_to(Path("$"))
      else -- If the user provided a vault name (i.e. `$my-vault/myfile`)
        local vault = ws.get_vault(custom_vault_path)
        if not vault then
          local msg = "Unable to expand path: vault '%s' does not exist"
          log.warn(string.format(msg, custom_vault_path))
          return
        end
        filepath = ws / filepath:relative_to(Path("$" .. custom_vault_path))
      end
    elseif filepath:is_relative() then
      relative = true
      local this_file = Path(host_file):absolute()
      filepath = this_file:parent_assert() / filepath
    else
      filepath = filepath:absolute()
    end
    -- requested to expand word file
    if not raw_path then
      if type(path) == "string" and (path:sub(#path) == "/" or path:sub(#path) == "\\") then
        -- if path ends with `/`, it is an invalid request!
        log.error(table.concat({
          "md file location cannot point to a directory.",
          string.format("Current link points to '%s'", path),
          "which ends with a `/`.",
        }, " "))
        return
      end
      filepath = filepath:add_suffix(".md")
    end
    return filepath, relative
  end,

  ---Call attempt to edit a file, catches and suppresses the error caused by a swap file being
  ---present. Re-raises other errors via log.error
  ---@param path string
  edit_file = function(path)
    local ok, err = pcall(vim.cmd.edit, path)
    if not ok then
      -- Vim:E325 is the swap file error, in which case, a lengthy message already shows to
      -- the user, and we don't have to crash out of this function (which creates a long and
      -- misleading error message).
      if err and not err:match("Vim:E325") then
        log.error(("Failed to edit file %s. Error:\n%s"):format(path, err))
      end
    end
  end,

  ---Resolve `$<vault>/path/to/file` and return the real path
  -- NOTE: Use `expand_pathlib` which returns a PathlibPath object instead.
  ---
  ---\@deprecate Use `expand_pathlib` which returns a PathlibPath object instead. TODO: deprecate this <2024-03-27>
  ---@param path string|PathlibPath # path
  ---@param raw_path boolean? # If true, returns resolved path, otherwise, returns resolved path and append ".word"
  ---@return string? # Resolved path. If path does not start with `$` or not absolute, adds relative from current file.
  expand_path = function(path, raw_path)
    local res = init.public.expand_pathlib(path, raw_path)
    return res and res:tostring() or nil
  end,
}

return init
