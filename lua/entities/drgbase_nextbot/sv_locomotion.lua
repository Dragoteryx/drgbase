-- Getters/setters --

function ENT:GetDesiredSpeed()
  return self:GetNW2Float("DrG/Speed", 300)
end
function ENT:SetDesiredSpeed(speed)
  return self.loco:SetDesiredSpeed(speed)
end

function ENT:GetAcceleration()
  return self.loco:GetAcceleration()
end
function ENT:SetAcceleration(accel)
  return self.loco:SetAcceleration(accel)
end

function ENT:GetDeceleration()
  return self.loco:GetDeceleration()
end
function ENT:SetDeceleration(decel)
  return self.loco:SetDeceleration(decel)
end

function ENT:GetMaxYawRate()
  return self.loco:GetMaxYawRate()
end
function ENT:SetMaxYawRate(rate)
  return self.loco:SetMaxYawRate(rate)
end

function ENT:GetJumpHeight()
  return self.loco:GetJumpHeight()
end
function ENT:SetJumpHeight(height)
  return self.loco:SetJumpHeight(height)
end

function ENT:GetStepHeight()
  return self.loco:GetStepHeight()
end
function ENT:SetStepHeight(height)
  return self.loco:SetStepHeight(height)
end

function ENT:GetDeathDropHeight()
  return self.loco:GetDeathDropHeight()
end
function ENT:SetDeathDropHeight(height)
  return self.loco:SetDeathDropHeight(height)
end

function ENT:IsStuck()
  return self.loco:IsStuck()
end
function ENT:ClearStuck()
  return self.loco:ClearStuck()
end
function ENT:IsStuckInWorld()
  return self:TraceHull(Vector(0, 0, 0), {
    collisiongroup = COLLISION_GROUP_DEBRIS
  }).HitWorld
end

-- Meta --

local entMETA = FindMetaTable("Entity")

local GetVelocity = entMETA.GetVelocity
function entMETA:GetVelocity(...)
  if self.IsDrGNextbot then
    return self.loco:GetVelocity()
  else return GetVelocity(self, ...) end
end

local SetVelocity = entMETA.SetVelocity
function entMETA:SetVelocity(velocity, ...)
  if self.IsDrGNextbot then
    if velocity.z > 0 then self:LeaveGround() end
    return self.loco:SetVelocity(velocity)
  else return SetVelocity(self, velocity, ...) end
end

local GetGravity = entMETA.GetGravity
function entMETA:GetGravity(...)
  if self.IsDrGNextbot then
    return self.loco:GetGravity()
  else return GetGravity(self, ...) end
end

local SetGravity = entMETA.SetGravity
function entMETA:SetGravity(gravity, ...)
  if self.IsDrGNextbot then
    return self.loco:SetGravity(gravity)
  else return SetGravity(self, gravity, ...) end
end

local locoMETA = FindMetaTable("CLuaLocomotion")

local SetDesiredSpeed = locoMETA.SetDesiredSpeed
function locoMETA:SetDesiredSpeed(speed, ...)
  local nextbot = self:GetNextBot()
  if nextbot.IsDrGNextbot then nextbot:SetNW2Float("DrG/Speed", speed) end
  return SetDesiredSpeed(self, speed, ...)
end