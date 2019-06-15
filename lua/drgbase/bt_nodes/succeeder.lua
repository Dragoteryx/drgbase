
local Decorator = BT_NODES["Decorator"]
local Succeeder = {}
Succeeder.__index = Succeeder
setmetatable(Succeeder, Decorator)
function Succeeder:New()
  local succeeder = Decorator:New("Succeeder")
  setmetatable(succeeder, self)
  return succeeder
end

function Succeeder:Decorate(child, tree, nextbot, ...)
  local res = child:Run(tree, nextbot, ...)
  if res == "failure" then return "success"
  else return res end
end
function Succeeder:__tostring()
  return self:GetType()
end

BT_NODES["Succeeder"] = Succeeder
