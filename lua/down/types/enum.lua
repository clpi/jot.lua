---@enum down.ids.enum
---
--- The scope of an entity.
--- @alias down.Mode
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

--- The scope of an entity.
--- @alias down.Status 'queued' status of a task
---   | 'waiting'   Waiting
---   | 'finished'  Finished
---   | 'cancelled' Cancelled
---   | 'pending'   Pending, todo
---   | 'blocked'   Blocked
---
--- The scope of an entity.
--- @alias down.Scope
---  | "priority"
---  | "category"
---  | "group"
---  | "flag"
---  | "user" for entities in the same profile
---  | "tag"         for shared tag entities
---  | "workspace"   for all files in workspace
---  | "project"     for entities in the same project
---  | "global"      for all entities across workspaces and profiles
---  | "local"       for this file only
---  | "dir"         for this and other files in the same dir
---  | "children"    for this file, all in same dir, and all children of dirs
---  | "dynamic"     for entities in the same dynamic scope
---  | "other"       for entities in other scopes
---
---
--- Operating system
--- @alias down.Os
--- | "windows"
--- | "wsl"
--- | "wsl2"
--- | "mac"
--- | "linux"
--- | "bsd"
---
--- @alias down.dirs.Down
---   | { name: "home", uri: "~/.down" }
---   | { name: "config", uri: "~/.config/down" }
---   | { name: "data", uri: "~/.local/share/down"}
---   | { name: "cache", uri: "~/.local/share/down"}
---   | { name: "temp", uri: "/tmp/down"}
---   | { name: "log", uri: "~/.down/log"}
---   | { name: "lsp", uri: "~/.down/lsp"}
---   | { name: "workspace", uri: "~/.down/workspace"}
---
--- The status of a task.
---@alias down.task.Status "done"
--- | "todo"
--- | "cancelled"
--- | "waiting"
--- | "blocked"
--- | "doing"
---
--- The priority of a task.
--- @alias down.task.Priority "misc"
--- | "lowest"
--- | "low"
--- | "medium"
--- | "high"
--- | "highest"
---
--- Ranking
--- @alias down.Ranking integer 0
---   | 1
---   | 2
---   | 3
---   | 4
---   | 5
