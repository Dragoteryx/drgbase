
-- BEHAVIOUR TREE CLASS --

local DebugEvents = CreateConVar("drgbase_debug_bt_events", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

local BehaviourTree = {}
BehaviourTree.__index = BehaviourTree
function BehaviourTree:New(name)
  local tree = {}
  tree._name = name
  tree._data = {}
  tree._event = {}
  tree._ignore = {}
  tree._transitions = {}
  setmetatable(tree, self)
  return tree
end

function BehaviourTree:OnInit() end
function BehaviourTree:OnRun() end
function BehaviourTree:OnEvent() end
function BehaviourTree:OnEnd() end

function BehaviourTree:GetName()
  return self._name
end
function BehaviourTree:SetName(name)
  self._name = name
end

function BehaviourTree:GetRoot(root)
  return self._root
end
function BehaviourTree:SetRoot(root)
  self._root = root
end
function BehaviourTree:Run(nextbot, ...)
  if GetConVar("drgbase_debug_bt_nodes"):GetBool() then
    DrGBase.Print("[-] "..tostring(self).." => ?")
  end
  local root = self:GetRoot()
  if not root then
    if GetConVar("drgbase_debug_bt_nodes"):GetBool() then
      DrGBase.Print("[-] "..tostring(self).." => failure")
    end
    return "failure"
  end
  self:OnRun(nextbot, ...)
  local res = root:Run(self, nextbot, ...)
  self:OnEnd(nextbot, res, ...)
  if GetConVar("drgbase_debug_bt_nodes"):GetBool() then
    DrGBase.Print("[-] "..tostring(self).." => "..res)
  end
  return res
end
function BehaviourTree:__tostring()
  return "Tree("..self:GetName()..")"
end

function BehaviourTree:GetData(nextbot, key)
  local crea = nextbot:GetCreationID()
  self._data[crea] = self._data[crea] or {}
  return self._data[crea][key]
end
function BehaviourTree:SetData(nextbot, key, data)
  local crea = nextbot:GetCreationID()
  self._data[crea] = self._data[crea] or {}
  self._data[crea][key] = data
end

function BehaviourTree:Event(nextbot, event, ...)
  if not self:IgnoreEvent(event) then
    if DebugEvents:GetBool() then
      DrGBase.Print("[-] "..tostring(self).." received event '"..event.."'.")
    end
    local crea = nextbot:GetCreationID()
    local res = self:OnEvent(nextbot, event, ...)
    if not res then
      if self._transitions[crea] then
        local transition = self._transitions[crea]
        if DebugEvents:GetBool() then
          DrGBase.Print("[-] "..tostring(self).." passed event '"..event.."' to "..tostring(transition)..".")
        end
        transition:Event(nextbot, event)
      else
        self._event[crea] = true
        if DebugEvents:GetBool() then
          DrGBase.Print("[-] "..tostring(self).." executed event '"..event.."'.")
        end
      end
    elseif DebugEvents:GetBool() then
      DrGBase.Print("[-] "..tostring(self).." caught event '"..event.."'.")
    end
  elseif DebugEvents:GetBool() then
    DrGBase.Print("[-] "..tostring(self).." ignored event '"..event.."'.")
  end
end
function BehaviourTree:IgnoreEvent(event, ignore)
  if ignore ~= nil then self._ignore[event] = tobool(ignore)
  else return self._ignore[event] or false end
end

-- NODE CLASSES --

BT_NODES = {}
DrGBase.IncludeFile("bt_nodes/node.lua")
DrGBase.IncludeFile("bt_nodes/leaf.lua")
DrGBase.IncludeFile("bt_nodes/conditional.lua")
DrGBase.IncludeFile("bt_nodes/composite.lua")
DrGBase.IncludeFile("bt_nodes/selector.lua")
DrGBase.IncludeFile("bt_nodes/sequence.lua")
DrGBase.IncludeFile("bt_nodes/decorator.lua")
DrGBase.IncludeFile("bt_nodes/succeeder.lua")
DrGBase.IncludeFile("bt_nodes/inverter.lua")
DrGBase.IncludeFile("bt_nodes/repeatfor.lua")
DrGBase.IncludeFile("bt_nodes/repeatuntil.lua")
DrGBase.IncludeFile("bt_nodes/tree_transition.lua")
local Leaf = BT_NODES["Leaf"]
local Conditional = BT_NODES["Conditional"]
local Sequence = BT_NODES["Sequence"]
local Selector = BT_NODES["Selector"]
local Succeeder = BT_NODES["Succeeder"]
local Inverter = BT_NODES["Inverter"]
local RepeatFor = BT_NODES["RepeatFor"]
local RepeatUntil = BT_NODES["RepeatUntil"]
local TreeTransition = BT_NODES["TreeTransition"]
local NODE_TYPES = BT_NODES
BT_NODES = nil

local COMPOSITES = {
  ["Sequence"] = Sequence,
  ["Selector"] = Selector
}
local DECORATORS = {
  ["Succeeder"] = Succeeder,
  ["Inverter"] = Inverter,
  ["RepeatFor"] = RepeatFor,
  ["RepeatUntil"] = RepeatUntil
}
local function CreateNode(tbl)
  if not istable(tbl) then return end
  if not isstring(tbl.type) then return end
  if tbl.type == "Tree" or tbl.Type == "TreeTransition" then
    if not isstring(tbl.name) then return end
    return TreeTransition:New(tbl.name, tbl.args)
  elseif COMPOSITES[tbl.type] then
    local composite = COMPOSITES[tbl.type]:New(tobool(tbl.random))
    if istable(tbl.children) then
      for i, child in ipairs(tbl.children) do
        composite:AddChild(CreateNode(child))
      end
    end
    return composite
  elseif DECORATORS[tbl.type] then
    local decorator
    if tbl.type == "RepeatFor" then
      decorator = RepeatFor:New(tonumber(tbl.nb))
    else decorator = DECORATORS[tbl.type]:New() end
    decorator:SetChild(CreateNode(tbl.child))
    return decorator
  elseif NODE_TYPES[tbl.type] then
    if not isstring(tbl.name) then return end
    if not isfunction(tbl.run) then return end
    local node = NODE_TYPES[tbl.type]:New(tbl.name, tbl.run)
    if tbl.type == "Conditional" then
      node:SetSuccessChild(CreateNode(tbl.success))
      node:SetFailureChild(CreateNode(tbl.failure))
    end
    return node
  end
end

-- BEHAVIOUR TREE REGISTRY --

local DEFAULTS = {
  ["baseai"] = true,
  ["handleenemy"] = true,
  ["chaseenemy"] = true,
  ["patrol"] = true,
  ["movetopos"] = true,
  ["followentity"] = true
}
local BEHAVIOUR_TREES = {}
function DrGBase.GetBehaviourTree(name)
  name = string.lower(name)
  if BEHAVIOUR_TREES[name] then return BEHAVIOUR_TREES[name] end
  local tree = DrGBase.CreateBehaviourTree(name)
  BEHAVIOUR_TREES[name] = tree
  return tree
end
function DrGBase.GetBT(name)
  return DrGBase.GetBehaviourTree(name)
end

function DrGBase.CreateBehaviourTree(name)
  local default = tobool(DEFAULTS[name])
  local luaFolder = default and "default_behaviours/" or "behaviours/"
  if file.Exists("drgbase/"..luaFolder..name..".lua", "LUA") then
    DrGBase.Print("Creating behaviour tree '"..name.."'.")
    local tree = BehaviourTree:New(name)
    tree.Structure = {}
    BT = tree
    DrGBase.IncludeFile(luaFolder..name..".lua")
    BT = nil
    tree:SetRoot(CreateNode(tree.Structure))
    tree.Structure = nil
    tree:OnInit()
    if tree:GetRoot() then DrGBase.Print("Behaviour tree '"..name.."' created.")
    else DrGBase.Error("Error while creating behaviour tree '"..name.."'.") end
    BEHAVIOUR_TREES[name] = tree
    return tree
  else DrGBase.Error("Unable to find behaviour tree '"..name.."'.") end
end
function DrGBase.CreateBT(name)
  return DrGBase.CreateBehaviourTree(name)
end

-- LOAD BEHAVIOURS --

for name, default in pairs(DEFAULTS) do
  DrGBase.GetBehaviourTree(name)
end
for i, name in ipairs(file.Find("drgbase/behaviours/*.lua", "LUA")) do
  name = string.Replace(name, ".lua", "")
  DrGBase.GetBehaviourTree(name)
end
