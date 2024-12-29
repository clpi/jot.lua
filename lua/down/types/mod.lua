---@meta down.types.mod
---
--- @alias down.mod.Handler fun(event: down.Event)
---
--- @alias down.mod.SetupFun fun(): down.mod.Setup
---
--- @class down.Opts: {
---   [string]?: string,
--- }
---
--- @alias down.VimMode
--- | 'n'
--- | 'i'
--- | 'v'
--- | 'x'
--- | 'c'
---
--- @class down.Map: {
---   [1]: down.VimMode | down.VimMode[],
---   [2]: string,
---   [3]: string | fun(),
---   [4]?: string,
---   [5]?: down.MapOpts,
---
--- @class down.MapOpts: {
---   mode?: down.VimMode | down.VimMode[],
---   key?: string,
---   callback?: string | fun(),
---   desc?: string,
---   noremap?: boolean,
---   nowait?: boolean
--- }
---
--- @alias down.Maps down.Map[]
---
--- @class (exact) down.Mod
---   @field hook? fun(arguments?: string)    A user-defined function that is invoked whenever down starts up. May be used to e.g. set custom keybindings.
---   @field config? down.mod.Config The config for the mod.
---   @field import? table<string, down.Mod> Imported submod of the given mod. Contrary to `required`, which only exposes the public API of a mod, imported mod can be accessed in their entirety.
---   @field commands?  down.Commands that adds all the commands for the mod.
---   @field maps? down.Maps
---   @field opts? down.Opts Function that adds all the options for the mod.
---   @field load? fun() Function that is invoked once the mod is considered "stable", i.e. after all dependencies are loaded. Perform your main loading routine here.
---   @field version? string
---   @field bench? fun() Function that is invoked when the mod is being benchmarked.
---   @field name string The name of the mod.
---   @field namespace string The name of the mod.
---   @field post_load? fun() Function that is invoked after all mod are loaded. Useful if you want the down environment to be fully set up before performing some task.
---   @field public data? down.mod.Data Every mod can expose any set of information it sees fit through this field. All functions and variables declared in this table will be to any other mod loaded.
---   @field required? table<string, down.Mod.Data> Contains the public tables of all mod that were required via the `requires` array provided in the `setup()` function of this mod.
---   @field setup? fun(): down.mod.Setup? Function that is invoked before any other loading occurs. Should perform preliminary startup tasks.
---   @field replaced? boolean If `true`, this means the mod is a replacement for a base mod. This flag is set automatically whenever `setup().replaces` is set to a value.
---   @field handle fun(event: down.Event) A callback that is invoked any time an event the mod has subscribed to has fired.
---   @field tests? table<string, fun(down.Mod.Mod):boolean> Function that is invoked when the mod is being tested.
---   @field public events? down.mod.Events
---   @field public subscribed? down.mod.Events
-- ---   @field public [string]? down.mod.Data
---
--- @class (exact) down.mod.Setup: {
---   [string]?: { [string]?: any },
---   loaded: boolean,
---   requires?: string[],
---   replaces?: string,
---   merge?: boolean,
---   @field public [string]? any
---
--- @class (exact) down.mod.Events: { [string]: down.Event }
---
--- The entire mod configuration
--- @alias down.config.Mod
---   | down.mod.Lsp
---   | down.mod.Code
---   | down.mod.Parse
---   | down.mod.Edit
---   | down.mod.Data
---   | down.mod.Cmd
---   | down.mod.Tool
---   | down.mod.Workspace
---   | down.mod.Note
---   | down.mod.Ui
---
--- The entire mod configuration
--- @alias down.config.mod.Config
---   | down.mod.lsp.Config
---   | down.mod.data.Config
---   | down.mod.edit.Config
---   | down.mod.config.Config
---   | down.mod.cmd.Config
---   | down.mod.tool.Config
---   | down.mod.workspace.Config
---   | down.mod.note.Config
---   | down.mod.ui.Config
---   | down.mod.parse.Config
---   | down.mod.code.Config
---
--- The entire mod configuration
--- @alias down.Mod.Mod
---   | down.mod.Lsp
---   | down.mod.Code
---   | down.mod.Parse
---   | down.mod.Edit
---   | down.mod.Data
---   | down.mod.Cmd
---   | down.mod.Tool
---   | down.mod.Workspace
---   | down.mod.Note
---   | down.mod.Ui
---
--- @alias down.Mod.Data
---   | down.mod.lsp.Data
---   | down.mod.data.Data
---   | down.mod.edit.Data
---   | down.mod.cmd.Data
---   | down.mod.tool.Data
---   | down.mod.workspace.Data
---   | down.mod.note.Data
---   | down.mod.ui.Data
---   | down.mod.parse.Data
---   | down.mod.code.Data
---
--- @alias down.Mod.Config
---   | down.mod.lsp.Config
---   | down.mod.data.Config
---   | down.mod.edit.Config
---   | down.mod.config.Config
---   | down.mod.cmd.Config
---   | down.mod.tool.Config
---   | down.mod.workspace.Config
---   | down.mod.note.Config
---   | down.mod.ui.Config
---   | down.mod.parse.Config
---   | down.mod.code.Config
---
--- The base configuration
--- @class (exact) down.config.BaseConfig: {
---   [string]?: any,
---   dev?: boolean,
--- }
---
