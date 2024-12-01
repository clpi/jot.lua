--[[
    File: store
    Title: Store persistent data and query it easily with `base.store`
    Summary: Deals with storing persistent data across jot sessions.
    Internal: true
    ---
--]]
local M = Mod.create("data", {
  -- "sync",
  -- "log",
  -- "tag",
  -- "metadata",
  -- "media",
  -- "encrypt",
  -- "export",
  -- "dirs",
  -- "save",
})

M.setup = function()
  return {
    success = true,
    requires = {
      "data.dirs",
    },
  }
end

M.config.public = {
  -- Full path to store data (saved in mpack data format)
  path = vim.fn.stdpath("data") .. "/jot.mpack",
}

M.private = {
  data = {},
}

---@class base.store
M.public = {
  directory_map = function(path, callback)
    for name, type in vim.fs.dir(path) do
      if type == "directory" then
        M.public.directory_map(table.concat({ path, "/", name }), callback)
      else
        callback(name, type, path)
      end
    end
  end,

  --- Recursively copies a directory from one path to another
  ---@param old_path string #The path to copy
  ---@param new_path string #The new location. This function will not
  --- succeed if the directory already exists.
  ---@return boolean #If true, the directory copying succeeded
  copy_directory = function(old_path, new_path)
    local file_permissions = tonumber("744", 8)
    local ok, err = vim.loop.fs_mkdir(new_path, file_permissions)

    if not ok then
      return ok, err ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
    end

    for name, type in vim.fs.dir(old_path) do
      if type == "file" then
        ok, err = vim.loop.fs_copyfile(
          table.concat({ old_path, "/", name }),
          table.concat({ new_path, "/", name })
        )

        if not ok then
          return ok, err ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
        end
      elseif type == "directory" and not vim.endswith(new_path, name) then
        ok, err = module.public.copy_directory(
          table.concat({ old_path, "/", name }),
          table.concat({ new_path, "/", name })
        )

        if not ok then
          return ok, err ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
        end
      end
    end

    return true, nil ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
  end,
  --- Grabs the data present on disk and overwrites it with the data present in memory
  sync = function()
    local file = io.open(M.config.public.path, "r")

    if not file then
      return
    end

    local content = file:read("*a")

    io.close(file)

    M.private.data = vim.mpack.decode and vim.mpack.decode(content)
      or vim.mpack.unpack(content)
  end,

  --- Stores a key-value pair in the store
  ---@param key string #The key to index in the store
  ---@param data any #The data to store at the specific key
  store = function(key, data)
    M.private.data[key] = data
  end,

  --- Removes a key from store
  ---@param key string #The name of the key to remove
  remove = function(key)
    M.private.data[key] = nil
  end,

  --- Retrieves a key from the store
  ---@param key string #The name of the key to index
  ---@return any|table #The data present at the key, or an empty table
  retrieve = function(key)
    return M.private.data[key] or {}
  end,

  --- Flushes the contents in memory to the location specified in the `path` configuration option.
  flush = function()
    local file = io.open(M.config.public.path, "w")

    if not file then
      return
    end

    file:write(
      vim.mpack.encode and vim.mpack.encode(M.private.data)
        or vim.mpack.pack(M.private.data)
    )

    io.close(file)
  end,
}

M.load = function()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      M.public.flush()
    end,
  })

  M.public.sync()
end

M.events.subscribed = {}

return M
