--- @meta down.types.context
---
--- The position of a character aaagin a file.
--- @class (exact) down.Position: { line?: number, char?: number } position of a character in a file
---
--- The position of a character aaagin a file.
--- @class (exact) down.Range: { start: down.Position,start: down.Position } position of a character in a file

--- The context of an in-file object.
--- @class (exact) down.Context context of in-file object
---   @field public position? down.Position location
---   @field public buf? number
---   @field public win? number
---   @field public file? down.Id  root node in file scope
---   @field public dir? down.Id  root node in file scope
---   @field public scope? down.Scope in file scope
---
--- The scope of an entity.
--- @class (exact) down.Info
---   @field public id down.Id
---   @field public uri down.Uri
---   @field public context? down.Context
---   @field public metadata? { [string]: any }
---   @field public tags? { [string]: down.Tag }
---
