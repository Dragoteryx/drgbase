
local Composite = BT_NODES["Composite"]
local Sequence = {}
Sequence.__index = Sequence
setmetatable(Sequence, Composite)
function Sequence:New(random)
  local sequence = Composite:New(random, "Sequence")
  setmetatable(sequence, self)
  return sequence
end

function Sequence:Handle(tree, nextbot, ...)
  for _, child in self:GetIterator() do
    local res = child:Run(tree, nextbot, ...)
    if res ~= "success" then return res end
  end
  return "success"
end
function Sequence:__tostring()
  return self:GetType().."("..#self._children..")"
end

BT_NODES["Sequence"] = Sequence
