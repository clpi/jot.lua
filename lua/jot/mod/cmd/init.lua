--[[
    file: cmd-init
    title: Does the Heavy Lifting for the `:jot` Command
    summary: This init deals with handling everything related to the `:jot` command.
    internal: true
    ---
This internal init handles everything there is for the `:jot` command to function.

Different mod can define their own commands, completions and conditions on when they'd

For a full example on how to create your own command, it is recommended to read the
`base.cmd`'s `mod.lua` file. At the beginning of the file is an examples table
which walks you through the necessary steps.
--]]

local jot = require("jot")
local log, mod, util = jot.log, jot.mod, jot.utils

local M = mod.create("cmd")

M.maps = function()
  Map.nmap(",wml", "<CMD>Jot mod list<CR>")
  Map.nmap(",wmL", "<CMD>Jot mod load<CR>")
end
M.setup = function()
  return { loaded = true, requires = {} }
end
M.public = {
  data = {

    --- Handles the calling of the appropriate function based on the command the user entered
    jot_callback = function(data)
      local args = data.fargs

      local current_buf = vim.api.nvim_get_current_buf()
      local is_jot = vim.bo[current_buf].filetype == "markdown"

      local function check_condition(condition)
        if condition == nil then
          return true
        end

        if condition == "markdown" and not is_jot then
          return false
        end

        if type(condition) == "function" then
          return condition(current_buf, is_jot)
        end

        return condition
      end

      local ref = {
        subcommands = M.public.commands,
      }
      local argument_index = 0

      for i, cmd in ipairs(args) do
        if not ref.subcommands or vim.tbl_isempty(ref.subcommands) then
          break
        end

        ref = ref.subcommands[cmd]

        if not ref then
          log.error(
            ("Error when executing `:Jot %s` - such a command does not exist!"):format(
              table.concat(vim.list_slice(args, 1, i), " ")
            )
          )
          return
        elseif not check_condition(ref.condition) then
          log.error(
            ("Error when executing `:Jot %s` - the command is currently disabled. Some commands will only become available under certain conditions, e.g. being within a `.jot` file!")
            :format(
              table.concat(vim.list_slice(args, 1, i), " ")
            )
          )
          return
        end

        argument_index = i
      end

      local argument_count = (#args - argument_index)

      if ref.args then
        ref.min_args = ref.args
        ref.max_args = ref.args
      elseif ref.min_args and not ref.max_args then
        ref.max_args = math.huge
      else
        ref.min_args = ref.min_args or 0
        ref.max_args = ref.max_args or 0
      end

      if #args == 0 or argument_count < ref.min_args then
        local completions = M.public.data.generate_completions(
          _,
          table.concat({ "Jot ", data.args, " " })
        )
        M.public.data.select_next_cmd_arg(data.args, completions)
        return
      elseif argument_count > ref.max_args then
        log.error(
          ("Error when executing `:jot %s` - too many arguments supplied! The command expects %s argument%s."):format(
            data.args,
            ref.max_args == 0 and "no" or ref.max_args,
            ref.max_args == 1 and "" or "s"
          )
        )
        return
      end

      if not ref.name then
        log.error(
          ("Error when executing `:jot %s` - the ending command didn't have a `name` variable associated with it! This is an implementation error on the developer's side, so file a report to the author of the mod.")
          :format(
            data.args
          )
        )
        return
      end

      if not M.events.defined[ref.name] then
        M.events.defined[ref.name] = mod.define_event(M, ref.name)
      end

      mod.broadcast_event(
        assert(
          mod.create_event(
            M,
            table.concat({ "cmd.events.", ref.name }),
            vim.list_slice(args, argument_index + 1)
          )
        )
      )
    end,

    --- This function returns all available commands to be used for the :jot command
    ---@param _ nil #Placeholder variable
    ---@param command string #Supplied by nvim itself; the full typed out command
    generate_completions = function(_, command)
      local current_buf = vim.api.nvim_get_current_buf()
      local is_jot = vim.api.nvim_buf_get_option(current_buf, "filetype")
          == "markdown"

      local function check_condition(condition)
        if condition == nil then
          return true
        end

        if condition == "markdown" and not is_jot then
          return false
        end

        if type(condition) == "function" then
          return condition(current_buf, is_jot)
        end

        return condition
      end

      command = command:gsub("^%s*", "")

      local splitcmd = vim.list_slice(
        vim.split(command, " ", {
          plain = true,
          trimempty = true,
        }),
        2
      )

      local ref = {
        subcommands = M.public.commands,
      }
      local last_valid_ref = ref
      local last_completion_level = 0

      for _, cmd in ipairs(splitcmd) do
        if not ref or not check_condition(ref.condition) then
          break
        end

        ref = ref.subcommands or {}
        ref = ref[cmd]

        if ref then
          last_valid_ref = ref
          last_completion_level = last_completion_level + 1
        end
      end

      if not last_valid_ref.subcommands and last_valid_ref.complete then
        if type(last_valid_ref.complete) == "function" then
          last_valid_ref.complete = last_valid_ref.complete(current_buf, is_jot)
        end

        if vim.endswith(command, " ") then
          local completions = last_valid_ref.complete[#splitcmd - last_completion_level + 1]
              or {}

          if type(completions) == "function" then
            completions = completions(current_buf, is_jot) or {}
          end

          return completions
        else
          local completions = last_valid_ref.complete[#splitcmd - last_completion_level]
              or {}

          if type(completions) == "function" then
            completions = completions(current_buf, is_jot) or {}
          end

          return vim.tbl_filter(function(key)
            return key:find(splitcmd[#splitcmd])
          end, completions)
        end
      end

      -- TODO: Fix `:jot m <tab>` giving invalid completions
      local keys = ref and vim.tbl_keys(ref.subcommands or {})
          or (
            vim.tbl_filter(function(key)
              return key:find(splitcmd[#splitcmd])
            end, vim.tbl_keys(last_valid_ref.subcommands or {}))
          )
      table.sort(keys)

      do
        local subcommands = (
          ref and ref.subcommands or last_valid_ref.subcommands
        ) or {}

        return vim.tbl_filter(function(key)
          return check_condition(subcommands[key].condition)
        end, keys)
      end
    end,

    --- Queries the user to select next argument
    ---@param qargs table #A string of arguments previously supplied to the jot command
    ---@param choices table #all possible choices for the next argument
    select_next_cmd_arg = function(qargs, choices)
      local current = table.concat({ "Jot ", qargs })

      local query

      if vim.tbl_isempty(choices) then
        query = function(...)
          vim.ui.input(...)
        end
      else
        query = function(...)
          vim.ui.select(choices, ...)
        end
      end

      query({
        prompt = current,
      }, function(choice)
        if choice ~= nil then
          vim.cmd(string.format("%s %s", current, choice))
        end
      end)
    end,
  },
  commands = {
    mod = {
      subcommands = {
        new = {
          args = 1,
          name = "mod.new",
        },
        load = {
          args = 1,
          name = "mod.load",
        },

        list = {
          args = 0,
          name = "mod.list",
        },
      },
    },
  },

  -- The table containing all the functions. This can get a tad complex so I recommend you read the wiki entry

  --- Recursively merges the contents of the init's config.funtions table with base.cmd's mod.config.commands table.
  ---@param mod_name string #An absolute path to a loaded init with a mod.config.commands table following a valid structure
  add_commands = function(mod_name)
    local mod_config = mod.get_mod(mod_name)

    if not mod_config or not mod_config.commands then
      return
    end

    M.public.commands =
        vim.tbl_extend("force", M.public.commands, mod_config.commands)
  end,

  -- add = function(cmd, cb)
  --   mod.await("cmd", function(c)
  --     c.add_commands_from_table({
  --       [cmd] = {
  --         name = cmd,
  --         callback = cb,
  --       }
  --     })
  --   end)
  --   M.public.add_commands(cmd)
  -- end,

  --- Recursively merges the provided table with the mod.config.commands table.
  ---@param functions table #A table that follows the mod.config.commands structure
  add_commands_from_table = function(functions)
    M.public.commands = vim.tbl_extend("force", M.public.commands, functions)
  end,

  --- Takes a relative path (e.g "list.mod") and loads it from the commands/ directory
  ---@param name string #The relative path of the init we want to load
  add_commands_from_file = function(name)
    -- Attempt to require the file
    local err, ret = pcall(require, "jot.mod.cmd." .. name .. "init")

    -- If we've failed bail out
    if not err then
      log.warn(
        "Could not load command",
        name,
        "for init base.cmd - the corresponding mod.lua file does not exist."
      )
      return
    end

    -- Load the init from table
    mod.load_mod_from_table(ret)
  end,

  --- Rereads data from all mod and rebuild the list of available autocompletiinitinitons and commands
  sync = function()
    -- Loop through every loaded init and set up all their commands
    for _, lm in pairs(mod.loaded_mod) do
      if lm.public.commands then
        M.public.add_commands_from_table(lm.public.commands)
      end
    end
  end,

  --- Defines a custom completion function to use for `base.cmd`.
  ---@param callback function The same function format as you would receive by being called by `:command -completion=customlist,v:lua.callback jot`.
  set_completion_callback = function(callback)
    M.public.data.generate_completions = callback
  end,
}
M.load = function()
  -- Define the :jot command with autocompletion taking any number of arguments (-nargs=*)
  -- If the user passes no arguments or too few, we'll query them for the remainder using select_next_cmd_arg.
  vim.api.nvim_create_user_command("Jot", M.public.data.jot_callback, {
    desc = "The jot command",
    range = 2,
    force = true,
    -- bang = true,
    nargs = "*",
    complete = M.public.data.generate_completions,
  })

  -- Loop through all the command mod we want to load and load them
  for _, command in ipairs(M.config.load) do
    -- If one of the command mod is "config" then load all the base mod
    if command == "default" then
      for _, base_command in ipairs(M.config.base) do
        M.public.add_commands_from_file(base_command)
      end
    end
  end
end

M.config = {
  -- A list of cmd mod to load automatically.
  -- This feature will soon be deprecated, so it is not recommended to touch it.
  load = {
    "default",
  },

  -- A list of base commands to load.
  --
  -- This feature will soon be deprecated, so it is not recommended to touch it.
  base = {
    "mod",
    "back",
    "rename",
  },
}
---@class cmd

M.post_load = M.public.sync

M.on_event = function(event)
  if event.type == "cmd.events.mod.setup" then
    local ok = pcall(mod.load_mod, event.content[1])

    if not ok then
      vim.notify(
        string.format("init `%s` does not exist!", event.content[1]),
        vim.log.levels.ERROR,
        {}
      )
    end
  end

  if event.type == "cmd.events.mod.unload" then
  end

  if event.type == "cmd.events.mod.list" then
    local Popup = require("nui.popup")

    local mod_list_popup = Popup({
      position = "50%",
      size = { width = "50%", height = "80%" },
      enter = true,
      buf_options = {
        filetype = "markdown",
        modifiable = true,
        readonly = false,
      },
      win_options = {
        conceallevel = 3,
        concealcursor = "nvi",
      },
    })

    mod_list_popup:on("VimResized", function()
      mod_list_popup:update_layout()
    end)

    local function close()
      mod_list_popup:unmount()
    end

    mod_list_popup:map("n", "<Esc>", close, {})
    mod_list_popup:map("n", "q", close, {})

    local lines = {}

    for name, _ in pairs(jot.mod.loaded_mod) do
      table.insert(lines, "- `" .. name .. "`")
    end

    vim.api.nvim_buf_set_lines(mod_list_popup.bufnr, 0, -1, true, lines)

    vim.bo[mod_list_popup.bufnr].modifiable = false

    mod_list_popup:mount()
  end
end
M.events.subscribed = {
  cmd = {
    -- ["mod.new"] = true,
    ["mod.unload"] = true,
    ["mod.load"] = true,
    ["mod.list"] = true,
  },
}

return M
