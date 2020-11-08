function DrGBase.Class(superclass)
  local class = {}
  if istable(superclass) then
    class.__index = setmetatable({}, superclass)
    class.__index.__super = setmetatable({}, {
      __index = superclass.__index,
      __call = function(_, ...)
        if isfunction(superclass.__new) then
          local res = superclass.__new(...)
          if res then return res end
        end
      end
    })
  else class.__index = {} end

  setmetatable(class, {
    __call = function(_, ...)
      local obj = setmetatable({}, class)
      if isfunction(class.__new) then
        local res = class.__new(obj, ...)
        if res then return obj, res end
      end
      return obj
    end
  })

  function IsInstance(tbl)
    local meta = getmetatable(tbl)
    if not meta then return false
    elseif meta == class then return true
    else return IsInstance(class.__index) end
  end

  return class, IsInstance
end