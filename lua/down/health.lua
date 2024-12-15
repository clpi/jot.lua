local H = {}

local h = vim.health
local ok,err,warn=h.ok,h.error,h.warn

H.check = function()
  h.start "checking config"
  local c = require "down.mod.config".config
  if c == nil then
    err "config is nil"
  else
    ok "config not nil"
  end
end

H.health = {
}

return H
