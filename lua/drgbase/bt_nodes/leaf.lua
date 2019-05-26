
local Node = BT_NODES["Node"]
local Leaf = {}
Leaf.__index = Leaf
setmetatable(Leaf, Node)
function Leaf:New(description, run, type)
  local leaf = Node:New(type or "Leaf")
  leaf._super = Node
  leaf._description = description
  leaf._run = run
  setmetatable(leaf, self)
  return leaf
end

function Leaf:SetDescription(description)
  self._description = description
  return self
end
function Leaf:GetDescription()
  return self._description
end

function Leaf:Execute(nextbot, data, id)
  if self._run(nextbot, data) then return true
  else return false end
end

function Leaf:__tostring()
  return "Leaf("..self:GetDescription()..")"
end

BT_NODES["Leaf"] = Leaf
