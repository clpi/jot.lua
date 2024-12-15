local P = Mod.create("edit.parse.tag")

P.setup = function()
  return {
    loaded = true
  }
end

---@class down.edit.parse.tag.Config
P.config = {}

---@class down.edit.parse.tag.Data
P.data = {}

return P
