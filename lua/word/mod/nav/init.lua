local N = Mod.create('nav')

N.setup = function()
  return {
    success = true,
    requires = {
      'data'
    }
  }
end

---@class nav
M.public = {
  data = M.required["data"],
  stack = {

  },
  hist = {

  }

}

M.load = function()
  2
end

return N
