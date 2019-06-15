
local Node = BT_NODES["Node"]
local Decorator = {}
Decorator.__index = Decorator
setmetatable(Decorator, Node)
function Decorator:New(type)
  local decorator = Node:New(type)
  setmetatable(decorator, self)
  return decorator
end

function Decorator:GetChild()
  return self._child
end
function Decorator:SetChild(node)
  self._child = node
end

function Decorator:IsChild(node)
  if not node then return end
  return node == self:GetChild()
end

function Decorator:Handle(tree, nextbot, ...)
  local child = self:GetChild()
  if not child then return "failure" end
  return self:Decorate(child, tree, nextbot, ...)
end
function Decorator:Decorate(child, tree, nextbot, ...)
  return child:Run(tree, nextbot, ...)
end

BT_NODES["Decorator"] = Decorator
