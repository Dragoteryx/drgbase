local META = FindMetaTable("DrG/NextBot")

-- Getters/setters --

function META:GetDesiredSpeed()
  return self:GetNW2Float("DrG/Speed", 300)
end
function META:SetDesiredSpeed(speed)
  return self.loco:SetDesiredSpeed(speed)
end

function META:GetAcceleration()
  return self.loco:GetAcceleration()
end
function META:SetAcceleration(accel)
  return self.loco:SetAcceleration(accel)
end

function META:GetDeceleration()
  return self.loco:GetDeceleration()
end
function META:SetDeceleration(decel)
  return self.loco:SetDeceleration(decel)
end

function META:GetMaxYawRate()
  return self.loco:GetMaxYawRate()
end
function META:SetMaxYawRate(rate)
  return self.loco:SetMaxYawRate(rate)
end

function META:GetJumpHeight()
  return self.loco:GetJumpHeight()
end
function META:SetJumpHeight(height)
  return self.loco:SetJumpHeight(height)
end

function META:GetStepHeight()
  return self.loco:GetStepHeight()
end
function META:SetStepHeight(height)
  return self.loco:SetStepHeight(height)
end

function META:GetDeathDropHeight()
  return self.loco:GetDeathDropHeight()
end
function META:SetDeathDropHeight(height)
  return self.loco:SetDeathDropHeight(height)
end

function META:IsStuck()
  return self.loco:IsStuck()
end
function META:ClearStuck()
  return self.loco:ClearStuck()
end
function META:IsStuckInWorld()
  return self:TraceHull(Vector(0, 0, 0), {
    collisiongroup = COLLISION_GROUP_DEBRIS
  }).HitWorld
end

-- Meta --

function META:GetVelocity(...)
  return self.loco:GetVelocity()
end

function META:SetVelocity(velocity, ...)
  if velocity.z > 0 then self:LeaveGround() end
  return self.loco:SetVelocity(velocity)
end

function META:GetGravity(...)
  return self.loco:GetGravity()
end

function META:SetGravity(gravity, ...)
  return self.loco:SetGravity(gravity)
end

local locoMETA = FindMetaTable("CLuaLocomotion")

local SetDesiredSpeed = locoMETA.SetDesiredSpeed
function locoMETA:SetDesiredSpeed(speed, ...)
  local nextbot = self:GetNextBot()
  if nextbot.IsDrGNextbot then nextbot:SetNW2Float("DrG/Speed", speed/DrGBase.SpeedMultiplier:GetFloat()/nextbot:GetModelScale()) end
  return SetDesiredSpeed(self, speed, ...)
end