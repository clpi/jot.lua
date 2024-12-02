local L = Mod.create("edit.cursor")
local tu = require("nvim-treesitter.ts_utils")

function L.setup()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class edit.cursor.Data
---@field public node TSNode|nil
---@field public text string[]
---@field public prev TSNode|nil
---@field public next TSNode|nil
---@field public root function|TSNode
---@field public children TSNode[]
---@field public captures function|string[]
---@field public range ...
---@field public lspRange table
---@field public hl nil
L.data = {
  ---@return string[]
  captures = function()
    return vim.treesitter.get_captures_at_cursor(0)
  end,
}

---@return table
L.data.lspRange = function()
  ---@type TSNode
  ---@diagnostic disable-next-line
  local n = L.data.node()
  return tu.node_to_lsp_range(n)
end
---@param switch boolean: switch parent
---@param nextParent boolean: nextParent parent
---@return TSNode|nil
L.data.next = function(switch, nextParent)
  ---@type TSNode
  ---@diagnostic disable-next-line
  local n = L.data.node()
  return tu.get_next_node(n, switch or true, nextParent or true)
end
---@param switch boolean: switch parent
---@param prevParent boolean: nextParent parent
---@return TSNode|nil
L.data.prev = function(switch, prevParent)
  ---@type TSNode
  ---@diagnostic disable-next-line
  local n = L.data.node()
  return tu.get_previous_node(n, switch or true, prevParent or true)
end
---@return string[]
L.data.text = function()
  ---@type TSNode
  ---@diagnostic disable-next-line
  local n = L.data.node()
  return tu.get_node_text(n, 0)
end
---@return TSNode|nil
L.data.node = function()
  return tu.get_node_at_cursor(0, nil)
end
---@return TSNode
L.data.root = function()
  ---@type TSNode
  ---@diagnostic disable-next-line
  local n = L.data.node()
  return tu.get_root_for_node(n)
end

---@return ...
L.data.range = function()
  ---@type TSNode
  ---@diagnostic disable-next-line
  local n = L.data.node()
  return tu.get_vim_range(n, 0)
end

---@param ns? string: namespace
---@param hgroup? string: hilite group
---@return nil
L.data.hl = function(ns, hgroup)
  ---@type TSNode
  ---@diagnostic disable-next-line
  local n = L.data.node()
  return tu.highlight_node(n, 0, ns, hgroup)
end

return L
