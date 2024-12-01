# TODO

- [x] Get heading indentation to work
- [ ] **prepare for official org initial release**
- [ ] Bring at least a few scaffolded modules to functionality
- [ ] Automate flake creation through GH Actions
- [ ] load commands on filetype/workspace load
- [ ] Fix rudimentary commands ported over to bring to base functionality
- [ ] Once at base functionality, clean up and refactor to bring to a `0.1.0` release
- [ ] Allow optional choice of telescope or not
- [ ] Add other package manager support
- [ ] **Support [blink-cmp] and** [nvim-cmp] and [magazine-cmp] when possible
- [ ] Support `rst`, limited `.txt` and `md`?
- [ ] _IMPORTANT_ Remove `pathlib.nvim` dependency
- [ ] `mod` encrypt, export, track, metadata
- [ ] Create release workflow
- [ ] Update `CHANGELOG.md` and `README.md` as necessary
- [ ] find out reason for delay upon save `(11/24 21:31)`

---

## For next version

- [ ] [cmd] Make the following subcommands functional:
  - `...`
- [ ] Remove the following subcommands:
  - `...`
- [ ] Remove utf-16 encoding
- [ ] Remove unneeded server capabilities for lsp
  - [ ] `textDocument/diagnostics`
- [ ] Add treesitter queries for:
  - [ ] `tag`s
  - [ ] `todo`s
  - [ ] wikilinks
  - [ ] `url`s
  - [ ] `timestamp`s
- [ ] Concaelment and syntax highlighting like `render-markdown`
- [ ] `tag` support and `todo` support `treesitter` queries
- [ ] `timestamp` insertion, add autoinsert/conceal timestamp functionality `?`
- [ ] natural language date parsing for todos

- - -

## Todo specifications

### Commands

- [ ] `cmd`: add a new custom command
- [ ] `mod`: add a new module
- [ ] `note`: note functionality:
  - [ ] `note.book`: [telescope] note books
- [ ] `preview`: preview current file in browser
- [ ] `tag`: tag functionality
- [ ] `find`: telescope/fzf sugar functionality
- [ ] `log`: deal with logging (not debug)/tracking/variable functionalitY
  - [ ] `log.new`: add a new log to capture/save to
  - [ ] `log.add`: append a new log entry to ? the default log : telescope
- [ ] `save`: save some piece of media to store
  - [ ] `save`: _root_ save the current file
- [ ] `load`: load a file saved
- [ ] `template`: template functionality
- [ ] `snippet`: snippet functionality
- [ ] `debug`: for development purpose
- [ ] `encrypt`: encrypt (lock/unlock?) a workspace/file

---

#### Maybes

- [ ] `var`: var functionality `?`
- [ ] `clipboard`: interaction `?`

- [ ] `refactor` like functionality

---

### LSP

- [ ] `textDocument/inalyHint`: inlay hints
- [ ] `textDocument/definition`: definition

- [ ] `textDocument/rename`: rename
- [ ] `textDocument/hover`: hover
- [ ] `textDocument/completion`: completion
- [ ] `textDocument/codeAction`: code action
- [ ] `textDocument/documentSymbol`: document symbol

### Modules

- [ ] `book`: book functionality
- [ ] `tag`: tag functionality
- [ ] `ai`: ai functionality
- [ ] `mod`: module customization/creation
- [ ] `config`: configuration by command/loading
- [ ] `map`: keymap by command/loading

### CLI

- [ ] `sh`: shell/repl functionality
- [ ] `workspace`: workspace customization/adding/loading

### Treesitter

- [ ] `tag` queries
- [ ] `todo` queries
- [ ] `code` queries
- [ ] `url` queries

- [ ] `illuminate` like highlighting
- [ ] `conceal` functionality

```lua
-- enable on setup
require("nvim-treesitter.configs").setup({
  conceal = {
    enable = true,
    ensure_installed = {
      "markdown", "markdown_inline"
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = true
    },
    conceal_characters = {
      ["*"] = "•",  -- * list chars
      ["[ ]"] = "□" -- todo unchecked
      "[x]"] = "✓"
    }

  }
})

```

### External

- [ ] `vscode` extension

## For future versions

### Miscellaneous

- [ ] notebook/jupyter support `(11/24 21:35)`
- [ ] performance profile
- [ ] add capture ui, `popup` or `sidebar`
- [ ] `telescope` and `blink.cmp` support/`magazine`
- [ ] `context` support/scope recognition
- [ ] `code fragment` evaluation and inline display

### One day

- [ ] automatic tag generation / document scanning

### Maybe

- [ ] `...`
- [ ] Scope indentation?
- [ ] `.wd` [jot] syntax support/hl
