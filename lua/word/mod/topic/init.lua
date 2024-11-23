---@meta


---@alias word.event.mod_loaded string
---Informs that a new module has been loaded and added to word's environment.
---Since only the module's name is published, a module that would like to gather
---more information about the newly loaded module should retrieve it by calling
---`word.modules.get()`.
---TODO: Make this a reality!


---@alias word.event.word_started nil
---Informs that word has finished loaded. Its payload is empty.
