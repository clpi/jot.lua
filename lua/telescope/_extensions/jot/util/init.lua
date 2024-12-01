local utils = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local entry_display = require("telescope.pickers.entry_display")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local state = require("telescope.actions.state")
local actions_set = require("telescope.actions.set")
local conf = require("telescope.config").values

local jot = require("jot")
---Gets the full path to the current workspace
---@return string?
utils.get_current_workspace = function()
  local workspace = Mod.get_mod("workspace")
  if workspace then
    local current_workspace = workspace.get_current_workspace()[2]
    return current_workspace
  end
  return nil
end

return utils
