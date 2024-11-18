rockspec_format = "3.0"
package = "word.lua"
version = "0.1.0-alpha.1"
source = {
  url = "git://github.com/clpi/word.lua",
  tag = nil
}

description = {
  summary = "Extensibility of org, comfort of markdown, for everyone",
  detailed = [[
    Extensibility of org, comfort of markdown, for everyone
  ]],
  description = [[
    Extensibility of org, comfort of markdown, for everyone
  ]],
  homepage = "https://word.cli.st",
  maintainer = "https://github.com/clpi",
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

test_dependencies = {
  "nlua",
  "nvim-treesitter == 0.9.2",
}

-- test = {
--   type = "command",
--   command = "scripts/test.sh"
-- }

build = {
  type = "builtin",
  install = {
    bin = {
      "bin/word",
    }
  },
  copy_directories = {
    "doc",
  }
}
