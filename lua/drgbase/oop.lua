local CLASSES = setmetatable({}, {__mode = "k"})

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
    if CLASSES[obj] then return false end
    local meta = getmetatable(obj)
    if not istable(meta) then return false end
    local super = meta.__index
    if not istable(super) then return false end
    return super == class or IsInstance(super)
  end

  return class, IsInstance
end