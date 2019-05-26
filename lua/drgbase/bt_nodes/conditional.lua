
local Node = BT_NODES["Node"]
local Leaf = BT_NODES["Leaf"]
local Conditional = {}
Conditional.__index = Conditional
setmetatable(Conditional, Leaf)
function Conditional:New(description, run)
  local conditional = Leaf:New(description, run, "Conditional")
  conditional._super = Leaf
  conditional._success = true
  conditional._failure = false
  setmetatable(conditional, self)
  return conditional
end

function Conditional:GetSuccessChild()
  return self._success
end
function Conditional:SetSuccessChild(child)
  self._success = child
  return self
end
function Conditional:GetFailureChild()
  return self._failure
end
function Conditional:SetFailureChild(child)
  self._failure = child
  return self
end

function Conditional:IsChild(node)
  if node == nil then return false end
  return node == self:GetSuccessChild() or node == self:GetFailureChild()
end

function Conditional:Execute(nextbot, data, id)
  if self._run(nextbot, data) then
    local child = self:GetSuccessChild()
    if child then
      self:RegisterNext(id, child)
      local res = child:Run(nextbot, data, id)
      self:RegisterNext(id, nil)
      return res
    else return false end
  else
    local child = self:GetFailureChild()
    if child then
      self:RegisterNext(id, child)
      local res = child:Run(nextbot, data, id)
      self:RegisterNext(id, nil)
      return res
    else return true end
  end
end
function Conditional:Update(id)
  Node.Update(self, id)
  if self:GetSuccessChild() then self:GetSuccessChild():Update(id) end
  if self:GetFailureChild() then self:GetFailureChild():Update(id) end
end

function Conditional:__tostring()
  return "Conditional("..self:GetDescription()..")"
end

function Conditional:Print(depth)
  depth = depth or 0
  Node.Print(self, depth)
  if self:GetSuccessChild() then self:GetSuccessChild():Print(depth+1) end
  if self:GetFailureChild() then self:GetFailureChild():Print(depth+1) end
end

BT_NODES["Conditional"] = Conditional
