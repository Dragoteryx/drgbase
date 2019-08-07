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

function ENT:GetDesiredSpeed()
  return self:GetNW2Float("DrGBaseDesiredSpeed")
end
function ENT:SetDesiredSpeed(speed)
  return self.loco:SetDesiredSpeed(speed)
end

-- Meta --

local locoMETA = FindMetaTable("CLuaLocomotion")

local old_IsClimbingOrJumping = locoMETA.IsClimbingOrJumping
function locoMETA:IsClimbingOrJumping()
  local nextbot = self:GetNextBot()
  if nextbot.IsDrGNextbot then
    return nextbot:IsClimbing() or old_IsClimbingOrJumping(self)
  else return old_IsClimbingOrJumping(self) end
end

local old_IsUsingLadder = locoMETA.IsUsingLadder
function locoMETA:IsUsingLadder()
  local nextbot = self:GetNextBot()
  if nextbot.IsDrGNextbot then
    local bool, ladder = nextbot:IsClimbingLadder()
    return bool
  else return old_IsUsingLadder(self) end
end

local old_SetDesiredSpeed = locoMETA.SetDesiredSpeed
function locoMETA:SetDesiredSpeed(speed)
  local nextbot = self:GetNextBot()
  if nextbot.IsDrGNextbot then
    nextbot:SetNW2Float("DrGBaseDesiredSpeed", speed)
    nextbot:SetNW2Float("DrGBaseSpeed", speed/nextbot:GetScale())
    return old_SetDesiredSpeed(self, speed)
  else return old_SetDesiredSpeed(self, speed) end
end

local AREA_LARGEENOUGH_CACHE = {}

function locoMETA:DrG_IsAreaLargeEnough(area)
  local nextbot = self:GetNextBot()
  if not nextbot.IsDrGNextbot then return true end
  local mins, maxs = nextbot:GetCollisionBounds()
  local str = tostring(mins).." // "..tostring(maxs).." // "..tostring(self:GetStepHeight())
  AREA_LARGEENOUGH_CACHE[str] = AREA_LARGEENOUGH_CACHE[str] or {}
  local largeEnoughCache = AREA_LARGEENOUGH_CACHE[str]
  local largeEnough = largeEnoughCache[area:GetID()]
  if isbool(largeEnough) then return largeEnough
  else
    local mins, maxs = nextbot:GetCollisionBounds()
    local sizeX = math.abs(mins.x-maxs.x)
    local sizeY = math.abs(mins.y-maxs.y)
    local info = area:GetExtentInfo()
    if sizeX > info.SizeX or sizeY > info.SizeY then
      local tr = nextbot:TraceHull(Vector(0, 0, 0), {
        start = area:GetCenter()+Vector(0, 0, info.SizeZ),
        collisiongroup = COLLISION_GROUP_DEBRIS, step = true
      })
      largeEnoughCache[area:GetID()] = not tr.HitWorld
      return not tr.HitWorld
    else
      largeEnoughCache[area:GetID()] = true
      return true
    end
  end
end
