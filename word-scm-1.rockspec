rockspec_format = "3.0"
package = "word.lua"
version = "0.1.0"
source = {
  url = "git://github.com/clpi/word.lua",
  tag = nil
}

description = {
  summary = "Extensibility for everyone",
  detailed = [[
    org for markdown for neovim
  ]],
  description = [[
    extensibility of org without the hassle of another syntax
  ]],
  homepage = "word.cli.st",
  maintainer = "github.com/clpi",
  labels = { "wiki", "plugin", "neovim", "notes", "markdown" },
  homepage = "https://github.com/clpi/word.lua",
  labels = {
    "wiki", "neovim", "notes", "org", "markdown"
  },
  license = "MIT",
}

dependencies = {
  "lua == 5.1",
  "nvim-nio ~> 1.7",
  "plenary.nvim == 0.1.4",
  "nui.nvim == 0.3.0",
  "pathlib.nvim ~> 2.2",
}

source = {
  url = "http://github.com/clpi/word.lua/archive/v" .. MODREV .. ".zip",
}

if MODREV == "scm" then
  source = {
    url = "git://github.com/clpi/word.lua",
  }
end

test_dependencies = {
  "nlua",
  -- Placed here as we plan on removing nvim-treesitter as a dependency soon, but it's still required for various tests.
  "nvim-treesitter == 0.9.2",
}

test = {
  type = "command",
  command = "scripts/test.sh"
}

build = {
  type = "builtin",
  copy_directories = {
    "queries",
    "doc",
  }
}
