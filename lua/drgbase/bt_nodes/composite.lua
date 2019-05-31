
local Node = BT_NODES["Node"]
local Composite = {}
Composite.__index = Composite
setmetatable(Composite, Node)
function Composite:New(random, type)
  local composite = Node:New(type)
  composite._random = random or false
  composite._children = {}
  setmetatable(composite, self)
  return composite
end

function Composite:IsComposite()
  return true
end
function Composite:GetType()
  if self:IsRandom() then return "Random"..self._type
  else return self._type end
end

function Composite:IsRandom()
  return self._random
end
function Composite:SetRandom(random)
  self._random = tobool(random)
  return true
end

function Composite:GetChildren()
  return self._children
end
function Composite:AddChild(node, position)
  if isnumber(position) then
    table.insert(self._children, position, node)
  else table.insert(self._children, node) end
  return self
end
function Composite:RemoveChild(toremove)
  if isnumber(toremove) then table.remove(self._children, toremove)
  else table.RemoveByValue(self._children, toremove) end
  return self
end
function Composite:GetChild(position)
  return self._children[position or 1]
end

function Composite:IsChild(node)
  return table.HasValue(self._children, node)
end

function Composite:GetIterator()
  if self:IsRandom() then return RandomPairs(self:GetChildren())
  else return ipairs(self:GetChildren()) end
end
function Composite:Update(id)
  Node.Update(self, id)
  for i, child in ipairs(self._children) do
    child:Update(id)
  end
end

function Composite:Print(depth)
  depth = depth or 0
  Node.Print(self, depth)
  for i, child in ipairs(self._children) do
    child:Print(depth+1)
  end
end

BT_NODES["Composite"] = Composite
