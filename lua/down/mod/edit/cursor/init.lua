local L = Mod.create("edit.cursor")
local tu = require("nvim-treesitter.ts_utils")

function L.setup()
  return {
    requires = {
      "tool.treesitter",
      "workspace",
    },
    loaded = true,
  }
end

---@class down.edit.cursor.Config
L.config = {}

---@class down.edit.cursor.Data
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
}
---@class edit.cursor.Node
L.data.node = {}
function L.data.node:captures()
  return require("vim.treesitter").get_captures_at_cursor(0)
end

---@return table
function L.data.node:lspRange()
  ---@diagnostic disable-next-line
  return tu.node_to_lsp_range(self.get())
end

---@param switch boolean: switch parent
---@param nextParent boolean: nextParent parent
---@return TSNode|nil
function L.data.node:next(switch, nextParent)
  ---@diagnostic disable-next-line
  return tu.get_next_node(self.get(), switch or true, nextParent or true)
end

---@param switch boolean: switch parent
---@param prevParent boolean: nextParent parent
---@return TSNode|nil
function L.data.node:prev(switch, prevParent)
  ---@diagnostic disable-next-line
  return tu.get_previous_node(self.get(), switch or true, prevParent or true)
end

---@return string[]
function L.data.node:text()
  ---@diagnostic disable-next-line
  return tu.get_node_text(self.get(), 0)
end

---@return TSNode|nil
function L.data.node.get()
  local n = tu.get_node_at_cursor(0, nil)
  ---@diagnostic disable-next-line
  setmetatable(n, { __index = n, __call = L.data.node.get() })
  return n
end

---@return TSNode
function L.data.node:root()
  ---@diagnostic disable-next-line
  return tu.get_root_for_node(self.get())
end

---@return ...
function L.data.node:range()
  ---@diagnostic disable-next-line
  return tu.get_vim_range(self.get(), 0)
end

---@param ns? string: namespace
---@param hgroup? string: hilite group
---@return nil
function L.data.node:hl(ns, hgroup)
  ---@diagnostic disable-next-line
  return tu.highlight_node(self.get(), 0, ns, hgroup)
end

return L
