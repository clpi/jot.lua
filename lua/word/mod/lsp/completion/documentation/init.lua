local D = require("word.mod").create("lsp.completion.documentation")

D.setup = function()
  return {
    loaded = true,
  }
end

return D
