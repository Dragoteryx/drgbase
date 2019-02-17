
function ENT:GetSpeed()
  return self:GetDrGVar("DrGBaseSpeed")
end

function ENT:Speed(scale)
  local speed = self:GetVelocity():Length()
  if scale then return math.Round(speed*self:GetScale())
  else return math.Round(speed) end
end
function ENT:SpeedSqr(scale)
  if not scale then return math.Round(self:GetVelocity():LengthSqr())
  else return math.Round((self:GetVelocity()/self:GetScale()):LengthSqr()) end
end
function ENT:IsSpeedMore(speed, scale)
  return speed^2 < self:SpeedSqr(scale)
end
function ENT:IsSpeedLess(speed, scale)
  return speed^2 > self:SpeedSqr(scale)
end
function ENT:IsSpeedEqual(speed, scale)
  return speed^2 == self:SpeedSqr(scale)
end

function ENT:IsMoving()
  return self:SpeedSqr() ~= 0
end

function ENT:IsRunning()
  return self:IsSpeedMore(self.WalkSpeed*1.1, true)
end

function ENT:IsClimbing()
  return self:GetDrGVar("DrGBaseClimbing")
end

if SERVER then

  -- Getters --

  function ENT:IsMovingForward()
    if not self:IsMoving() then return false end
    if self:IsPossessed() then return self:PossessorForward() end
    return math.Round(math.DrG_DegreeAngle(self:GetForward(), self.loco:GetGroundMotionVector())) < 90
  end

  function ENT:IsMovingBackward()
    if not self:IsMoving() then return false end
    if self:IsPossessed() then return self:PossessorBackward() end
    return math.Round(math.DrG_DegreeAngle(self:GetForward(), self.loco:GetGroundMotionVector())) > 90
  end

  function ENT:IsMovingLeft()
    if not self:IsMoving() then return false end
    if self:IsPossessed() then return self:PossessorLeft() end
    return math.Round(math.DrG_DegreeAngle(self:GetRight(), self.loco:GetGroundMotionVector())) > 90
  end

  function ENT:IsMovingRight()
    if not self:IsMoving() then return false end
    if self:IsPossessed() then return self:PossessorRight() end
    return math.Round(math.DrG_DegreeAngle(self:GetRight(), self.loco:GetGroundMotionVector())) < 90
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
    if not IsValid(self:GetPath()) then return end
    self._DrGBasePath:Invalidate()
  end
  function ENT:DrawPath()
    if not IsValid(self:GetPath()) then return end
    self:GetPath():Draw()
  end

  -- Movements --

  function ENT:MoveToPos(pos, options, callback)
    if self:IsFlying() then
      local vector, data = math.DrG_ParabolicTrajectory(self:GetPos(), pos, {
        magnitude = self:GetRangeTo(pos), recursive = true
      })
      self:FlyForwardTo(self:GetPos() + vector)
    else
      if not navmesh.IsLoaded() then return "failed" end
      options = options or {}
      options.lookahead = options.lookahead or 300
      options.tolerance = options.tolerance or 20
      if callback == nil then callback = function() end end
      self._DrGBasePath = self._DrGBasePath or Path("Follow")
      local path = self._DrGBasePath
      path:SetMinLookAheadDistance(options.lookahead)
      path:SetGoalTolerance(options.tolerance)
      if not IsValid(path) or pos:DistToSqr(path:LastSegment().pos) > options.tolerance^2 then
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
            self:GetPos():DistToSqr(ladder:GetPosAtHeight(self:GetPos().z)) <= options.tolerance^2 then
    					self:ClimbLadder(current.ladder)
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
          if not IsValid(path) or pos:DistToSqr(path:LastSegment().pos) > options.tolerance^2 then
            self:_Debug("generating path.")
            path:DrG_Compute(self, pos, options.generator)
          else path:ResetAge() end
        end
      	coroutine.yield()
      end
      if self:GetPos():DistToSqr(pos) <= options.tolerance^2 then return "ok"
      else return "moved" end
    end
  end

  function ENT:FollowEntity(ent, options, callback)
    if self:IsFlying() then return end
    if callback == nil then callback = function() end end
    return self:MoveToPos(ent:GetPos(), options, function(path)
      if not IsValid(ent) then return "invalid" end
      local res = callback(path, options)    
      if isstring(res) then return res
      elseif not IsValid(ent) then return "invalid"
      else return ent:GetPos() end
    end)
  end

  function ENT:MoveTowards(pos, face)
    if not self:CanMove(self:GetPossessor()) then return end
    if self:IsFlying() then self:FlyTowards(pos, face)
    else
      self.loco:Approach(pos, 1)
      if face then self.loco:FaceTowards(pos) end
    end
  end

  function ENT:StepAwayFromPos(pos)
    if self:IsFlying() then return end
    if not self:CanMove(self:GetPossessor()) then return end
    self.loco:FaceTowards(pos)
    self:GoBackward()
  end

  function ENT:FacePos(pos)
    local angle = math.DrG_AngleVectors(self:GetPos(), pos)
    self:SetAngles(Angle(0, angle.y, 0))
  end

  function ENT:FaceEntity(ent)
    self:FacePos(ent:GetPos())
  end

  function ENT:FaceTowards(pos)
    self.loco:FaceTowards(pos)
  end

  function ENT:FaceTowardsEntity(ent)
    self:FaceTowards(ent:GetPos())
  end

  function ENT:GoForward()
    if not self:CanMove(self:GetPossessor()) then return end
    self:MoveTowards(self:GetPos() + self:GetForward())
  end

  function ENT:GoBackward()
    if not self:CanMove(self:GetPossessor()) then return end
    self:MoveTowards(self:GetPos() - self:GetForward())
  end

  function ENT:StrafeLeft()
    if not self:CanMove(self:GetPossessor()) then return end
    self:MoveTowards(self:GetPos() - self:GetRight())
  end

  function ENT:StrafeRight()
    if not self:CanMove(self:GetPossessor()) then return end
    self:MoveTowards(self:GetPos() + self:GetRight())
  end

  -- Climbing --

  function ENT:ClimbLadder(ladder)
    if self:IsFlying() then return end
    if self:IsClimbing() then return end
    if self:OnStartClimbing(ladder) == false then return end
    self:SetDrGVar("DrGBaseClimbing", true)
    self:PlayAnimationAndMove(self.StartClimbAnimation, self.StartClimbAnimRate, function()
      return self:WhileClimbing(ladder, "start", self:GetCycle())
    end)
    local length = ladder:GetLength()
    while self:GetPos().z + self.StopClimb < ladder:GetTop().z and not self:IsDying() do
      if self:WhileClimbing(ladder, "climb", ladder:GetTop().z - self:GetPos().z - self.StopClimb) then break end
      self.loco:FaceTowards(ladder:GetPosAtHeight(self:GetPos().z))
		  self:SetPos(ladder:GetPosAtHeight(self:GetSpeed()/50 + self:GetPos().z))
      coroutine.wait(0.025)
    end
    self:PlayAnimationAndMove(self.StopClimbAnimation, self.StopClimbAnimRate, function()
      return self:WhileClimbing(ladder, "stop", self:GetCycle())
    end)
    self:OnStopClimbing(ladder)
    local pos = self:GetPos()
    self:SetPos(navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos))
    self:SetDrGVar("DrGBaseClimbing", false)
  end
  function ENT:OnStartClimbing(ladder) end
  function ENT:WhileClimbing(ladder) end
  function ENT:OnStopClimbing(ladder) end

  -- Handlers --

  function ENT:EnableUpdateSpeed(bool)
    if bool == nil then return self._DrGBaseSpeedFetch
    elseif bool then self._DrGBaseSpeedFetch = true
    else self._DrGBaseSpeedFetch = false end
  end

  function ENT:ShouldRun(state)
    return state == DRGBASE_STATE_AI_FIGHT or
    state == DRGBASE_STATE_AI_AVOID
  end

  function ENT:WantsToRun()
    local run
    if self:IsPossessed() then run = self:GetPossessor():KeyDown(IN_SPEED)
    else run = self:ShouldRun(self:GetState()) end
    return run
  end

  function ENT:_HandleMovement()
    if self:EnableUpdateSpeed() then self:SetSpeed(self:UpdateSpeed(self:WantsToRun())) end
  end

  function ENT:UpdateSpeed(run)
    if self:IsFlying() then return self.FlightSpeed
    elseif self:IsClimbing() then return self.ClimbSpeed
    elseif run then return self.RunSpeed
    else return self.WalkSpeed end
  end

else



end
