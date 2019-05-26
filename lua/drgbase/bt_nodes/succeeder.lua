
local Decorator = BT_NODES["Decorator"]
local Succeeder = {}
Succeeder.__index = Succeeder
setmetatable(Succeeder, Decorator)
function Succeeder:New()
  local succeeder = Decorator:New("Succeeder")
  setmetatable(succeeder, self)
  return succeeder
end

function Succeeder:Decorate(child, nextbot, data, id)
  child:Run(nextbot, data, id)
  return true
end

function Succeeder:__tostring()
  return "Succeeder"
end

BT_NODES["Succeeder"] = Succeeder
