string = require('string')
--- Check if a string is a wikilink, if so, return the link destination.
--- @param self string
--- @return string|nil
function string.iswikilink(self)
  if self:startswith('[[') and self:endswith(']]') then
    return self:sub(3, -3)
  end
  return nil
end

--- @param self string
--- @param start string
--- @return boolean
function string.startswith(self, start)
  return self:sub(1, #start) == start
end

--- @param self string
--- @param ending string
--- @return boolean
function string.endswith(self, ending)
  return self:sub(-#ending) == ending
end

--- Split self at `at`th occurrence of `patt`
--- @param self string
--- @param patt string: The pattern to split on
--- @return string[]
function string.split(self, patt)
  local a, b = string.find(self, patt or '%.')
  if a == nil or b == nil then
    return { [1] = self }
  end
  return {
    [1] = string.sub(self, 0, a or #self - 1),
    [2] = string.sub(self, b + 1),
  }
end

--- Returns true if string is 'true', or false if string is 'false'
--- Returns nil if string is neither
--- @param self string
--- @return boolean|nil
function string.isbool(self)
  if self ~= nil and self ~= '' then
    if self == 'true' then
      return true
    elseif self == 'false' then
      return false
    end
  end
  return nil
end

return string
