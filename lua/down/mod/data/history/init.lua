---@class type.Mod
local M = require "down.mod".new("data.history", {

})

M.config = {
  silent = true,
}

---@class down.data.history.Data
M.data = {


  --- Buffer queue
  --- @type table<number, integer>
  history = {},

  --- @type table<number, integer>
  buf = {},

}


M.data.push = function(stack, buf)
  table.insert(stack or M.data.buf, 1, buf or vim.api.nvim_get_current_buf())
end

M.data.pop = function(stack, buf)
  table.remove(stack or M.data.buf, 1)
end

M.data.print = function(self)
  for i, v in ipairs(self) do
    print(i, v.path, v.buf)
  end
end

M.data.back = function()
  local bn = vim.api.nvim_get_current_buf()
  if bn > 1 and #M.data.buf > 0 then
    M.data.push(M.data.history, bn)
    local prev = M.data.buf[1]
    vim.api.nvim_command("buffer " .. prev)
    M.data.pop(M.data.buf)
    return true
  else
    if M.config.silent then
      vim.api.nvim_echo({ { "Can't go back again", "WarningMsg" } }, true, {})
    end
    return false
  end
end

M.data.forward = function()
  local cb = vim.api.nvim_get_current_buf()
  local hb = M.data.history[1]
  if hb then
    M.data.push(M.data.buf, cb)
    vim.api.nvim_command("buffer " .. hb)
    M.data.pop(M.data.history)
    return true
  else
    if not M.config.silent then
      vim.api.nvim_echo({ { "Can't go forward again", "WarningMsg" } }, true, {})
    end
    return false
  end
end


---@alias down.data.history.Store down.Store Store
---@type down.data.history.Store Store
M.data.store = {


}

---@class down.data.history.Config
M.config = {

  store = "data/stores"

}

---@return down.mod.Setup
M.setup = function()
  ---@type down.mod.Setup
  return {
    requires = {

    },
    loaded = true,
  }
end


return M