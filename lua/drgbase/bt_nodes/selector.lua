
local Composite = BT_NODES["Composite"]
local Selector = {}
Selector.__index = Selector
setmetatable(Selector, Composite)
function Selector:New(random)
  local selector = Composite:New(random, "Selector")
  setmetatable(selector, self)
  return selector
end

function Selector:Execute(nextbot, data, id)
  for _, child in self:GetIterator() do
    if self:ShouldUpdate(id) then return false end
    self:RegisterNext(id, child)
    if child:Run(nextbot, data, id) then
      self:RegisterNext(id, nil)
      return true
    else self:RegisterNext(id, nil) end
  end
  return false
end

function Selector:__tostring()
  return self:GetType().."("..#self:GetChildren()..")"
end

BT_NODES["Selector"] = Selector
