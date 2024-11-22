# word - the _familiar_, organized future for neovim

<a href="https://neovim.io"> ![Neovim](https://img.shields.io/badge/Neovim%200.10+-brightgreen?style=for-the-badge) </a>
<a href="/LICENSE"> ![License](https://img.shields.io/badge/license-GPL%20v3-brightgreen?style=for-the-badge)</a>
![LuaRocks](https://img.shields.io/luarocks/v/clpi/word.lua)

---

> [!Warning]
>
> `word.lua` is **BEGINNING DEVELOPMENT**

<!--toc:start-->

- [word - the _familiar_, organized future for neovim](#word-the-familiar-organized-future-for-neovim)
  - [Introduction](#introduction)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
  - [Config](#config)
  - [Usage](#usage)
  - [Todo](#todo)
  - [Support](#support)
  - [Credits](#credits)
  <!--toc:end-->


## Introduction

- **word.lua** is a [neovim] plugin intended to bring the extensibility of [org-mode] or [neorg] in the comfort of [markdown].

- we want to be able to take notes like developers, without shutting ourselves out of the entire ecosystem built around markdown.

- it's a work in progress with an initial project structure based on the structure of neorg, and will be updated regularly

## Requirements

> [!Note]
>
> `word.lua` must have at least [neovim 0.10+](https://neovim.io)

## Quickstart

<details open>
  <summary>
<a href="#">lazy.nvim</a>
  </summary>

```lua
{
    "clpi/word.lua",
    lazy    = false,
    config  = true,
    version = "*"
    branch  = "master",
    build   = ":TSUpdate markdown markdown_inline",
    config = function(_, opts)
      require("word").setup({
        mod = {
          workspace = {
            config = {
              workspaces = {
                notes = "~/notes"
              }
            }
          }
        }
      })
    end,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-neotest/nvim-nio",
      "pysan3/pathlib.nvim",
      "nvim-lua/plenary-nvim",
    }
}
```

</details>

---

<details>

  <summary>
<a href="#">plug.vim</a>
  </summary>

> [!Warning]
>
> Not yet tested

```vim
Plug "nvim-telescope/telescope.nvim"
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-lua/plenary-nvim'
Plug "pysan3/pathlib.nvim"
Plug "nvim-neotest/nvim-nio"
Plug "clpi/word.lua", {
    \ "branch" : "master",
    \ "do"     : ":lua require('word').setup()"
    \ }
```

</details>

---

<details>
<summary><a href="#">Vundle</a></summary>

> [!Warning]
>
> Not yet tested

```vim
Plugin 'nvim-lua/plenary-nvim'
Plugin "pysan3/pathlib.nvim"
Plugin "nvim-neotest/nvim-nio"
Plugin 'nvim-telescope/telescope.nvim'
Plugin 'MunifTanjim/nui.nvim'
Plugin 'clpi/word.lua'
```

</details>

---

<details>

  <summary>
<a href="#">dein.vim</a>
  </summary>

> [!Warning]
>
> Not yet tested

```vim
call dein#add('pysan3/pathlib.nvim')
call dein#add('nvim-neotest/nvim-nio')
call dein#add('MunifTanjim/nui.nvim')
call dein#add('nvim-telescope/telescope.nvim')
call dein#add('clpi/word.lua')
```

</details>

---

<details>

  <summary>
<a href="#">packer.nvim</a>
  </summary>

> [!Warning]
>
> Not yet tested

```lua
use {
  "clp/word.lua",
  requires = {
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

---

<details>

  <summary>
<a href="#">mini.deps</a>
  </summary>

> [!Warning]
>
> Not yet tested

```lua
{
  "clp/word.lua",
}
```

</details>

---

<details>

  <summary>
<a href="#">rocks.nvim</a>
  </summary>

> [!Warning]
>
> Not yet tested

```lua
Rocks install mini.lua
```

</details>

## Config

```lua
-- Setup the initial config
require("word").setup({})

```

## Usage

Check back!

## Todo

> [!Tip]
>
> Check out [TODO.md](./TODO.md) for a more detailed list of tasks

## Support

check back!

## Credits

`word.lua` is a project by [clpi](github.com/clpi) and is licensed under the [MIT](./LICENSE) license. For information about **contributing**, please consult the [CONTRIBUTING.md](./CONTRIBUTING.md) file.

special thanks goes to [nvim-neorg/neorg](https://github.com/nvim-neorg/neorg) for providing the inspiration and basis of this project.

thank you and keep updated!

- [The `word.lua` book](https://word.cli.st)
- [`word.lua` on luarocks](https://luarocks.org/inits/clpi/word.lua)
- [`word.lua` on dotfyle](https://dotfyle.com/plugins/clpi/word.lua)

<!-- <div align="center"> -->
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- </div> -->
