
local Leaf = BT_NODES["Leaf"]
local Conditional = {}
Conditional.__index = Conditional
setmetatable(Conditional, Leaf)
function Conditional:New(name, run)
  local conditional = Leaf:New(name, run, "Conditional")
  setmetatable(conditional, self)
  return conditional
end

function Conditional:GetSuccessChild()
  return self._success
end
function Conditional:SetSuccessChild(node)
  self._success = node
end

function Conditional:GetFailureChild()
  return self._failure
end
function Conditional:SetFailureChild(node)
  self._failure = node
end

function Conditional:IsChild(node)
  if not node then return end
  return node == self:GetSuccessChild() or node == self:GetFailureChild()
end

function Conditional:Handle(tree, nextbot, ...)
  if self._run(tree, nextbot, ...) then
    return self:Condition(self:GetSuccessChild(), tree, nextbot, ...)
  else
    return self:Condition(self:GetFailureChild(), tree, nextbot, ...)
  end
end
function Conditional:Condition(child, tree, nextbot, ...)
  if child then
    return child:Run(tree, nextbot, ...)
  else return "failure" end
end
function Conditional:__tostring()
  return self:GetType().."("..self:GetName()..")"
end

BT_NODES["Conditional"] = Conditional
