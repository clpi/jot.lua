function string:startswith(start)
  return self:sub(1, #start) == start
end

function string:endswith(en)
  return self:sub(- #en) == en
end

setmetatable(string, {
  __bool = function(self)
    if self ~= nil and self ~= "" then
      if self == "true" then
        return true
      elseif self == "false" then
        return false
      end
    end
    return nil
  end
})
