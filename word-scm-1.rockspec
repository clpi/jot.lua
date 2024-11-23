local MODREV, SPECREV = "scm", "-1"
rockspec_format = "3.0"
package = "word.lua"
version = MODREV .. SPECREV
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
  homepage = "https://github.com/clpi/word.lua",
  maintainer = "https://github.com/clpi",
  labels = {
    "wiki", "neovim", "note", "org", "markdown", "nvim", "plugin", "org-mode",
  },
  license = "MIT",
}

if MODREV == "scm" then
  source = {
    url = "git://github.com/clpi/word.lua",
    tag = nil,
    branch = "master"
  }
end

dependencies = {
  "lua == 5.1",
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
      "scripts/bin/word",
    }
  },
  copy_directories = {
    "doc",
  }
}
--vim:ft=lua
