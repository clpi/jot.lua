local mod = require('down.mod')
local config = require("down.config")

---@type down.Mod
local M = mod.new('data', {
  -- "log",
  -- "store",
  -- "task",
  -- "mod",
  -- "sync",
  -- "dirs",
  -- "tag",
  -- "clipboard",
  -- "media",
  -- "template",
  -- "metadata",
  -- "todo",
  -- "task",
  -- "save"
  -- "code",
})

---@type down.Store<down.File>
M.data.files = {
  store = {},
}

M.setup = function()
  vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
      M.data.flush()
    end,
  })

  M.data.sync()
  ---@type down.mod.Setup
  return {
    loaded = true,
    requires = {},
  }
end

---@class down.mod.data.Config
M.config = {
  path = vim.fn.stdpath('data') .. '/down.mpack',
}
---@class down.mod.data.Data
M.data = {
  data = {}
}
M.data.concat = function(p1, p2)
  return table.concat({ p1, config.pathsep, p2 })
end

M.data.directory_map = function(path, callback)
  for name, type in vim.fs.dir(path) do
    if type == 'directory' then
      M.data.directory_map(M.data.concat(path, name), callback)
    else
      callback(name, type, path)
    end
  end
end

--- Recursively copies a directory from one path to another
---@param old_path string #The path to copy
---@param new_path string #The new location. This function will not
--- succeed if the directory already exists.
---@return boolean #If true, the directory copying succeeded
M.data.copy_directory = function(old_path, new_path)
  local file_permissions = tonumber('744', 8)
  local ok, err = vim.loop.fs_mkdir(new_path, file_permissions)

  if not ok then
    return ok, err ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
  end

  for name, type in vim.fs.dir(old_path) do
    if type == 'file' then
      ok, err = vim.loop.fs_copyfile(
        M.data.concat({ old_path, name }),
        M.data.concat(new_path, name)
      )

      if not ok then
        return ok, err ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
      end
    elseif type == 'directory' and not vim.endswith(new_path, name) then
      ok, err = M.data.copy_directory(
        M.data.concat(old_path, name),
        M.data.concat(new_path, name)
      )

      if not ok then
        return ok, err ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
      end
    end
  end

  return true, nil ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
end
--- Grabs the data present on disk and overwrites it with the data present in memory
M.data.sync = function()
  local file = io.open(M.config.path, 'r')
  if not file then
    return
  end
  local content = file:read('*a')
  io.close(file)
  local c = vim.mpack.decode(content)
  M.data.data = vim.mpack.decode and vim.mpack.decode(content)
end

--- Stores a key-value pair in the store
---@param key string #The key to index in the store
---@param data any #The data to store at the specific key
M.data.store = function(key, data)
  M.data.data[key] = data
end

--- Removes a key from store
---@param key string #The name of the key to remove
M.data.remove = function(key)
  M.data.data[key] = nil
end

--- Retrieves a key from the store
---@param key string #The name of the key to index
---@return any|table #The data present at the key, or an empty table
M.data.retrieve = function(key)
  return M.data.data[key] or {}
end

--- Flushes the contents in memory to the location specified
M.data.flush = function()
  local file = io.open(M.config.path, 'w')

  if not file then
    return
  end

  file:write(
    vim.mpack.encode and vim.mpack.encode(M.data.data) or vim.mpack.pack(M.data.data)
  )

  io.close(file)
end


M.subscribed = {}

return M
