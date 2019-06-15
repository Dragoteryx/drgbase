
local Composite = BT_NODES["Composite"]
local Selector = {}
Selector.__index = Selector
setmetatable(Selector, Composite)
function Selector:New(random)
  local selector = Composite:New(random, "Selector")
  setmetatable(selector, self)
  return selector
end

function Selector:Handle(tree, nextbot, ...)
  for _, child in self:GetIterator() do
    local res = child:Run(tree, nextbot, ...)
    if res ~= "failure" then return res end
  end
  return "failure"
end
function Selector:__tostring()
  return self:GetType().."("..#self._children..")"
end

BT_NODES["Selector"] = Selector
