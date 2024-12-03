local MODREV, SPECREV = "scm", "-1"
local account = "clpi"
local repo = "word.lua"
rockspec_format = "3.0"
package = "word.lua"
version = MODREV .. SPECREV

source = {
  url = "git://github.com/" .. account .. "/" .. repo .. ".git",
  branch = "master",
  version = "0.1.0-alpha",
  tag = "0.1.0-alpha",
}

description = {
  summary = "Extensibility of org, comfort of markdown, for everyone",
  package = "word.lua",
  issues_url = "https://github.com/clpi/word.lua/issues",
  version = "0.1.0-alpha",
  detailed = [[
    Extensibility of org, comfort of markdown, for everyone
  ]],
  description = [[
    Extensibility of org, comfort of markdown, for everyone
  ]],
  homepage = "https://github.com/clpi/word.lua",
  maintainer = "https://github.com/clpi",
  labels = {
    "wiki",
    "neovim",
    "note",
    "org",
    "markdown",
    "nvim",
    "telekasten",
    "plugin",
    "org-mode",
  },
  license = "MIT",
}

if MODREV == "scm" then
  source = {
    url = "git://github.com/clpi/word.lua",
    tag = nil,
    branch = "master",
  }
end

dependencies = {
  "lua == 5.4",
  "pathlib.nvim ~> 2.2",
  "nvim-nio ~> 1.7",
  "plenary.nvim == 0.1.4",
  "nui.nvim == 0.3.0",
}

test_dependencies = {
  "nlua",
  "nvim-treesitter == 0.9.2",
}

test = {
  type = "command",
  command = "make test",
}
--
deploy = {
  wrap_bin_scripts = true,
}

build = {
  type = "builtin",
  build_pass = false,
  modules = {},
  install = {
    bin = {
      wordls = "scripts/bin/wordls",
      word_lsp = "scripts/bin/word-lsp",
      word = "scripts/bin/word",
    },
  },
  copy_directories = {
    "queries",
    "plugin",
    "doc",
  },
}
--vim:ft=lua
