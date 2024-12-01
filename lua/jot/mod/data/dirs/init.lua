local D = Mod.create("data.dirs")

local path = require("plenary.path")
local Path = require("pathlib")

local stdp = vim.fn.stdpath
local uv = vim.uv or vim.loop

D.private = {
  get_mkfile = function(file)
    local f = path:new(file)
    if not f:exists() or f:is_dir() then
      file:touch()
    end
    return file
  end,
  get_mkdir = function(dir)
    local d = path:new(dir)
    if not d:exists() or d:is_file() then
      dir:mkdir()
    end
    return dir
  end
}

D.setup = function()
  return {
    requires = {
      'workspace'
    },
    success = true
  }
end

D.load = function()
end

D.config.public = {
  vim = {
    data = vim.fn.stdpath('data'),
    config = vim.fn.stdpath('config'),
    cache = vim.fn.stdpath('cache'),
    state = vim.fn.stdpath('state'),
    run = vim.fn.stdpath("run"),
    log = vim.fn.stdpath("log"),
  }
}

D.public = {
  user = {

  },
  jot = {
    config = {
      data = vim.fn.stdpath('data'),
      config = vim.fn.stdpath('config'),
      cache = vim.fn.stdpath('cache'),
      state = vim.fn.stdpath('state'),
      run = vim.fn.stdpath("run"),
      log = vim.fn.stdpath("log"),
    }

  },
  vim = {
    data = vim.fn.stdpath('data'),
    config = vim.fn.stdpath('config'),
    cache = vim.fn.stdpath('cache'),
    state = vim.fn.stdpath('state'),
    run = vim.fn.stdpath("run"),
    log = vim.fn.stdpath("log"),
  }

}

D.on_event = function(e)

end


return D
