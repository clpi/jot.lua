std = luajit
cache = true
codes = true
self = false

exclude_files = {
  "_neovim/*",
  "_runtime/*"
}

read_globals = {
  "vim"
}
-- Global objects
globals = {
  "_",
  "vim",
  "word",
  "log",
}

std = "max+busted"

ignore = {
  "631", -- max_line_length
  "212",
  "122"
}
