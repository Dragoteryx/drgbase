
function ENT:GetSpeed()
  return self:GetDrGVar("DrGBaseSpeed")
end

function ENT:Speed()
  return self:GetVelocity():Length()
end

function ENT:SpeedSqr()
  return self:GetVelocity():LengthSqr()
end

function ENT:IsMoving()
  return self:SpeedSqr() ~= 0
end

function ENT:IsFlying()
  return false
end

if SERVER then

  function ENT:SetSpeed(speed)
    if speed == nil then return end
    if speed < 0 then speed = 0 end
    if speed == self:GetDrGVar("DrGBaseSpeed") then return end
    self:SetDrGVar("DrGBaseSpeed", speed)
    self:_Debug("speed set to "..speed..".")
    return self.loco:SetDesiredSpeed(speed)
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
    	path:Update(self)
    	if options.draw then path:Draw() end
    	if self.loco:IsStuck() then
    		self:OnStuck()
    		return "stuck"
    	end
    	if options.maxage and path:GetAge() > options.maxage then
        return "timeout"
    	end
      local res = callback(options)
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
    self:MoveToPos(ent:GetPos(), options, function()
      if not IsValid(ent) then return "invalid" end
      local res = callback(options)
      if isstring(res) then return res
      else return ent:GetPos() end
    end)
  end

  function ENT:StepAwayFromPos(pos)
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
    self.loco:Approach(self:GetPos() + self:GetForward(), 1)
  end

  function ENT:GoBackward()
    self.loco:Approach(self:GetPos() + self:GetForward()*-1, 1)
  end

  function ENT:StrafeLeft()
    self.loco:Approach(self:GetPos() + self:GetRight()*-1, 1)
  end

  function ENT:StrafeRight()
    self.loco:Approach(self:GetPos() + self:GetRight(), 1)
  end

  function ENT:TurnLeft()
    self:SetAngles(self:GetAngles() + Angle(0, 2, 0))
  end

  function ENT:TurnRight()
    self:SetAngles(self:GetAngles() + Angle(0, -2, 0))
  end

  -- Handlers --

  function ENT:_HandleMovement()
    if self:IsPossessed() then
      local possessor = self:GetPossessor()
      self:SetSpeed(self:PossessionGroundSpeed(possessor:KeyDown(IN_SPEED)))
    else
      self:SetSpeed(self:GroundSpeed(self:GetState()))
    end
  end
  function ENT:GroundSpeed() end
  function ENT:FlightSpeed() end
  function ENT:PossessionGroundSpeed() end
  function ENT:PossessionFlightSpeed() end
  function ENT:PossessionFlightBuoyancy() end
  function ENT:OnStartFlying() end
  function ENT:OnStopFlying() end

else



end
