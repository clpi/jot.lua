local D = require("word.mod").create("data.dirs")

D.setup = function()
  return {
    success = true
  }
end

D.public = {
  data = vim.fn.stdpath('data'),
  config = vim.fn.stdpath('config'),
}

D.config.public = {
  data = vim.fn.stdpath('data'),
  config = vim.fn.stdpath('config'),
}

return D
