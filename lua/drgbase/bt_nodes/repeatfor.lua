
local Decorator = BT_NODES["Decorator"]
local RepeatFor = {}
RepeatFor.__index = RepeatFor
setmetatable(RepeatFor, Decorator)
function RepeatFor:New(nb)
  local repeatFor = Decorator:New("RepeatFor")
  repeatFor._nb = nb
  setmetatable(repeatFor, self)
  return repeatFor
end

function RepeatFor:GetNb()
  return self._nb
end
function RepeatFor:SetNb(nb)
  self._nb = tonumber(nb)
end

function RepeatFor:Decorate(child, tree, nextbot, ...)
  for i = 1, self:GetNb() do
    local res = child:Run(tree, nextbot, ...)
    if res ~= "success" then return res end
    nextbot:YieldCoroutine(true)
  end
  return "success"
end
function RepeatFor:__tostring()
  return self:GetType().."("..self:GetNb()..")"
end

BT_NODES["RepeatFor"] = RepeatFor
