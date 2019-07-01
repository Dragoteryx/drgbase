if CLIENT then return end

-- Handlers --

function ENT:_InitLocomotion()
  self:SetAcceleration(self.Acceleration)
  self:SetDeceleration(self.Deceleration)
  self:SetJumpHeight(self.JumpHeight)
  self:SetStepHeight(self.StepHeight)
  self:SetMaxYawRate(self.MaxYawRate)
  self:SetDeathDropHeight(self.DeathDropHeight)
end

-- Getters/setters --

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

function ENT:GetMaxYawRate()
  return self.loco:GetMaxYawRate()
end
function ENT:SetMaxYawRate(rate)
  return self.loco:SetMaxYawRate(rate)
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

end

-- Meta --

local locoMETA = FindMetaTable("CLuaLocomotion")

--[[local old_SetDesiredSpeed = locoMETA.SetDesiredSpeed
function locoMETA:SetDesiredSpeed(speed)
  local nextbot = self:GetNextBot()
  if nextbot.IsDrGNextbot then
    -- do stuff
    return old_SetDesiredSpeed(self, speed)
  else return old_SetDesiredSpeed(self, speed) end
end]]
