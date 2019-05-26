
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
  ["MoveToPosition"] = true,
  ["Patrol"] = true,
  ["DefaultAI"] = true,
  ["ChaseEnemy"] = true
}
local BEHAVIOURS = {}
local CUSTOM_BEHAVIOURS = {}
function DrGBase.GetBehaviourTree(name)
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
function FUNCTIONS.CreateBehaviourTree(name, args)
  if not istable(args) then args = {} end
  local default = tobool(DEFAULTS[name])
  local luaFolder = default and "default_behaviours/" or "behaviours/"
  if not file.Exists("drgbase/"..luaFolder..name..".json", "LUA") then return end
  BT = {}
  BT_ARGS = args
  if file.Exists("drgbase/"..luaFolder..name..".lua", "LUA") then
    DrGBase.IncludeFile(luaFolder..name..".lua")
  end
  BT_ARGS = nil
  local json = util.JSONToTable(file.Read("drgbase/"..luaFolder..name..".json", "LUA"))
  local tree = FUNCTIONS.CreateNode(json, BT)
  BT = nil
  return tree
end
function FUNCTIONS.CreateNode(tbl, bt)
  if not isstring(tbl.type) then return end
  if tbl.type == "Tree" then
    return FUNCTIONS.CreateBehaviourTree(tbl.name, tbl.args)
  elseif COMPOSITES[tbl.type] then
    local node = NODE_TYPES[tbl.type]:New(tobool(tbl.random))
    if istable(tbl.children) then
      for i, child in ipairs(tbl.children) do
        node:AddChild(FUNCTIONS.CreateNode(child, bt))
      end
    end
    return node
  elseif DECORATORS[tbl.type] then
    local node
    if tbl.type == "RepeatFor" then
      node = RepeatFor:New(isnumber(tbl.nb) and tbl.nb or 1)
    else node = NODE_TYPES[tbl.type]:New() end
    node:SetChild(FUNCTIONS.CreateNode(tbl.child, bt))
    return node
  else
    local run
    if not isstring(tbl.run) then return end
    if string.StartWith(tbl.run, ":") then
      local func = string.Replace(tbl.run, ":", "")
      run = function(nextbot, data)
        local method = nextbot[func]
        if not isfunction(method) then return false end
        local res = method(nextbot, unpack(tbl.args or {}))
        if res == nil or res then return true
        else return false end
      end
    elseif string.StartWith(tbl.run, ".") then
      local func = string.Replace(tbl.run, ".", "")
      run = function(nextbot, data)
        local method = nextbot[func]
        if not isfunction(method) then return false end
        local res = method(unpack(tbl.args or {}))
        if res == nil or res then return true
        else return false end
      end
    else
      local generator = bt[tbl.run]
      if not generator then return end
      run = generator(unpack(tbl.args or {}))
    end
    local node = NODE_TYPES[tbl.type]:New(isstring(tbl.description) and tbl.description or tbl.run, run)
    if tbl.type == "Conditional" then
      if tbl.success then
        node:SetSuccessChild(FUNCTIONS.CreateNode(tbl.success, BT))
      end
      if tbl.failure then
        node:SetFailureChild(FUNCTIONS.CreateNode(tbl.failure, BT))
      end
    end
    return node
  end
end

function DrGBase.RefreshBehaviourTree(name)
  local tree = FUNCTIONS.CreateBehaviourTree(name)
  if DEFAULTS[name] then BEHAVIOURS[name] = tree
  else CUSTOM_BEHAVIOURS[name] = tree end
end
for name, default in pairs(DEFAULTS) do
  DrGBase.RefreshBehaviourTree(name)
end
for i, name in ipairs(file.Find("drgbase/behaviours/*.json", "LUA")) do
  name = string.Replace(name, ".json", "")
  DrGBase.RefreshBehaviourTree(name)
end
