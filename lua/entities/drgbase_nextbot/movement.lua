
function ENT:GetSpeed()
  return self:GetDrGVar("DrGBaseSpeed")
end

function ENT:Speed(scale)
  local speed = self:GetVelocity():Length()
  if scale then return math.Round(speed/self:GetScale())
  else return math.Round(speed) end
end
function ENT:SpeedSqr()
  return math.Round(self:GetVelocity():LengthSqr())
end

function ENT:IsFlying()
  return false
end

function ENT:IsMoving()
  return self:SpeedSqr() ~= 0
end

function ENT:IsMovingForward()
  if SERVER and self:IsPossessed() or
  CLIENT and self:IsPossessedByLocalPlayer() then
    return self:GetPossessor():KeyDown(IN_FORWARD) and
    not self:GetPossessor():KeyDown(IN_BACK)
  else return true end
end

function ENT:IsMovingBackward()
  if SERVER and self:IsPossessed() or
  CLIENT and self:IsPossessedByLocalPlayer() then
    return self:GetPossessor():KeyDown(IN_BACK) and
    not self:GetPossessor():KeyDown(IN_FORWARD)
  else return false end
end

function ENT:IsMovingLeft()
  if SERVER and self:IsPossessed() or
  CLIENT and self:IsPossessedByLocalPlayer() then
    return self:GetPossessor():KeyDown(IN_MOVELEFT) and
    not self:GetPossessor():KeyDown(IN_MOVERIGHT)
  else return false end
end

function ENT:IsMovingRight()
  if SERVER and self:IsPossessed() or
  CLIENT and self:IsPossessedByLocalPlayer() then
    return self:GetPossessor():KeyDown(IN_MOVERIGHT) and
    not self:GetPossessor():KeyDown(IN_MOVELEFT)
  else return false end
end

if SERVER then

  function ENT:CanMove()
    return true
  end

  function ENT:SetSpeed(speed)
    if speed == nil then return end
    if speed < 0 then speed = 0 end
    if speed ~= self:GetDrGVar("DrGBaseSpeed") then
      self:SetDrGVar("DrGBaseSpeed", speed)
      self:_Debug("speed set to "..speed..".")
    end
    return self.loco:SetDesiredSpeed(speed*self:GetScale())
  end

  function ENT:GetPath()
    return self._DrGBasePath
  end

  function ENT:InvalidatePath()
    if IsValid(self._DrGBasePath) then
      self._DrGBasePath:Invalidate()
    end
  end

  function ENT:MoveToPos(pos, options, callback)
    options = options or {}
    if callback == nil then callback = function() end end
    options.lookahead = options.lookahead or 300
    options.tolerance = options.tolerance or 20
    self._DrGBasePath = self._DrGBasePath or Path("Follow")
    local path = self._DrGBasePath
    path:SetMinLookAheadDistance(options.lookahead)
    path:SetGoalTolerance(options.tolerance)
    if not IsValid(path) or pos:DistToSqr(path:LastSegment().pos) > math.pow(options.tolerance, 2) then
      self:_Debug("generating path.")
      DrGBase.Navmesh.ComputePath(path, self, pos, options.generator)
    else path:ResetAge() end
    if not IsValid(path) then return "failed" end
    while IsValid(path) do
      if self:IsDying() then return "dying" end
      if self:CanMove(self:GetPossessor()) then
    	  path:Update(self)
      end
    	if options.draw then path:Draw() end
    	if self.loco:IsStuck() then
    		self:HandleStuck()
    		return "stuck"
    	end
    	if options.maxage and path:GetAge() > options.maxage then
        return "timeout"
    	end
      local res = callback(path, options)
      if isstring(res) then return res
      elseif isvector(res) then pos = res end
      if options.repath and path:GetAge() > options.repath then
        if not IsValid(path) or pos:DistToSqr(path:LastSegment().pos) > math.pow(options.tolerance, 2) then
          self:_Debug("generating path.")
          DrGBase.Navmesh.ComputePath(path, self, pos, options.generator)
        else path:ResetAge() end
      end
    	coroutine.yield()
    end
    if self:GetPos():DistToSqr(pos) <= math.pow(options.tolerance, 2) then return "ok"
    else return "moved" end
  end

  function ENT:FollowEntity(ent, options, callback)
    self:MoveToPos(ent:GetPos(), options, function(path)
      if not IsValid(ent) then return "invalid" end
      local res = callback(path, options)
      if isstring(res) then return res
      else return ent:GetPos() end
    end)
  end

  function ENT:StepAwayFromPos(pos)
    if not self:CanMove(self:GetPossessor()) then return end
    local tr = util.TraceLine({
      start = self:GetPos() + Vector(0, 0, 10),
      endpos = pos + Vector(0, 0, 10),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    })
    self.loco:FaceTowards(pos)
    self.loco:Approach(self:GetPos() + tr.Normal*-1, 1)
  end

  function ENT:FacePos(pos)
    local angle = util.TraceLine({
      start = self:GetPos() + Vector(0, 0, 1),
      endpos = pos + Vector(0, 0, 1),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    }).Normal:Angle()
    angle.p = 0
    angle.r = 0
    self:SetAngles(angle)
  end

  function ENT:FaceEntity(ent)
    self:FacePos(ent:GetPos())
  end

  function ENT:GoForward()
    if not self:CanMove(self:GetPossessor()) then return end
    self.loco:Approach(self:GetPos() + self:GetForward(), 1)
  end

  function ENT:GoBackward()
    if not self:CanMove(self:GetPossessor()) then return end
    self.loco:Approach(self:GetPos() + self:GetForward()*-1, 1)
  end

  function ENT:StrafeLeft()
    if not self:CanMove(self:GetPossessor()) then return end
    self.loco:Approach(self:GetPos() + self:GetRight()*-1, 1)
  end

  function ENT:StrafeRight()
    if not self:CanMove(self:GetPossessor()) then return end
    self.loco:Approach(self:GetPos() + self:GetRight(), 1)
  end

  -- Handlers --

  function ENT:EnableSpeedFetch(bool)
    if bool == nil then return self._DrGBaseSpeedFetch
    elseif bool then self._DrGBaseSpeedFetch = true
    else self._DrGBaseSpeedFetch = false end
  end

  function ENT:_HandleMovement()
    if not self:EnableSpeedFetch() then return end
    local speed
    if self:IsPossessed() then
      local possessor = self:GetPossessor()
      if self:IsFlying() then speed = self:PossessionFlightSpeed(possessor:KeyDown(IN_SPEED))
      else speed = self:PossessionGroundSpeed(possessor:KeyDown(IN_SPEED)) end
    elseif self:IsFlying() then speed = self:FlightSpeed(self:GetState())
    else speed = self:GroundSpeed(self:GetState()) end
    self:SetSpeed(speed)
  end
  function ENT:GroundSpeed() end
  function ENT:FlightSpeed() end
  function ENT:PossessionGroundSpeed() end
  function ENT:PossessionFlightSpeed() end

else



end
