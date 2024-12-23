local W = {}

---@return down.Workspace
W.init = function()
  local pwd = vim.fn.getcwd()
  ---@type down.Workspace
  return {
    id = pwd,
    config = {
      init = {
      },
      rc = pwd .. "rc.down",
      dataDir = pwd .. ".down/"


    },
    uri = "file:",

    name = pwd,

  }
end


W.spl = function()
  return
end

return W
