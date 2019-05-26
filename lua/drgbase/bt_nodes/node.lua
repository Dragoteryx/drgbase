
local DebugBT = CreateConVar("drgbase_debug_bt_nodes", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

local ID = 1
local Node = {}
Node.__index = Node
function Node:New(type)
  local node = {}
  node._type = type
  node._nexts = {}
  node._updates = {}
  setmetatable(node, self)
  return node
end

function Node:IsComposite()
  return false
end
function Node:IsDecorator()
  return false
end
function Node:IsLeaf()
  return self:GetType() == "Leaf"
end
function Node:IsConditional()
  return self:GetType() == "Conditional"
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

function Node:Start(nextbot, callback)
  local id = ID
  ID = ID + 1
  if isfunction(callback) then callback(id) end
  return self:Run(nextbot, {}, id)
end
function Node:Run(nextbot, data, id)
  if DebugBT:GetBool() then
    DrGBase.Print("["..id.."] "..tostring(self).." => ?")
  end
  self._lastID = id
  if self:ShouldUpdate(id) then
    if DebugBT:GetBool() then
      DrGBase.Print("["..id.."] "..tostring(self).." => update")
    end
    return false
  else
    local res = self:Execute(nextbot, data, id)
    if DebugBT:GetBool() then
      DrGBase.Print("["..id.."] "..tostring(self).." => "..tostring(res))
    end
    return res
  end
end
function Node:Execute(nextbot, data, id)
  return false
end
function Node:LastID()
  return self._lastID
end

function Node:Update(id)
  self._updates[id] = true
end
function Node:ShouldUpdate(id)
  return self._updates[id] or false
end

function Node:RegisterNext(id, node)
  self._nexts[id] = node
  return self
end
function Node:FetchNext(id)
  return self._nexts[id]
end
function Node:TreeTraversal(id)
  local node = self
  return function()
    if node ~= nil then
      local toreturn = node
      node = toreturn:FetchNext(id)
      return toreturn
    else return nil end
  end
end

function Node:Print(depth)
  depth = depth or 0
  local str = ""
  for i = 1, depth do str = str.."  " end
  print(str..tostring(self))
end

BT_NODES["Node"] = Node
