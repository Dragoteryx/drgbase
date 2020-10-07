local locoMETA = FindMetaTable("CLuaLocomotion")

-- Speed --

local old_SetDesiredSpeed = locoMETA.SetDesiredSpeed
function locoMETA:SetDesiredSpeed(speed, ...)
  local nextbot = self:GetNextBot()
  if nextbot.IsDrGNextbot then nextbot:SetNW2Float("DrG/Speed", speed) end
  return old_SetDesiredSpeed(self, speed, ...)
end