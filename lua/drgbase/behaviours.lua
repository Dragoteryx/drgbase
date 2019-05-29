if CLIENT then return end

-- LOAD NODES --
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
local Leaf = BT_NODES["Leaf"]
local Conditional = BT_NODES["Conditional"]
local Sequence = BT_NODES["Sequence"]
local Selector = BT_NODES["Selector"]
local Succeeder = BT_NODES["Succeeder"]
local Inverter = BT_NODES["Inverter"]
local RepeatFor = BT_NODES["RepeatFor"]
local RepeatUntil = BT_NODES["RepeatUntil"]
local NODE_TYPES = BT_NODES
BT_NODES = nil

-- BEHAVIOUR REGISTRY --

local DEFAULTS = {
  ["movetoposition"] = true,
  ["patrol"] = true,
  ["baseai"] = true,
  ["chaseenemy"] = true
}
local BEHAVIOURS = {}
local CUSTOM_BEHAVIOURS = {}
function DrGBase.GetBehaviourTree(name)
  name = string.lower(name)
  if BEHAVIOURS[name] then return BEHAVIOURS[name]
  else return CUSTOM_BEHAVIOURS[name] end
end

-- CREATE BEHAVIOUR --

local COMPOSITES = {
  ["Selector"] = true,
  ["Sequence"] = true
}
local DECORATORS = {
  ["Succeeder"] = true,
  ["Inverter"] = true,
  ["RepeatFor"] = true,
  ["RepeatUntil"] = true
}

local FUNCTIONS = {}
function FUNCTIONS.CreateBehaviourTree(name, args, branch)
  name = string.lower(name)
  if not istable(args) then args = {} end
  local default = tobool(DEFAULTS[name])
  local luaFolder = default and "default_behaviours/" or "behaviours/"
  if file.Exists("drgbase/"..luaFolder..name..".lua", "LUA") then
    if not branch then
      DrGBase.Print("Generating behaviour tree '"..name.."'.")
    end
    BT = {}
    BT.Tree = {}
    BT.Args = args
    include(luaFolder..name..".lua")
    local tree = FUNCTIONS.CreateNode(BT.Tree)
    BT = nil
    if not branch then
      if tree then DrGBase.Print("Behaviour tree '"..name.."' successfully generated.")
      else DrGBase.Error("Error while creating behaviour tree '"..name.."'.") end
    end
    return tree
  elseif not branch then
    DrGBase.Error("Unable to find behaviour tree '"..name.."'.")
  end
end
function FUNCTIONS.CreateNode(tbl)
  if not istable(tbl) then return end
  if not isstring(tbl.type) then return end
  if tbl.type == "Tree" then
    return FUNCTIONS.CreateBehaviourTree(tbl.name, tbl.args, true)
  elseif COMPOSITES[tbl.type] then
    local node = NODE_TYPES[tbl.type]:New(tobool(tbl.random))
    if istable(tbl.children) then
      for i, child in ipairs(tbl.children) do
        if not istable(child) then continue end
        node:AddChild(FUNCTIONS.CreateNode(child))
      end
    end
    return node
  elseif DECORATORS[tbl.type] then
    local node
    if tbl.type == "RepeatFor" then
      node = RepeatFor:New(isnumber(tbl.nb) and tbl.nb or 1)
    else node = NODE_TYPES[tbl.type]:New() end
    if istable(tbl.child) then
      node:SetChild(FUNCTIONS.CreateNode(tbl.child))
    end
    return node
  elseif NODE_TYPES[tbl.type] then
    if not isfunction(tbl.run) then return end
    local node = NODE_TYPES[tbl.type]:New(isstring(tbl.description) and tbl.description or tbl.type, tbl.run)
    if tbl.type == "Conditional" then
      if istable(tbl.success) then
        node:SetSuccessChild(FUNCTIONS.CreateNode(tbl.success, BT))
      end
      if istable(tbl.failure) then
        node:SetFailureChild(FUNCTIONS.CreateNode(tbl.failure, BT))
      end
    end
    return node
  end
end

function DrGBase.RefreshBehaviourTree(name)
  name = string.lower(name)
  local tree = FUNCTIONS.CreateBehaviourTree(name)
  if DEFAULTS[name] then BEHAVIOURS[name] = tree
  else CUSTOM_BEHAVIOURS[name] = tree end
  return tree
end
for name, default in pairs(DEFAULTS) do
  DrGBase.RefreshBehaviourTree(name)
end
for i, name in ipairs(file.Find("drgbase/behaviours/*.lua", "LUA")) do
  name = string.Replace(name, ".lua", "")
  DrGBase.RefreshBehaviourTree(name)
end

--PrintTable(DrGBase.GetBehaviourTree("BaseAI"))
