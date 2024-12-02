# word - the _familiar_, organized future for neovim

<a href="https://neovim.io"> ![Neovim](https://img.shields.io/badge/Neovim%200.10+-brightgreen?style=for-the-badge) </a>
<a href="/LICENSE"> ![License](https://img.shields.io/badge/license-GPL%20v3-brightgreen?style=for-the-badge)</a>
![LuaRocks](https://img.shields.io/luarocks/v/clpi/word.lua)

---

> [!Important]
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

- `word.lua` is a [neovim](#) plugin intended to bring the extensibility of [org-mode](#) or [neorg](github.com/nvim-neorg/neorg) with the **comfort** of [markdown](#).

- In its [current state](#), `word.lua` is in the beginning stages of development, currently functionining as a markdown-based version of [neorg](#), with many planned features to come

- we want to be able to take notes like developers, without leaving behind all the ecosystem benefits of markdown.

- it's a work in progress and will be updated regularly

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
    version = "*"
    branch  = "master",
    config = function(_, opts)
      require("word").setup({
        mods = {
          config = {},
          workspace = {
            config = {
              workspaces = {
                default = "~/word",
                notes = "~/notes"
              }
            }
          }
        }
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "pysan3/pathlib.nvim",
      "nvim-telescope/telescope.nvim", -- optional
    }
}
```

</details>

---

<details>

  <summary>
<a href="#">plug.vim</a>
  </summary>

> [!Caution]
>
> Not yet tested

```vim
Plug "nvim-telescope/telescope.nvim"
Plug "nvim-treesitter/treesitter.nvim"
Plug "nvim-lua/plenary.nvim",
Plug "MunifTanjim/nui.nvim",
Plug "pysan3/pathlib.nvim"
Plug "clpi/word.lua", {
    \ "branch" : "master",
    \ "do"     : ':lua require([[word]]).setup({
    \   mods = {
    \     config = {},
    \     workspace = {
    \       config = {
    \         workspaces = {
    \           default = [[~/wiki]],
    \           notes = [[~/notes]]
    \         }
    \       }
    \     }
    \   }
    \ })'
    \ }
```

</details>

---

<details>
<summary><a href="#">Vundle</a></summary>

> [!Caution]
>
> Not yet tested

```vim
Plugin "pysan3/pathlib.nvim"
Plugin 'nvim-telescope/telescope.nvim'
Plugin "nvim-lua/plenary.nvim",
Plugin "MunifTanjim/nui.nvim",
Plugin 'clpi/word.lua'
```

</details>

---

<details>

  <summary>
<a href="#">dein.vim</a>
  </summary>

> [!Caution]
>
> Not yet tested

```vim
call dein#add("nvim-lua/plenary.nvim")
call dein#add("MunifTanjim/nui.nvim")
call dein#add('pysan3/pathlib.nvim')
call dein#add('nvim-telescope/telescope.nvim')
call dein#add('clpi/word.lua')
```

</details>

---

<details>

  <summary>
<a href="#">packer.nvim</a>
  </summary>

> [!Caution]
>
> Not yet tested

```lua
use {
  "clp/word.lua",
  requires = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "pysan3/pathlib.nvim"
  },
  tag = "*",
  branch = 'master',
  config = function()
      require("word").setup({
        mods = {
          config = {},
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
}
```

</details>

---

<details>

  <summary>
<a href="#">mini.deps</a>
  </summary>

> [!Caution]
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

> [!Caution]
>
> Not yet tested

```
:Rocks install mini.lua
```

</details>

## Config

```lua
-- Setup the initial config
-- with workspace 'home' at ~/home
-- and make it default
require("word").setup({
  mods = {
    config = {},
    workspace = {
      config = {
        default = 'home',
        workspaces = {
          notes = "~/notes",
          home = "~/notes"
        }
      }
    }
  }
})
```

## Usage

> [!Note]
>
> Still early on in development!

### Modules

- `config` - configuration settings

### Default Modules

- `workspace` for managing workspaces
- `notes` for managing notes
- `data` for managing data
  - `data.tag` for managing tags
  - `data.meta` for managing metadata
  - `data.sync` for managing sync
  - `data.log` for managing logs
  - `data.dirs` for managing directories
  - `data.snippets` for snippets
- `ui` for ui actions
  - `ui.popup` for popup windows
  - `ui.chat` for chat services
  - `ui.win` for window creation
- `lsp` for lsp services
  - `lsp.completion` for completion
  - `lsp.format` for formatting
  - `lsp.actions` for codeactions
  - `lsp.lens` for codelens
- `links` for managing links
-

`...`

## Todo

> [!Tip]
>
> Check out [TODO.md](./TODO.md) for a more detailed list of tasks

## Support

> [!Note]
>
> Still early on in development!

## Credits

`word.lua` is a project by [clpi](github.com/clpi) and is licensed under the [MIT](./LICENSE) license. For information about **contributing**, please consult the [CONTRIBUTING.md](./CONTRIBUTING.md) file.

special thanks goes to [nvim-neorg/neorg](https://github.com/nvim-neorg/neorg) for providing the inspiration and basis of this project.

---

thank you and keep updated!

- [The `word.lua` book](https://word.cli.st)
- [The `word.lua` wiki](https://github.com/clpi/word.lua/wiki)
- [`word.lua` on luarocks](https://luarocks.org/inits/clpi/word.lua)
- [`word.lua` on dotfyle](https://dotfyle.com/plugins/clpi/word.lua)

<!-- <div align="center"> -->
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- </div> -->

```

```
