-- Util --

local CLASSES = table.DrG_Weak()
local function GetClass(obj)
  return CLASSES[obj]
end

-- Create class --

function DrGBase.CreateClass(superclass)
  local class = setmetatable({}, {})
  class.prototype = setmetatable({}, {})

  if istable(superclass) then
    getmetatable(class).__index = superclass
    class.super = superclass

    getmetatable(class.prototype).__index = superclass.prototype
    class.prototype.super = setmetatable({}, {
      __index = superclass.prototype,
      __call = function(_, ...)
        if isfunction(superclass.new) then
          superclass.new(...)
        end
      end
    })
  end

  local function lessthan(self, other)
    return self:compare(other) < 0
  end
  local function lessequal(self, other)
    return self:compare(other) <= 0
  end
  local function concat(self, other)
    return tostring(self)..other
  end

  getmetatable(class).__call = function(_, ...)
    local obj = setmetatable({}, {
      __index = class.prototype,
      __call = class.prototype.call,
      __tostring = class.prototype.tostring,
      __len = class.prototype.length,
      __unm = class.prototype.unm,
      __add = class.prototype.add,
      __sub = class.prototype.sub,
      __mul = class.prototype.mul,
      __div = class.prototype.div,
      __mod = class.prototype.mod,
      __pow = class.prototype.pow,
      __eq = class.prototype.equals,

      __lt = lessthan,
      __le = lessequal,
      __concat = concat
    })
    CLASSES[obj] = class
    if isfunction(class.new) then
      return obj, class.new(obj, ...)
    else return obj end
  end

  function class.IsInstance(obj)
    if not istable(obj) then return false end
    local meta = getmetatable(obj)
    if not meta then return false end
    return meta.__index == class.prototype or
      IsInstance(meta.__index)
  end

  return class
end

-- Utility classes --

function DrGBase.FlagsHelper(length)
  local ALL = (2^length)-1
  local class = DrGBase.CreateClass()

  local FLAGS = table.DrG_Weak()
  function class:new(flags)
    FLAGS[self] = isnumber(flags) and flags or 0
  end

  function class.prototype:GetFlags()
    return FLAGS[self]
  end
  function class.prototype:AddFlags(flags)
    FLAGS[self] = bit.bor(FLAGS[self], flags)
  end
  function class.prototype:RemoveFlags(flags)
    if not self:IsFlagSet(flags) then return end
    FLAGS[self] = self:GetFlags() - flags
  end
  function class.prototype:IsFlagSet(flags)
    return bit.band(self:GetFlags(), flags) == flags
  end

  function class.prototype:equals(other)
    return GetClass(self).IsInstance(other) and
      self:GetFlags() == other:GetFlags()
  end
  function class.prototype:unm()
    return GetClass(self)(ALL - self:GetFlags())
  end
  function class.prototype:add(other)
    return GetClass(self)(bit.bor(self:GetFlags(), other:GetFlags()))
  end
  function class.prototype:mul(other)
    return GetClass(self)(bit.band(self:GetFlags(), other:GetFlags()))
  end
  function class.prototype:sub(other)
    return self * (-other)
  end

  return class
end