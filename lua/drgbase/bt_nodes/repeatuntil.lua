
local Decorator = BT_NODES["Decorator"]
local RepeatUntil = {}
RepeatUntil.__index = RepeatUntil
setmetatable(RepeatUntil, Decorator)
function RepeatUntil:New()
  local repeatUntil = Decorator:New("RepeatUntil")
  setmetatable(repeatUntil, self)
  return repeatUntil
end

function RepeatUntil:Decorate(child, nextbot, data, id)
  while child:Run(nextbot, data, id) do
    if self:ShouldUpdate(id) then return false end
    nextbot:YieldCoroutine(true)
  end
  return true
end

function RepeatUntil:__tostring()
  return "RepeatUntil"
end

BT_NODES["RepeatUntil"] = RepeatUntil
