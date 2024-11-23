local C = {}
local mod = require "word.mod"
C.create_meta = function(name, ...)
  local m = mod.create(name)

  m.config.public.enable = { ... }

  m.setup = function()
    return { success = true }
  end

  m.load = function()
    m.config.public.enable = (function()
      if not m.config.public.disable then
        return m.config.public.enable
      end

      local ret = {}

      for _, mname in ipairs(m.config.public.enable) do
        if not vim.tbl_contains(m.config.public.disable, mname) then
          table.insert(ret, mname)
        end
      end

      return ret
    end)()

    for _, mname in ipairs(m.config.public.enable) do
      M.setup_mod(mname)
    end
  end

  return m
end

return C
