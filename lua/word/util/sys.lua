S = {}

--- @brief [[
--- Defines the configuration table for use throughout word.
--- @brief ]]

-- TODO(vhyrro): Make `word_version` and `version` a `Version` class.

--- @alias OperatingSystem
--- | "windows"
--- | "wsl"
--- | "wsl2"
--- | "mac"
--- | "linux"
--- | "bsd"

--- @alias word.configuration.init { config?: table }

--- @class (exact) word.configuration.user
--- @field hook? fun(manual: boolean, arguments?: string)    A user-defined function that is invoked whenever word starts up. May be used to e.g. set custom keybindings.
--- @field lazy_loading? boolean                             Whether to defer loading the word base until after the user has entered a `.word` file.
--- @field load table<string, word.configuration.init>    A list of mod to load, alongside their configurations.
--- @field logger? word.log.configuration                   A configuration table for the logger.

--- @class (exact) word.configuration
--- @field arguments table<string, string>                   A list of arguments provided to the `:wordStart` function in the form of `key=value` pairs. Only applicable when `user_config.lazy_loading` is `true`.
--- @field manual boolean?                                   Used if word was manually loaded via `:wordStart`. Only applicable when `user_config.lazy_loading` is `true`.
--- @field mod table<string, word.configuration.init> Acts as a copy of the user's configuration that may be modified at runtime.
--- @field word_version string                               The version of the file format to be used throughout word. Used internally.
--- @field os_info OperatingSystem                           The operating system that word is currently running under.
--- @field pathsep "\\"|"/"                                  The operating system that word is currently running under.
--- @field started boolean                                   Set to `true` when word is fully initialized.
--- @field user_config word.configuration.user              Stores the configuration provided by the user.
--- @field version string                                    The version of word that is currently active. Automatically updated by CI on every release.

--- Gets the current operating system.
--- @return OperatingSystem
S.get_os_info = function()
  local os = vim.loop.os_uname().sysname:lower()

  if os:find("windows_nt") then
    return "windows"
  elseif os == "darwin" then
    return "mac"
  elseif os == "linux" then
    local f = io.open("/proc/version", "r")
    if f ~= nil then
      local version = f:read("*all")
      f:close()
      if version:find("WSL2") then
        return "wsl2"
      elseif version:find("microsoft") then
        return "wsl"
      end
    end
    return "linux"
  elseif os:find("bsd") then
    return "bsd"
  end

  error("[word]: Unable to determine the currently active operating system!")
end

return S
