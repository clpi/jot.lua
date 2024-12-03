Map = {}

-- local vim = require("vim")

Map.km = vim.keymap.set

Map.nsk = vim.api.nvim_set_keymap

---@param cmd string | function
---@param opts? vim.keymap.set.Opts
---@return vim.keymap.set.Opts
Map.dopt = function(cmd)
  local cs = ""
  if type(cmd) == "string" then
    cs = cmd
  else
    cs = ""
  end
  return {
    desc = cs,
    silent = true,
    nowait = true,
    noremap = false,
  }
end

---@param key string the keys
---@param cmd string | function the command
---@param opts? vim.keymap.set.Opts the description
Map.nmap = function(key, cmd, opts)
  opts = opts or Map.dopt(cmd)
  Map.km("n", key, cmd, opts)
end

---@param key string the keys
---@param cmd string | function the command
---@param opts? vim.keymap.set.Opts the description
Map.nimap = function(key, cmd, opts)
  opts = opts or Map.dopt(cmd)
  Map.km({ "n", "i" }, key, cmd, opts)
end

Map.nbuf = function(buf, key, cmd, desc) end

return Map
