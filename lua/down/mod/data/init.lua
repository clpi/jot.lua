local mod = require('down.mod')
local config = require("down.config")

---@class down.mod.Data: down.Mod
local M = mod.new('data', {})

---@type down.Store<down.File>
M.data.files = {
  store = {},
}

--- @return down.mod.Setup
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

M.load = function()

end

---@class down.mod.data.Config
M.config = {
  path = vim.fn.stdpath('data') .. '/down.mpack',
  dir = {
    vim = vim.fs.joinpath(vim.fn.stdpath('data'), 'down/'),
    home = vim.fs.joinpath(os.getenv("HOME") or "~/", ".down/"),
  },
  file = {
    vim = vim.fs.joinpath(vim.fn.stdpath('data'), 'down/', 'down.json'),
    home = vim.fs.joinpath(os.getenv("HOME") or "~/", ".down/", 'down.json'),
  }
}
---@class down.mod.data.Data
M.data = {
  data = {}
}

M.data.concat = function(p1, p2)
  return table.concat({ p1, config.pathsep, p2 })
end

--- @param path string
--- @param cond? fun(name: string, ends: string): boolean
--- @return table<string>
M.data.files = function(path, cond)
  local f = {}
  local dir = path or vim.fs.root(vim.fn.cwd(), ".down/")
  for name, type in vim.fs.dir(dir) do
    if type == 'file' and cond or name:endswith(".md") then
      table.insert(f, name)
    elseif type == 'directory' and not name:startswith(".") then
      local fs = M.data.get_files(M.data.concat(path, name))
      for _, v in ipairs(fs) do
        table.insert(f, v)
      end
    end
  end
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

--- Recursively copies a directory froM.handlee path to another
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
