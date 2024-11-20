--[[
    File: store
    Title: Store persistent data and query it easily with `base.store`
    Summary: Deals with storing persistent data across word sessions.
    Internal: true
    ---
--]]

local M = require("word").mod.create("store")

M.setup = function()
  return {
    requires = {
    },
  }
end

M.config.public = {
  -- Full path to store data (saved in mpack data format)
  path = vim.fn.stdpath("data") .. "/word.mpack",
}

M.private = {
  data = {},
}

---@class base.store
M.public = {
  --- Grabs the data present on disk and overwrites it with the data present in memory
  sync = function()
    local file = io.open(M.config.public.path, "r")

    if not file then
      return
    end

    local content = file:read("*a")

    io.close(file)

    M.private.data = vim.mpack.decode and vim.mpack.decode(content) or vim.mpack.unpack(content)
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

    file:write(vim.mpack.encode and vim.mpack.encode(M.private.data) or vim.mpack.pack(M.private.data))

    io.close(file)
  end,
}

M.on_event = function(event)
end

M.load = function()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    pattern = "markdown",
    callback = function()
      M.public.flush()
    end,
  })

  M.public.sync()
end

M.events.subscribed = {
}

return M
