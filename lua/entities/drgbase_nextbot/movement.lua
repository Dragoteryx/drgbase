
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
function ENT:SpeedCached(scale)
  if CurTime() < self._DrGBaseLastSpeedCacheDelay then
    return self._DrGBaseLastSpeedCache
  else
    self._DrGBaseLastSpeedCacheDelay = CurTime() + 0.1
    self._DrGBaseLastSpeedCache = self:Speed(scale)
    return self._DrGBaseLastSpeedCache
  end
end

function ENT:IsFlying()
  return false
end

function ENT:IsMoving()
  return self:SpeedSqr() ~= 0
end

function ENT:IsSprinting()
  return self:SpeedCached(true) > self.WalkSpeed*self:GetScale()*1.1
end

if SERVER then

  -- Getters --

  function ENT:IsMovingForward()
    if not self:IsMoving() then return false end
    if self:IsPossessed() then return self:PossessorForward() end
    return math.Round(DrGBase.Math.VectorsAngle(self:GetForward(), self.loco:GetGroundMotionVector())) < 90
  end

  function ENT:IsMovingBackward()
    if not self:IsMoving() then return false end
    if self:IsPossessed() then return self:PossessorBackward() end
    return math.Round(DrGBase.Math.VectorsAngle(self:GetForward(), self.loco:GetGroundMotionVector())) > 90
  end

  function ENT:IsMovingLeft()
    if not self:IsMoving() then return false end
    if self:IsPossessed() then return self:PossessorLeft() end
    return math.Round(DrGBase.Math.VectorsAngle(self:GetRight(), self.loco:GetGroundMotionVector())) > 90
  end

  function ENT:IsMovingRight()
    if not self:IsMoving() then return false end
    if self:IsPossessed() then return self:PossessorRight() end
    return math.Round(DrGBase.Math.VectorsAngle(self:GetRight(), self.loco:GetGroundMotionVector())) < 90
  end

  function ENT:IsMovingUp()
    return self:GetVelocity().z > 0
  end

  function ENT:IsMovingDown()
    return self:GetVelocity().z < 0
  end

  -- Setters --

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

  -- Movements --

  function ENT:MoveToPos(pos, options, callback)
    if not navmesh.IsLoaded() then return "failed" end
    options = options or {}
    options.lookahead = options.lookahead or 300
    options.tolerance = options.tolerance or 20
    if callback == nil then callback = function() end end
    self._DrGBasePath = self._DrGBasePath or Path("Follow")
    local path = self._DrGBasePath
    path:SetMinLookAheadDistance(options.lookahead)
    path:SetGoalTolerance(options.tolerance)
    if not IsValid(path) or pos:DistToSqr(path:LastSegment().pos) > math.pow(options.tolerance, 2) then
      self:_Debug("generating path.")
      path:DrG_Compute(self, pos, options.generator)
    else path:ResetAge() end
    if not IsValid(path) then return "failed" end
    while IsValid(path) do
      local current = path:GetCurrentGoal()
      if self:IsDying() then return "dying" end
      if self:CanMove(self:GetPossessor()) then
        local type = current.type
        --if type > 0 then print(type) end
        if type == 4 then
          local ladder = current.ladder
  				if IsValid(ladder) and
          self:GetPos():DistToSqr(current.pos) <= math.pow(options.tolerance, 2) then
  					self:ClimbLadder(current.ladder, function()
              if options.draw then path:Draw() end
            end)
            self:InvalidatePath()
          else path:Update(self) end
        elseif type == 5 then
          self.loco:FaceTowards(self:GetPos() + current.forward)
          self.loco:Approach(self:GetPos() + current.forward, 1)
  			else path:Update(self) end
      end
    	if options.draw then
        local bound1, bound2 = self:GetCollisionBounds()
        local center = self:GetPos() + (bound1 + bound2)/2
        debugoverlay.Line(center, current.pos, 0.05, Color(215, 215, 65), true)
        path:Draw()
      end
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
          path:DrG_Compute(self, pos, options.generator)
        else path:ResetAge() end
      end
    	coroutine.yield()
    end
    if self:GetPos():DistToSqr(pos) <= math.pow(options.tolerance, 2) then return "ok"
    else return "moved" end
  end

  function ENT:FollowEntity(ent, options, callback)
    if callback == nil then callback = function() end end
    return self:MoveToPos(ent:GetPos(), options, function(path)
      if not IsValid(ent) then return "invalid" end
      local res = callback(path, options)
      if not IsValid(ent) then return "invalid" end
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
    self:GoBackward()
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

  -- Climbing --

  function ENT:IsClimbing()
    return self._DrGBaseClimbing
  end

  function ENT:ClimbLadder(ladder)
    if self:IsClimbing() then return end
    if self:OnStartClimbing(ladder) ~= false then
      self._DrGBaseClimbing = true
      local length = ladder:GetLength()
      self:PlayAnimationAndMove(self.StartClimbAnimation, self.StartClimbAnimRate, function()
        self:WhileClimbing(length, ladder)
      end)
      while self:GetPos().z + self.StopClimbing < ladder:GetTop().z and not self:IsDying() do
        self:WhileClimbing(ladder:GetTop().z - self:GetPos().z - self.StopClimbing, ladder)
        self.loco:FaceTowards(ladder:GetPosAtHeight(self:GetPos().z))
  		  self:SetPos(ladder:GetPosAtHeight(self:GetSpeed()/50 + self:GetPos().z))
        coroutine.wait(0.025)
      end
      self:PlayAnimationAndMove(self.StopClimbAnimation, self.StopClimbAnimRate, function()
        self:WhileClimbing(0, ladder)
      end)
      self:OnStopClimbing(ladder)
      local pos = self:GetPos()
      self:SetPos(navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos))
    end
    self._DrGBaseClimbing = false
  end
  function ENT:OnStartClimbing(ladder) end
  function ENT:WhileClimbing(ladder) end
  function ENT:OnStopClimbing(ladder) end

  -- Handlers --

  function ENT:EnableSpeedFetch(bool)
    if bool == nil then return self._DrGBaseSpeedFetch
    elseif bool then self._DrGBaseSpeedFetch = true
    else self._DrGBaseSpeedFetch = false end
  end

  function ENT:ShouldSprint(state)
    return state == DRGBASE_STATE_AI_FIGHT or
    state == DRGBASE_STATE_AI_AVOID
  end

  function ENT:_HandleMovement()
    if not self:EnableSpeedFetch() then return end
    local sprint
    if self:IsPossessed() then
      sprint = self:GetPossessor():KeyDown(IN_SPEED)
    else sprint = self:ShouldSprint(self:GetState()) end
    local speed
    if self:IsFlying() then speed = self:FlightSpeed(sprint)
    elseif self:IsClimbing() then speed = self:ClimbingSpeed(sprint)
    else speed = self:GroundSpeed(sprint) end
    self:SetSpeed(speed)
  end
  function ENT:GroundSpeed(sprint)
    if sprint then return self.RunSpeed
    else return self.WalkSpeed end
  end
  function ENT:FlightSpeed()
    return 0
  end
  function ENT:ClimbingSpeed()
    return self.ClimbSpeed
  end

else



end
