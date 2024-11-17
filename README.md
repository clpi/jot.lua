# word - the _familiar_, organized future for neovim

<a href="https://neovim.io"> ![Neovim](https://img.shields.io/badge/Neovim%200.10+-brightgreen?style=for-the-badge) </a>
<a href="/LICENSE"> ![License](https://img.shields.io/badge/license-GPL%20v3-brightgreen?style=for-the-badge)</a>
[![Push to Luarocks](https://github.com/clpi/word.lua/actions/workflows/luarocks.yml/badge.svg)](https://github.com/clpi/word.lua/actions/workflows/luarocks.yml)
[![Deploy mdBook site to Pages](https://github.com/clpi/word.lua/actions/workflows/book.yml/badge.svg)](https://github.com/clpi/word.lua/actions/workflows/book.yml)
![LuaRocks](https://img.shields.io/luarocks/v/clpi/word.lua)

---

`for neovim 0.10+`

## Introduction

**word** is a plugin meant to bring the awesome extensibility of emacs [org-mode] or [neorg] without needing to switch from the gold standard [markdown], or from the best editor [neovim].

- we want to be able to take notes like developers, without shutting ourselves out of the entire ecosystem built around markdown.

- it's a work in progress with an initial project structure based on the structure of neorg, and will be updated regularly

## Requirements

- must have at least [neovim 0.10+](https://neovim.io)

## Quickstart

<details open>
  <summary>
lazy.nvim
  </summary>

```lua
{
    "clpi/word.lua",
    lazy    = false,
    version = false,
    config  = true,
    branch = "master",
    opts = {},
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-nio",
      "pathlib.nvim",
      "plenary-nvim",
    }
}
```

</details>

---

<details>

  <summary>
plug.vim
  </summary>

```vim
Plug "nvim-telescope/telescope.nvim"
Plug 'MunifTanjim/nui.nvim'
Plug "clpi/word.lua", {
    \ "branch" : "main",
    \ "do"     : ":lua require('word').setup()"
    \ }
```

</details>

---

<details>
<summary>Vundle</summary>

```vim
  Plugin 'nvim-telescope/telescope.nvim'
  Plugin 'MunifTanjim/nui.nvim'
  Plugin 'renerocksai/telekasten.nvim'
```

</details>

---

<details>

  <summary>
dein.vim
  </summary>

```vim
call dein#add('MunifTanjim/nui.nvim')
call dein#add('nvim-telescope/telescope.nvim')
call dein#add('clpi/word.lua')
```

</details>

---

<details>

  <summary>
packer.nvim
  </summary>

```lua
use {
  "clp",
  rocks = {
        "nvim-telescope/telescope.nvim",
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

</details>

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
- [ ] **Support [blink-cmp] and** [nvim-cmp] and [magazine-cmp] when possible

## Support

check back!

## Credits

`word.lua` is a project by [clpi](github.com/clpi) and is licensed under the [MIT](./LICENSE) license. For information about **contributing**, please consult the [CONTRIBUTING.md](./CONTRIBUTING.md) file.

special thanks goes to [nvim-neorg/neorg](https://github.com/nvim-neorg/neorg) for providing the inspiration and basis of this project.

thank you and keep updated!

- [The word book](https://word.cli.st)
- [word.lua on luarocks](https://luarocks.org/inits/clpi/word.lua)
- [word.lua on dotfyle](https://dotfyle.com/plugins/clpi/word.lua)

<!-- <div align="center"> -->
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- </div> -->
