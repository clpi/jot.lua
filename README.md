# word - the _familiar_, organized future for neovim

<a href="https://neovim.io"> ![Neovim](https://img.shields.io/badge/Neovim%200.10+-brightgreen?style=for-the-badge) </a>
<a href="/LICENSE"> ![License](https://img.shields.io/badge/license-GPL%20v3-brightgreen?style=for-the-badge)</a>
[![Push to Luarocks](https://github.com/clpi/word.lua/actions/workflows/luarocks.yml/badge.svg)](https://github.com/clpi/word.lua/actions/workflows/luarocks.yml)
[![Deploy mdBook site to Pages](https://github.com/clpi/word.lua/actions/workflows/book.yml/badge.svg)](https://github.com/clpi/word.lua/actions/workflows/book.yml)
![LuaRocks](https://img.shields.io/luarocks/v/clpi/word.lua)

---

`for only neovim currently, not vim`
`for neovim 0.10+`

## Introduction

- **word** is a plugin meant to bring the awesome extensibility of emacs [org-mode] or [neorg] without needing to switch from the gold standard [markdown], or from the best editor [neovim].

- we want to be able to take notes like developers, without shutting ourselves out of the entire ecosystem built around markdown.

- it's a work in progress with an initial project structure based on the structure of neorg, and will be updated regularly

## Requirements

- [neovim 0.10+](https://neovim.io)

## Install

### lazy.nvim

```lua
{
    "clpi/word.lua",
    lazy    = false,
    version = false,
    config  = true,
    opts = {},
}
```

---

### plug.vim

```vim
Plug "clpi/word.lua", {
    \ "branch" : "main",
    \ "do"     : ":lua require('word').setup()"
    \ }
```

---

### packer.nvim

```lua
use {
  "clp",
  rocks = {
        "nvim-nio",
        "nui.nvim",
        "plenary.nvim",
        "pathlib.nvim"
  },
  tag = "*",
  config = function()
      require("word").setup()
  end,
}
```

## Config

check back!

## Usage

check back!

## Todo

- [ ] Bring at least a few scaffolded modules to functionality 
- [ ] Automate flake creation through GH Actions
- [ ] Fix rudimentary commands ported over to bring to base functionality
- [ ] Once at base functionality, clean up and refactor to bring to a `0.1.0` release
- [ ] Allow optional choice of telescope or not
- [ ] Add other package manager support

## Support

check back!

## Credits

thank you and keep updated!

- [The word book](https://word.cli.st)
- [word.lua on luarocks](https://luarocks.org/inits/clpi/word.lua)
- [word.lua on dotfyle](https://dotfyle.com/plugins/clpi/word.lua)

<!-- <div align="center"> -->

<!-- </div> -->
