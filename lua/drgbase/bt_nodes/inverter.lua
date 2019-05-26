
local Decorator = BT_NODES["Decorator"]
local Inverter = {}
Inverter.__index = Inverter
setmetatable(Inverter, Decorator)
function Inverter:New()
  local inverter = Decorator:New("Inverter")
  setmetatable(inverter, self)
  return inverter
end

function Inverter:Decorate(child, nextbot, data, id)
  return not child:Run(nextbot, data, id)
end

function Inverter:__tostring()
  return "Inverter"
end

BT_NODES["Inverter"] = Inverter
