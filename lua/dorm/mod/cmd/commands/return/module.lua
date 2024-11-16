--[[
    file: cmd-return
    title: Provides the `:dorm return` Command
    summary: Return to last location before entering dorm.
    internal: true
    ---
When executed (`:dorm return`), all currently open `.dorm` files are deleted from
the buffer list, and the current workspace is set to "base".
--]]

local dorm = require("dorm")
local mod = dorm.mod

local module = mod.create("cmd.commands.return")

module.setup = function()
    return { success = true, requires = { "cmd" } }
end

module.public = {
    dorm_commands = {
        ["return"] = {
            args = 0,
            name = "return",
        },
    },
}

module.on_event = function(event)
    if event.type == "cmd.events.return" then
        -- Get all the buffers
        local buffers = vim.api.nvim_list_bufs()

        local to_delete = {}
        for buffer in vim.iter(buffers):rev() do
            if vim.fn.buflisted(buffer) == 1 then
                -- If the listed buffer we're working with has a .dorm extension then remove it (not forcibly)
                if not vim.endswith(vim.api.nvim_buf_get_name(buffer), ".dorm") then
                    vim.api.nvim_win_set_buf(0, buffer)
                    break
                else
                    table.insert(to_delete, buffer)
                end
            end
        end

        for _, buffer in ipairs(to_delete) do
            vim.api.nvim_buf_delete(buffer, {})
        end
    end
end

module.events.subscribed = {
    ["cmd"] = {
        ["return"] = true,
    },
}

return module
