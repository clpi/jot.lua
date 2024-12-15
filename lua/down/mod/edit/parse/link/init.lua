local P = Mod.create("edit.parse.link")

P.setup = function()
  return {
    loaded = true
  }
end

---@class down.edit.parse.link.Config
P.config = {}
---@class down.edit.parse.link.Data
P.data = {}

return P
