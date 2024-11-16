--[[
    File: store
    Title: Store persistent data and query it easily with `base.store`
    Summary: Deals with storing persistent data across word sessions.
    Internal: true
    ---
--]]

local word = require("word")
local mod = word.mod

local module = mod.create("store")

module.setup = function()
    return {
        requires = {
            "autocmd",
        },
    }
end

module.config.public = {
    -- Full path to store data (saved in mpack data format)
    path = vim.fn.stdpath("data") .. "/word.mpack",
}

module.private = {
    data = {},
}

---@class base.store
module.public = {
    --- Grabs the data present on disk and overwrites it with the data present in memory
    sync = function()
        local file = io.open(module.config.public.path, "r")

        if not file then
            return
        end

        local content = file:read("*a")

        io.close(file)

        module.private.data = vim.mpack.decode and vim.mpack.decode(content) or vim.mpack.unpack(content)
    end,

    --- Stores a key-value pair in the store
    ---@param key string #The key to index in the store
    ---@param data any #The data to store at the specific key
    store = function(key, data)
        module.private.data[key] = data
    end,

    --- Removes a key from store
    ---@param key string #The name of the key to remove
    remove = function(key)
        module.private.data[key] = nil
    end,

    --- Retrieves a key from the store
    ---@param key string #The name of the key to index
    ---@return any|table #The data present at the key, or an empty table
    retrieve = function(key)
        return module.private.data[key] or {}
    end,

    --- Flushes the contents in memory to the location specified in the `path` configuration option.
    flush = function()
        local file = io.open(module.config.public.path, "w")

        if not file then
            return
        end

        file:write(vim.mpack.encode and vim.mpack.encode(module.private.data) or vim.mpack.pack(module.private.data))

        io.close(file)
    end,
}

module.on_event = function(event)
    -- Synchronize the data in memory with the data on disk after we leave Neovim
    if event.type == "autocmd.events.vimleavepre" then
        module.public.flush()
    end
end

module.load = function()
    module.required["autocmd"].enable_autocommand("VimLeavePre")

    module.public.sync()
end

module.events.subscribed = {
    ["autocmd"] = {
        vimleavepre = true,
    },
}

return module
