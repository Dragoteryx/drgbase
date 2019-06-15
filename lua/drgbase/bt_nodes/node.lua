
local DebugBT = CreateConVar("drgbase_debug_bt_nodes", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

local node_id = 0
local Node = {}
Node.__index = Node
function Node:New(type)
  local node = {}
  node._id = node_id
  node_id = node_id+1
  node._type = type
  setmetatable(node, self)
  return node
end

function Node:GetID()
  return self._id
end
function Node:GetType()
  return self._type
end

function Node:IsParent(node)
  return node:IsChild(self)
end
function Node:IsChild(node)
  return false
end

function Node:IsLeaf()
  return self:GetType() == "Leaf"
end
function Node:IsConditional()
  return self:GetType() == "Conditional"
end
function Node:IsDecorator()
  return false
end
function Node:IsComposite()
  return false
end

function Node:Run(tree, nextbot, ...)
  if DebugBT:GetBool() then
    DrGBase.Print("["..self:GetID().."] "..tostring(self).." => ?")
  end
  local crea = nextbot:GetCreationID()
  if tree._event[crea] then
    tree._event[crea] = false
    if DebugBT:GetBool() then
      DrGBase.Print("["..self:GetID().."] "..tostring(self).." => event")
    end
    return "event"
  else
    local res = self:Handle(tree, nextbot, ...)
    if DebugBT:GetBool() then
      DrGBase.Print("["..self:GetID().."] "..tostring(self).." => "..res)
    end
    return res
  end
end
function Node:Handle(tree, nextbot, ...)
  return false
end
function Node:__tostring()
  return self:GetType()
end

BT_NODES["Node"] = Node
