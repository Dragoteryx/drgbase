
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
  return self:IsSpeedMore(self.WalkSpeed*1.5, true)
end

function ENT:IsClimbing()
  return self:GetDrGVar("DrGBaseClimbing")
end

local DebugAvoidance = CreateConVar("drgbase_debug_avoid", "0")
local DebugPath = CreateConVar("drgbase_debug_path", "0")

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
      self._DrGBaseMovingToPos = true
      local res = self:_MoveToPosGround(pos, options, callback)
      self._DrGBaseMovingToPos = false
      return res
    end
  end

  function ENT:_MoveToPosGround(pos, options, callback)
    options = options or {}
    options.tolerance = options.tolerance or 20
    options.lookahead = options.lookahead or 300
    if callback == nil then callback = function() end end
    if not navmesh.IsLoaded() then
      options.maxage = options.maxage or math.huge
      local delay = CurTime() + options.maxage
      while CurTime() < delay do
        if self:IsDying() then return "dying" end
        self._DrGBaseMovingToPos = false
        local res = callback(path, options)
        self._DrGBaseMovingToPos = true
        if isstring(res) then return res
        elseif isvector(res) then pos = res end
        if self:CanMove(self:GetPossessor()) then
          if not self:_DynamicAvoidance(true) then
            self:FaceTowards(pos)
            self:MoveTowards(pos)
          end
        end
        if self:GetRangeSquaredTo(pos) <= options.tolerance^2 then break
        else coroutine.yield() end
      end
    else
      if options.draw == nil then options.draw = GetConVar("developer"):GetBool() and DebugPath:GetBool() end
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
          if not self:_DynamicAvoidance(true) then
            if not self:OnMove(path, current, type) then
              local type = current.type
              if type > 0 then self:_Debug("path movement type: "..type..".") end
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
          end
        end
      	if options.draw then
          local bound1, bound2 = self:GetCollisionBounds()
          local center = self:GetPos() + (bound1 + bound2)/2
          debugoverlay.Line(center, current.pos, 0.05, Color(215, 215, 65), true)
          path:Draw()
        end
      	if self.loco:IsStuck() then
          self._DrGBaseMovingToPos = false
      		self:HandleStuck()
          self._DrGBaseMovingToPos = true
      		return "stuck"
      	end
      	if options.maxage and path:GetAge() > options.maxage then
          return "timeout"
      	end
        self._DrGBaseMovingToPos = false
        local res = callback(path, options)
        self._DrGBaseMovingToPos = true
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
    end
    if self:GetPos():DistToSqr(pos) <= options.tolerance^2 then return "ok"
    else return "moved" end
  end
  function ENT:OnMove(path) end

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
    local stopclimb = self:OnStartClimbing(ladder)
    if stopclimb == false then return end
    self:SetDrGVar("DrGBaseClimbing", true)
    local blockyaw = self:PossessionBlockYaw()
    self:PossessionBlockYaw(true)
    self:PlayAnimationAndMove(self.StartClimbAnimation, self.StartClimbAnimRate, function()
      return self:WhileClimbing(ladder, "start", self:GetCycle())
    end)
    local length = ladder:GetLength()
    while self:GetPos().z + stopclimb < ladder:GetTop().z and not self:IsDying() do
      if self:WhileClimbing(ladder, "climb", ladder:GetTop().z - self:GetPos().z - stopclimb) then break end
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
    self:PossessionBlockYaw(blockyaw)
  end

  function ENT:ClimbWall()
    if self:IsFlying() then return end
    if self:IsClimbing() then return end
    local hulls = self:CollisionHulls(true)
    if not hulls.NorthWest.Hit and not hulls.NorthEast.Hit then return end
    if self:OnStartClimbing() == false then return end
    local up = self:TraceHull({
      start = self:GetPos(),
      endpos = self:GetPos() + self:GetUp()*math.huge,
      filter = {self, self:GetWeapon()}
    })
    local height = math.DrG_MiddleVector(up.StartPos, up.HitPos):Length()
    local tr = {Hit = true}
    local incr = 0
    while tr.Hit do
      if incr > height then return end
      local start = self:GetPos() + Vector(0, 0, incr)
      tr = self:TraceHull({
        start = start,
        endpos = start + self:GetForward()*50,
        filter = {self, self:GetWeapon()}
      })
      incr = incr+1
    end
  end

  function ENT:OnStartClimbing(ladder) end
  function ENT:WhileClimbing(ladder) end
  function ENT:OnStopClimbing(ladder) end

  -- Hooks --

  function ENT:HandleStuck()
    if self:IsPossessed() then return end
    self:EnableDynamicAvoidance(true, 3)
    self.loco:ClearStuck()
  end

  -- Handlers --

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

  function ENT:EnableUpdateSpeed(bool)
    if bool == nil then return self._DrGBaseSpeedFetch
    elseif bool then self._DrGBaseSpeedFetch = true
    else self._DrGBaseSpeedFetch = false end
  end

  function ENT:UpdateSpeed(run)
    if self:IsFlying() then return self.FlightSpeed
    elseif self:IsClimbing() then return self.ClimbSpeed
    elseif run then return self.RunSpeed
    else return self.WalkSpeed end
  end

  function ENT:_HandleMovement()
    if self:EnableUpdateSpeed() then self:SetSpeed(self:UpdateSpeed(self:WantsToRun())) end
  end

  function ENT:EnableDynamicAvoidance(bool, duration)
    if bool == nil then return self._DrGBaseDynamicAvoidance end
    local previous = self:EnableDynamicAvoidance()
    if bool then self._DrGBaseDynamicAvoidance = true
    else self._DrGBaseDynamicAvoidance = false end
    if isnumber(duration) then
      self:Timer(duration, function()
        self:EnableDynamicAvoidance(previous)
      end)
    end
  end

  function ENT:_DynamicAvoidance(forwardOnly)
    if not self:EnableDynamicAvoidance() then return end
    if self:IsPossessed() then return end
    if not self:CanMove(self:GetPossessor()) then return end
    local hulls = self:CollisionHulls(nil, forwardOnly)
    if GetConVar("developer"):GetBool() and DebugAvoidance:GetBool() then
      local bound1, bound2 = self:GetCollisionBounds()
      if bound1.z < bound2.z then
        local temp = bound1
        bound1 = bound2
        bound2 = temp
      end
      bound2.z = self.loco:GetStepHeight()
      for k, hull in pairs(hulls) do
        local color = hull.Hit and DrGBase.Colors.Red or DrGBase.Colors.Green
        color = color:ToVector():ToColor()
        color.a = 0
        debugoverlay.Box(hull.HitPos, bound2, bound1, 0.05, color, true)
      end
    end
    local direction = ""
    if forwardOnly then
      if hulls.NorthWest.Hit and hulls.NorthEast.Hit then
        direction = "N"
        self:GoBackward()
      elseif hulls.NorthWest.Hit then
        direction = "NW"
        self:GoBackward()
        self:StrafeRight()
      elseif hulls.NorthEast.Hit then
        direction = "NE"
        self:GoBackward()
        self:StrafeLeft()
      else return false, direction, hulls end
      self:_Debug("avoiding obstacle "..direction..".")
      return true, direction, hulls
    else
      local nbHit = 0
      for k, tr in pairs(hulls) do
        if tr.Hit then nbHit = nbHit+1 end
      end
      if nbHit == 3 then
        if not hulls.NorthWest.Hit then
          direction = "SE"
          self:GoForward()
          self:StrafeLeft()
        elseif not hulls.NorthEast.Hit then
          direction = "SW"
          self:GoForward()
          self:StrafeRight()
        elseif not hulls.SouthEast.Hit then
          direction = "NW"
          self:GoBackward()
          self:StrafeRight()
        elseif not hulls.SouthWest.Hit then
          direction = "NE"
          self:GoBackward()
          self:StrafeLeft()
        end
      elseif nbHit == 2 then
        if hulls.NorthWest.Hit and hulls.NorthEast.Hit then
          direction = "N"
          self:GoBackward()
        elseif hulls.NorthEast.Hit and hulls.SouthEast.Hit then
          direction = "E"
          self:StrafeLeft()
        elseif hulls.SouthEast.Hit and hulls.SouthWest.Hit then
          direction = "S"
          self:GoForward()
        elseif hulls.SouthWest.Hit and hulls.NorthWest.Hit then
          direction = "W"
          self:StrafeRight()
        end
      elseif nbHit == 1 then
        if hulls.SouthEast.Hit then
          direction = "SE"
          self:GoForward()
          self:StrafeLeft()
        elseif hulls.SouthEast.Hit then
          direction = "SW"
          self:GoForward()
          self:StrafeRight()
        elseif hulls.NorthWest.Hit then
          direction = "NW"
          self:GoBackward()
          self:StrafeRight()
        elseif hulls.NorthEast.Hit then
          direction = "SE"
          self:GoBackward()
          self:StrafeLeft()
        end
      end
      local avoided = nbHit == 3 or nbHit == 2 or nbHit == 1
      if avoided then self:_Debug("avoiding obstacle "..direction..".") end
      return avoided, direction, hulls
    end
  end

else



end
