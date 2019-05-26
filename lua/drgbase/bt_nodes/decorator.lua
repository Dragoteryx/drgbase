
local Node = BT_NODES["Node"]
local Decorator = {}
Decorator.__index = Decorator
setmetatable(Decorator, Node)
function Decorator:New(type)
  local decorator = Node:New(type)
  setmetatable(decorator, self)
  return decorator
end

function Decorator:IsDecorator()
  return true
end

function Decorator:GetChild()
  return self._child
end
function Decorator:SetChild(child)
  self._child = child
  return self
end

function Decorator:IsChild(node)
  if node == nil then return end
  return node == self._child
end

function Decorator:Execute(nextbot, data, id)
  local child = self:GetChild()
  if not child then return false end
  self:RegisterNext(id, child)
  local res = self:Decorate(child, nextbot, data, id)
  self:RegisterNext(id, nil)
  return res
end
function Decorator:Decorate(child, nextbot, data, id)
  return child:Run(nextbot, data, id)
end
function Decorator:Update(id)
  Node.Update(self, id)
  if self:GetChild() then self:GetChild():Update(id) end
end

function Decorator:Print(depth)
  depth = depth or 0
  Node.Print(self, depth)
  if self:GetChild() then self:GetChild():Print(depth+1) end
end

BT_NODES["Decorator"] = Decorator
