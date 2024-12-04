---@meta
---
--- @alias word.mod.Data { [any]: any }

--- @class (exact) word.config.Mods
--- @field ['lsp.document']? lsp.document.Data
--- @field ['lsp.workspace']? lsp.workspace.Data
--- @field ['lsp.completion']? lsp.completion.Data
--- @field ['lsp.actions']? lsp.actions.Data
--- @field ['lsp.command']? lsp.command.Data
--- @field ['lsp.hint']? lsp.hint.Data
--- @field ['lsp.hover']? lsp.hover.Data
--- @field ['lsp.lens']? lsp.lens.Data
--- @field lsp? lsp.Data
--- @field ['lsp.window']? lsp.window.Data
--- @field ['lsp.semantic']? lsp.semantic.Data
--- @field ["edit.conceal"]? edit.conceal.Data
--- @field ["ui.icon"]? ui.icon.Data
--- @field workspace? workspace.Data
--- @field ["edit.fold"]? edit.fold.Data
--- @field ["edit.hl"]? edit.hl.Data
--- @field ["ui.win"]? ui.win.Data
--- @field note? note.Data
--- @field ['data.clipboard']? data.clipboard.Data
--- @field ['data.dirs']? data.dirs.Data
--- @field ['data.export']? data.export.Data
--- @field ['data.encrypt']? data.encrypt.Data
--- @field ['data.metadata']? data.metadata.Data
--- @field ['data.syntax']? data.syntax.Data
--- @field ['data.toc']? data.toc.Data
--- @field ['edit.parse']? edit.parse.Data
--- @field ['data.log']? data.log.Data
--- @field ['data.link']? data.link.Data
--- @field ['edit.link']? edit.link.Data
--- @field cmd? cmd.Data
--- @field ['data.tag']? data.tag.Data
--- @field ['data.sync']? data.sync.Data
--- @field ['data.mod']? data.mod.Data
--- @field ['data.code']? data.code.Data
--- @field ['data.todo']? data.todo.Data
--- @field ['edit.todo']? edit.todo.Data
--- @field ['edit.cursor']? edit.cursor.Data
--- @field ['edit.find']? edit.find.Data
--- @field ['edit.indent']? edit.indent.Data
--- @field ui? ui.Data
--- @field ['data.template']? data.template.Data
--- @field ["data.code.snippet"]? data.code.snippet.Data
--- @field ["data.code.run"]? data.code.run.Data
--- @field ["ui.calendar"]? ui.calendar.Data
--- @field ["ui.calendar.month"]? ui.calendar.month.Data
--- @field ["integration.treesitter"]? integration.treesitter.Data
--- @field ["integration.blink"]? integration.blink.Data
--- @field ["integration.telescope"]? integration.telescope.Data
--- @field ["integration.fzf"]? integration.fzf.Data
--- @field ["ui.chat"]? ui.chat.Data
--- @field ["ui.sidebar"]? ui.sidebar.Data
--- @field ["ui.popup"]? ui.popup.Data
--- @field ["ui.status"]? ui.status.Data

--- Defines both a public and private config for a word init.
--- Public configs may be tweaked by the user from the `word.setup()` function,  whereas private configs are for internal use only.
--- @class (exact) word.mod.Config
--- @field public public? table  config variables that may be tweaked by the user.
--- @field public private? table  config variables that may be tweaked by the user.
--- @field public custom? table  config variables that may be tweaked by the user.

--- @class (exact) word.mod.Events
--- @field defined? { [string]: word.Event }              Lists all events defined by this init.
--- @field subscribed? { [string]: { [string]: boolean } } Lists the events that the init is subscribed to.

--- @alias word.mod.Setup { loaded: boolean, requires?: string[], replaces?: string, merge?: boolean, wants?: string[] }

