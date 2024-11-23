local M = require('word.mod').create('data.meta')

M.setup = function()
  return {
    success = true,
    required = {
      'workspace',
      'data',
    },
  }
end

M.load = function()
end

M.config.public = {
  fields = {

  },
}

return M
