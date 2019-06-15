
local Node = BT_NODES["Node"]
local Leaf = {}
Leaf.__index = Leaf
setmetatable(Leaf, Node)
function Leaf:New(name, run, type)
  local leaf = Node:New(type or "Leaf")
  leaf._name = name
  leaf._run = run
  setmetatable(leaf, self)
  return leaf
end

function Leaf:GetName()
  return self._name
end
function Leaf:SetName(name)
  self._name = tostring(name)
end

function Leaf:Handle(tree, nextbot, ...)
  if self._run(tree, nextbot, ...) then return "success"
  else return "failure" end
end
function Leaf:__tostring()
  return self:GetType().."("..self:GetName()..")"
end

BT_NODES["Leaf"] = Leaf