--- Defines a init.
--- A init is an object that contains a set of hooks which are invoked by word whenever something in the
--- environment occurs. This can be an event, a simple act of the init being loaded or anything else.
--- @class (exact) word.Mod
--- @field hook? fun(manual: boolean, arguments?: string)    A user-defined function that is invoked whenever word starts up. May be used to e.g. set custom keybindings.
--- @field config? word.mod.config The config for the init.
--- @field events? word.mod.events Describes all information related to events for this init.
--- @field import? table<string, word.mod> Imported submod of the given init. Contrary to `required`, which only exposes the public API of a init, imported mod can be accessed in their entirety.
--- @field cmds? fun() Function that adds all the commands for the init.
--- @field opts? fun() Function that adds all the options for the init.
--- @field maps? fun() Function that adds all the mappings for the init.
--- @field load? fun() Function that is invoked once the init is considered "stable", i.e. after all dependencies are loaded. Perform your main loading routine here.
--- @field test? fun() Function that is invoked when the init is being tested.
--- @field bench? fun() Function that is invoked when the init is being benchmarked.
--- @field name string The name of the init.
--- @field namespace string The name of the init.
--- @field post_load? fun() Function that is invoked after all mod are loaded. Useful if you want the word environment to be fully set up before performing some task.
--- @field path string The full path to the init (a more verbose version of `name`). Moday be used in lua's `require()` statements.
--- @field public data? word.mod.Data Every init can expose any set of information it sees fit through this field. All functions and variables declared in this table will be to any other init loaded.
--- @field required? word.mod.Mods Contains the public tables of all mod that were required via the `requires` array provided in the `setup()` function of this init.
--- @field setup? fun(): word.mod.Setup? Function that is invoked before any other loading occurs. Should perform preliminary startup tasks.
--- @field replaced? boolean If `true`, this means the init is a replacement for a base init. This flag is set automatically whenever `setup().replaces` is set to a value.
--- @field on_event fun(event: word.Event) A callback that is invoked any time an event the init has subscribed to has fired.
--- Returns a new word init, exposing all the necessary function and variables.
--- @param name string The name of the new init. Modake sure this is unique. The recommended naming convention is `category.mod_name` or `category.subcategory.mod_name`.
--- @return word.mod
---
---
--- @alias OperatingSystem
--- | "windows"
--- | "wsl"
--- | "wsl2"
--- | "mac"
--- | "linux"
--- | "bsd"
--- @alias word.config.init { config?: table }

--- @class (exact) word.config.ft
--- @field md boolean
--- @field mdx boolean
--- @field markdown boolean
--- @field word boolean

--- @class (exact) word.config.user
--- @field lazy? boolean                             Whether to defer loading the word base until after the user has entered a `.word` file.
--- @field logger? word.log.config                   A config table for the logger.

--- @class (exact) word.config
--- @field args table<string, string>                   A list of arguments provided to the `:wordStart` function in the form of `key=value` pairs. Only applicable when `user_config.lazy_loading` is `true`.
--- @field manual boolean?                                   Used if word was manually loaded via `:wordStart`. Only applicable when `user_config.lazy_loading` is `true`.
--- @field mod table<string, word.config.init> Acts as a copy of the user's config that may be modified at runtime.
--- @field os OperatingSystem                           The operating system that word is currently running under.
--- @field pathsep "\\"|"/"                                  The operating system that word is currently running under.
--- @field started boolean                                   Set to `true` when word is fully initialized.
--- @field user word.config.user              Stores the config provided by the user.
--- @field version string                                    The version of word that is currently active. Automatically updated by CI on every release.

--- Stores the config for the entirety of word.
--- This includes not only the user config (passed to `setup()`), but also internal
--- variables that describe something specific about the user's hardware.
--- @see word.setup
---
---
--- @alias Mode
--- | "n"
--- | "no"
--- | "nov"
--- | "noV"
--- | "noCTRL-V"
--- | "CTRL-V"
--- | "niI"
--- | "niR"
--- | "niV"
--- | "nt"
--- | "Terminal"
--- | "ntT"
--- | "v"
--- | "vs"
--- | "V"
--- | "Vs"
--- | "CTRL-V"
--- | "CTRL-Vs"
--- | "s"
--- | "S"
--- | "CTRL-S"
--- | "i"
--- | "ic"
--- | "ix"
--- | "R"
--- | "Rc"
--- | "Rx"
--- | "Rv"
--- | "Rvc"
--- | "Rvx"
--- | "c"
--- | "cr"
--- | "cv"
--- | "cvr"
--- | "r"
--- | "rm"
--- | "r?"
--- | "!"
--- | "t"

--- @class (exact) word.Event
--- @field type string The type of the event. Exists in the format of `category.name`.
--- @field split_type string[] The event type, just split on every `.` character, e.g. `{ "category", "name" }`.
--- @field content? table|any The content of the event. The data found here is specific to each individual event. Can be thought of as the payload.
--- @field referrer string The name of the init that triggered the event.
--- @field broadcast boolean Whether the event was broadcast to all mod. `true` is so, `false` if the event was specifically sent to a single recipient.
--- @field cursor_position { [1]: number, [2]: number } The position of the cursor at the moment of broadcasting the event.
--- @field filename string The name of the file that the user was in at the moment of broadcasting the event.
--- @field filehead string The directory the user was in at the moment of broadcasting the event.
--- @field line_content string The content of the line the user was editing at the moment of broadcasting the event.
--- @field buffer number The buffer ID of the buffer the user was in at the moment of broadcasting the event.
--- @field window number The window ID of the window the user was in at the moment of broadcasting the event.
--- @field mode Mode The mode Neovim was in at the moment of broadcasting the event.
---
--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
---
--- @brief word.core
--- @see word.core
---
-- --- @class (exact) word.core.node.Node
---
--- @class (exact) word.core.Graph
--- @field public nodes { [string]: word.core.node.Node