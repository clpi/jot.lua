--[[
    file: cmd-Module
    title: Does the Heavy Lifting for the `:Dorm` Command
    summary: This module deals with handling everything related to the `:Dorm` command.
    internal: true
    ---
This internal module handles everything there is for the `:Dorm` command to function.

Different mod can define their own commands, completions and conditions on when they'd
like these commands to be avaiable.

For a full example on how to create your own command, it is recommended to read the
`base.cmd`'s `module.lua` file. At the beginning of the file is an examples table
which walks you through the necessary steps.
--]]

local dorm = require("dorm")
local log, mod = dorm.log, dorm.mod

local module = mod.create("cmd")

module.examples = {
  ["Adding a dorm command"] = function()
    -- In your module.setup(), make sure to require base.cmd (requires = { "cmd" })
    -- Afterwards in a function of your choice that gets called *after* base.cmd gets intialized e.g. load():

    module.load = function()
      module.required["cmd"].add_commands_from_table({
        -- The name of our command
        my_command = {
          min_args = 1, -- Tells cmd that we want at least one argument for this command
          max_args = 1, -- Tells cmd we want no more than one argument
          args = 1,     -- Setting this variable instead would be the equivalent of min_args = 1 and max_args = 1
          -- This command is only avaiable within `.dorm` files.
          -- This can also be a function(bufnr, is_in_an_dorm_file)
          condition = "markdown",

          subcommands = { -- Defines subcommands
            -- Repeat the definition cycle again
            my_subcommand = {
              args = 2, -- Force two arguments to be supplied
              -- The identifying name of this command
              -- Every "endpoint" must have a name associated with it
              name = "my.command",

              -- If your command takes in arguments versus
              -- subcommands you can make a table of tables with
              -- completion for those arguments here.
              -- This table is optional.
              complete = {
                { "first_completion1",  "first_completion2" },
                { "second_completion1", "second_completion2" },
              },

              -- We do not define a subcommands table here because we don't have any more subcommands
              -- Creating an empty subcommands table will cause errors so don't bother
            },
          },
        },
      })
    end

    -- Afterwards, you want to subscribe to the corresponding event:

    module.events.subscribed = {
      ["cmd"] = {
        ["my.command"] = true, -- Has the same name as our "name" variable had in the "data" table
      },
    }

    -- There's also another way to define your own custom commands that's a lot more automated. Such automation can be achieved
    -- by putting your code in a special directory. That directory is in base.cmd.commands. Creating your mod in this directory
    -- will allow users to easily enable you as a "command module" without much hassle.

    -- To enable a command in the commands/ directory, do this:

    require("dorm").setup({
      load = {
        ["cmd"] = {
          config = {
            load = {
              "some.cmd", -- The name of a valid command
            },
          },
        },
      },
    })

    -- And that's it! You're good to go.
    -- Want to find out more? Read the wiki entry! https://github.com/nvim-dorm/dorm/wiki/dorm-Command
  end,
}

module.load = function()
  -- Define the :Dorm command with autocompletion taking any number of arguments (-nargs=*)
  -- If the user passes no arguments or too few, we'll query them for the remainder using select_next_cmd_arg.
  vim.api.nvim_create_user_command("Dorm", module.private.command_callback, {
    desc = "The dorm command",
    force = true,
    -- bang = true,
    nargs = "*",
    complete = module.private.generate_completions,
  })

  -- Loop through all the command mod we want to load and load them
  for _, command in ipairs(module.config.public.load) do
    -- If one of the command mod is "base" then load all the base mod
    if command == "base" then
      for _, base_command in ipairs(module.config.public.base) do
        module.public.add_commands_from_file(base_command)
      end
    end
  end
end

