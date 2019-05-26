
local Decorator = BT_NODES["Decorator"]
local RepeatFor = {}
RepeatFor.__index = RepeatFor
setmetatable(RepeatFor, Decorator)
function RepeatFor:New(nb)
  local repeatFor = Decorator:New("RepeatFor")
  repeatFor._nb = nb
  setmetatable(repeatFor, self)
  return repeatFor
end

function RepeatFor:Decorate(child, nextbot, data, id)
  for i = 1, self._nb do
    if self:ShouldUpdate(id) then return false end
    if not child:Run(nextbot, data, id) then return false end
    coroutine.yield()
  end
  return true
end

function RepeatFor:__tostring()
  return "RepeatFor("..self._nb..")"
end

BT_NODES["RepeatFor"] = RepeatFor
