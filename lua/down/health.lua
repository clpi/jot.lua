local H = {}

local h = vim.health
local ok, err, warn = h.ok, h.error, h.warn

H.check = function()
  h.start "checking config"
  local c = require "down.config".config
  if c ~= nil then
    ok("config is not nil" .. #c.user.mod .. #c.mod)
  else
    err("config is nil" .. "")
  end
end

H.health = {
}

return H
