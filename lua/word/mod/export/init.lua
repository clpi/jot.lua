local E = Mod.create("export")

E.setup = function()
  return {
    success = true,
    requires = {
      "integration.treesitter",
      "data"
    }
  }
end

E.load = function()

end

return E