module.config.public = {
  -- A list of cmd mod to load automatically.
  -- This feature will soon be deprecated, so it is not recommended to touch it.
  load = {
    "base",
  },

  -- A list of base commands to load.
  --
  -- This feature will soon be deprecated, so it is not recommended to touch it.
  base = {
    "return",
  },
}
---@class base.cmd
module.public = {
  -- The table containing all the functions. This can get a tad complex so I recommend you read the wiki entry
  dorm_commands = {
    module = {
      subcommands = {
        -- new = {
        --   args = 1,
        --   name = "module.new",
        -- },
        load = {
          args = 1,
          name = "module.load",
        },

        list = {
          args = 0,
          name = "module.list",
        },
      },
    },
  },

  --- Recursively merges the contents of the module's config.public.funtions table with base.cmd's module.config.public.dorm_commands table.
  ---@param module_name string #An absolute path to a loaded module with a module.config.public.dorm_commands table following a valid structure
  add_commands = function(module_name)
    local module_config = mod.get_module(module_name)

    if not module_config or not module_config.dorm_commands then
      return
    end

    module.public.dorm_commands =
        vim.tbl_extend("force", module.public.dorm_commands, module_config.dorm_commands)
  end,

  --- Recursively merges the provided table with the module.config.public.dorm_commands table.
  ---@param functions table #A table that follows the module.config.public.dorm_commands structure
  add_commands_from_table = function(functions)
    module.public.dorm_commands = vim.tbl_extend("force", module.public.dorm_commands, functions)
  end,

  --- Takes a relative path (e.g "list.mod") and loads it from the commands/ directory
  ---@param name string #The relative path of the module we want to load
  add_commands_from_file = function(name)
    -- Attempt to require the file
    local err, ret = pcall(require, "dorm.mod.cmd.commands." .. name .. ".module")

    -- If we've failed bail out
    if not err then
      log.warn(
        "Could not load command",
        name,
        "for module base.cmd - the corresponding module.lua file does not exist."
      )
      return
    end

    -- Load the module from table
    mod.load_module_from_table(ret)
  end,

  --- Rereads data from all mod and rebuild the list of available autocompletimodulemoduleons and commands
  sync = function()
    -- Loop through every loaded module and set up all their commands
    for _, mod in pairs(mod.loaded_mod) do
      if mod.public.dorm_commands then
        module.public.add_commands_from_table(mod.public.dorm_commands)
      end
    end
  end,

  --- Defines a custom completion function to use for `base.cmd`.
  ---@param callback function The same function format as you would receive by being called by `:command -completion=customlist,v:lua.callback dorm`.
  set_completion_callback = function(callback)
    module.private.generate_completions = callback
  end,
}

