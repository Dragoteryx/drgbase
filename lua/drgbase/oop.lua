local CLASSES = table.DrG_Weak()

function DrGBase.Class(superclass)
  if superclass and not CLASSES[superclass] then return end
  local class = {}
  CLASSES[class] = true
  class.__index = class
  setmetatable(class, {
    __index = superclass,
    __call = function(_, ...)
      local obj = setmetatable({}, class)
      if isfunction(class.__new) then class.__new(obj, ...) end
      return obj
    end
  })

  function IsInstance(obj)
    local meta = getmetatable(obj)
    if not istable(meta) then return false end
    if not istable(meta.__index) then return false end
    return meta.__index == class or IsInstance(meta.__index)
  end

  return class, IsInstance
end