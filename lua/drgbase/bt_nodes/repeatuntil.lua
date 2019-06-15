
local Decorator = BT_NODES["Decorator"]
local RepeatUntil = {}
RepeatUntil.__index = RepeatUntil
setmetatable(RepeatUntil, Decorator)
function RepeatUntil:New()
  local repeatUntil = Decorator:New("RepeatUntil")
  setmetatable(repeatUntil, self)
  return repeatUntil
end

function RepeatUntil:Decorate(child, tree, nextbot, ...)
  while true do
    local res = child:Run(tree, nextbot, ...)
    if res == "failure" then return "success" end
    if res ~= "success" then return res end
    nextbot:YieldCoroutine(true)
  end
end
function RepeatUntil:__tostring()
  return self:GetType()
end

BT_NODES["RepeatUntil"] = RepeatUntil
