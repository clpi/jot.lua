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

return M
