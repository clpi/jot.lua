# dorm - the _familiar_, organized future for neovim

<a href="https://neovim.io"> ![Neovim](https://img.shields.io/badge/Neovim%200.10+-brightgreen?style=for-the-badge) </a>
<a href="/LICENSE"> ![License](https://img.shields.io/badge/license-GPL%20v3-brightgreen?style=for-the-badge)</a>
---
`for neovim 0.10+`

## Introduction

- **dorm** is a plugin meant to bring the awesome extensibility of emacs [org-mode] or [neorg] without needing to switch from the gold standard [markdown], or from the best editor [neovim].

- we want to be able to take notes like developers, without shutting ourselves out of the entire ecosystem built around markdown.

- it's a work in progress with an initial project structure based on the structure of neorg, and will be updated regularly

## Install

### lazy.nvim

```lua
{
    "clpi/dorm.lua",
    lazy    = false,
    version = false,
    config  = true,
}
```

---

### plug.vim

```vim
Plug "clpi/dorm.lua", {
    \ "branch" : "main",
    \ "do"     : ":lua require('dorm').setup()"
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
      require("dorm").setup()
  end,
}
```

## Config

check back!

## Usage

check back!

## Support

check back!

## Credits

thank you and keep updated!

- [The Dorm book](https://dorm.cli.st)
- [dorm.lua on luarocks](https://luarocks.org/modules/clpi/dorm.lua)

<!-- <div align="center"> -->

<!-- </div> -->
