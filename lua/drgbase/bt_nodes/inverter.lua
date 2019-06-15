
local Decorator = BT_NODES["Decorator"]
local Inverter = {}
Inverter.__index = Inverter
setmetatable(Inverter, Decorator)
function Inverter:New()
  local inverter = Decorator:New("Inverter")
  setmetatable(inverter, self)
  return inverter
end

function Inverter:Decorate(child, tree, nextbot, ...)
  local res = child:Run(tree, nextbot, ...)
  if res == "success" then return "failure"
  elseif res == "failure" then return "success"
  else return res end
end
function Inverter:__tostring()
  return self:GetType()
end

BT_NODES["Inverter"] = Inverter