module.private = {
  --- Handles the calling of the appropriate function based on the command the user entered
  command_callback = function(data)
    local args = data.fargs

    local current_buf = vim.api.nvim_get_current_buf()
    local is_dorm = vim.bo[current_buf].filetype == "markdown"

    local function check_condition(condition)
      if condition == nil then
        return true
      end

      if condition == "dorm" and not is_dorm then
        return false
      end

      if type(condition) == "function" then
        return condition(current_buf, is_dorm)
      end

      return condition
    end

    local ref = {
      subcommands = module.public.dorm_commands,
    }
    local argument_index = 0

    for i, cmd in ipairs(args) do
      if not ref.subcommands or vim.tbl_isempty(ref.subcommands) then
        break
      end

      ref = ref.subcommands[cmd]

      if not ref then
        log.error(
          ("Error when executing `:Dorm %s` - such a command does not exist!"):format(
            table.concat(vim.list_slice(args, 1, i), " ")
          )
        )
        return
      elseif not check_condition(ref.condition) then
        log.error(
          ("Error when executing `:Dorm %s` - the command is currently disabled. Some commands will only become available under certain conditions, e.g. being within a `.dorm` file!")
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
      local completions = module.private.generate_completions(_, table.concat({ "Dorm ", data.args, " " }))
      module.private.select_next_cmd_arg(data.args, completions)
      return
    elseif argument_count > ref.max_args then
      log.error(
        ("Error when executing `:Dorm %s` - too many arguments supplied! The command expects %s argument%s.")
        :format(
          data.args,
          ref.max_args == 0 and "no" or ref.max_args,
          ref.max_args == 1 and "" or "s"
        )
      )
      return
    end

    if not ref.name then
      log.error(
        ("Error when executing `:Dorm %s` - the ending command didn't have a `name` variable associated with it! This is an implementation error on the developer's side, so file a report to the author of the module.")
        :format(
          data.args
        )
      )
      return
    end

    if not module.events.defined[ref.name] then
      module.events.defined[ref.name] = mod.define_event(module, ref.name)
    end

    mod.broadcast_event(
      assert(
        mod.create_event(
          module,
          table.concat({ "cmd.events.", ref.name }),
          vim.list_slice(args, argument_index + 1)
        )
      )
    )
  end,

  --- This function returns all available commands to be used for the :Dorm command
  ---@param _ nil #Placeholder variable
  ---@param command string #Supplied by nvim itself; the full typed out command
  generate_completions = function(_, command)
    local current_buf = vim.api.nvim_get_current_buf()
    local is_dorm = vim.api.nvim_buf_get_option(current_buf, "filetype") == "dorm"

    local function check_condition(condition)
      if condition == nil then
        return true
      end

      if condition == "dorm" and not is_dorm then
        return false
      end

      if type(condition) == "function" then
        return condition(current_buf, is_dorm)
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
      subcommands = module.public.dorm_commands,
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
        last_valid_ref.complete = last_valid_ref.complete(current_buf, is_dorm)
      end

      if vim.endswith(command, " ") then
        local completions = last_valid_ref.complete[#splitcmd - last_completion_level + 1] or {}

        if type(completions) == "function" then
          completions = completions(current_buf, is_dorm) or {}
        end

        return completions
      else
        local completions = last_valid_ref.complete[#splitcmd - last_completion_level] or {}

        if type(completions) == "function" then
          completions = completions(current_buf, is_dorm) or {}
        end

        return vim.tbl_filter(function(key)
          return key:find(splitcmd[#splitcmd])
        end, completions)
      end
    end

    -- TODO: Fix `:Dorm m <tab>` giving invalid completions
    local keys = ref and vim.tbl_keys(ref.subcommands or {})
        or (
          vim.tbl_filter(function(key)
            return key:find(splitcmd[#splitcmd])
          end, vim.tbl_keys(last_valid_ref.subcommands or {}))
        )
    table.sort(keys)

    do
      local subcommands = (ref and ref.subcommands or last_valid_ref.subcommands) or {}

      return vim.tbl_filter(function(key)
        return check_condition(subcommands[key].condition)
      end, keys)
    end
  end,

  --- Queries the user to select next argument
  ---@param qargs table #A string of arguments previously supplied to the dorm command
  ---@param choices table #all possible choices for the next argument
  select_next_cmd_arg = function(qargs, choices)
    local current = table.concat({ "dorm ", qargs })

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
}

module.dorm_post_load = module.public.sync

module.on_event = function(event)
  if event.type == "cmd.events.module.load" then
    local ok = pcall(mod.load_module, event.content[1])

    if not ok then
      vim.notify(string.format("Module `%s` does not exist!", event.content[1]), vim.log.levels.ERROR, {})
    end
  end

  if event.type == "cmd.events.module.list" then
    local Popup = require("nui.popup")

    local module_list_popup = Popup({
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

    module_list_popup:on("VimResized", function()
      module_list_popup:update_layout()
    end)

    local function close()
      module_list_popup:unmount()
    end

    module_list_popup:map("n", "<Esc>", close, {})
    module_list_popup:map("n", "q", close, {})

    local lines = {}

    for name, _ in pairs(dorm.mod.loaded_mod) do
      table.insert(lines, "- `" .. name .. "`")
    end

    vim.api.nvim_buf_set_lines(module_list_popup.bufnr, 0, -1, true, lines)

    vim.bo[module_list_popup.bufnr].modifiable = false

    module_list_popup:mount()
  end
end

module.events.subscribed = {
  ["cmd"] = {
    -- ["module.new"] = true,
    ["module.load"] = true,
    ["module.list"] = true,
  },
}

return module
