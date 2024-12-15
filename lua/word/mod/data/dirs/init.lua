local D = Mod.create("data.dirs")

local Path = require("pathlib")
local path = require("plenary.path")

local stdp = vim.fn.stdpath
local uv = vim.uv or vim.loop

D.setup = function()
  return {
    requires = {
      "workspace",
    },
    loaded = true,
  }
end

---@class word.data.dirs.Config
D.config.public = {
  vim = {
    data = vim.fn.stdpath("data"),
    config = vim.fn.stdpath("config"),
    cache = vim.fn.stdpath("cache"),
    state = vim.fn.stdpath("state"),
    run = vim.fn.stdpath("run"),
    log = vim.fn.stdpath("log"),
  },
}

---@class word.data.dirs.Data
D.data = {
  user = {},
  word = {
    config = {
      data = vim.fn.stdpath("data"),
      config = vim.fn.stdpath("config"),
      cache = vim.fn.stdpath("cache"),
      state = vim.fn.stdpath("state"),
      run = vim.fn.stdpath("run"),
      log = vim.fn.stdpath("log"),
    },
  },
  vim = {
    data = vim.fn.stdpath("data"),
    config = vim.fn.stdpath("config"),
    cache = vim.fn.stdpath("cache"),
    state = vim.fn.stdpath("state"),
    run = vim.fn.stdpath("run"),
    log = vim.fn.stdpath("log"),
  },
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
  end,
}

D.on = function(e) end

return D
