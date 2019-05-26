
local Composite = BT_NODES["Composite"]
local Sequence = {}
Sequence.__index = Sequence
setmetatable(Sequence, Composite)
function Sequence:New(random)
  local sequence = Composite:New(random, "Sequence")
  setmetatable(sequence, self)
  return sequence
end

function Sequence:Execute(nextbot, data, id)
  for _, child in self:GetIterator() do
    if self:ShouldUpdate(id) then return false end
    self:RegisterNext(id, child)
    if not child:Run(nextbot, data, id) then
      self:RegisterNext(id, nil)
      return false
    else self:RegisterNext(id, nil) end
  end
  return true
end

function Sequence:__tostring()
  return self:GetType().."("..#self:GetChildren()..")"
end

BT_NODES["Sequence"] = Sequence
