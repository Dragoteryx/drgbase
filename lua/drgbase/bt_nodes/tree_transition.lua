
local Node = BT_NODES["Node"]
local TreeTransition = {}
TreeTransition.__index = TreeTransition
setmetatable(TreeTransition, Node)
function TreeTransition:New(name, args)
  local transition = Node:New("TreeTransition")
  transition._tree = {}
  transition._args = args
  setmetatable(transition, self)
  transition:SetTree(name)
  return transition
end

function TreeTransition:GetTree()
  return self._tree
end
function TreeTransition:SetTree(name)
  self._tree = DrGBase.GetBehaviourTree(name)
end

function TreeTransition:GetArgs()
  return self._args
end
function TreeTransition:SetArgs(args)
  self._args = args
end

function TreeTransition:Handle(tree, nextbot, ...)
  if not self:GetTree() then return "failure" end
  local args = {}
  if istable(self._args) then
    for i, arg in ipairs(self._args) do
      if isfunction(arg) then arg = arg(tree, nextbot, ...) end
      table.insert(args, arg)
    end
  elseif isfunction(self._args) then
    args = {self._args(tree, nextbot, ...)}
  end
  local crea = nextbot:GetCreationID()
  local old_trans = tree._transitions[crea]
  tree._transitions[crea] = self:GetTree()
  local res = self:GetTree():Run(nextbot, unpack(args))
  tree._transitions[crea] = old_trans
  return res
end

function TreeTransition:__tostring()
  return "TreeTransition("..self:GetTree():GetName()..")"
end

BT_NODES["TreeTransition"] = TreeTransition
