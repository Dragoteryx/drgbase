
-- Getters/setters --

function ENT:GetSpeed()
  return self:GetNW2Float("DrGBaseSpeed")
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
function ENT:IsSpeedMoreEqual(speed, scale)
  return self:IsSpeedEqual(speed, scale) or self:IsSpeedMore(speed, scale)
end
function ENT:IsSpeedLessEqual(speed, scale)
  return self:IsSpeedEqual(speed, scale) or self:IsSpeedLess(speed, scale)
end

function ENT:IsMoving()
  return self:IsSpeedMore(0)
end
function ENT:IsRunning()
  return self:IsOnGround() and self:IsSpeedMoreEqual((self.WalkSpeed + self.RunSpeed)/2, true)
end

function ENT:IsClimbing()
  return self:GetNW2Bool("DrGBaseClimbing")
end
function ENT:IsClimbingUp()
  return self:IsClimbing() and not self:IsClimbingDown()
end
function ENT:IsClimbingDown()
  return self:IsClimbing() and self:GetNW2Bool("DrGBaseClimbingDown")
end

function ENT:IsFlying()
  return false
end

-- Functions --

-- Hooks --

-- Handlers --

function ENT:_InitMovements()
  if CLIENT then return end
  self._DrGBaseUpdateSpeed = true
  self:LoopTimer(0.1, self._HandleSpeed)
end

if SERVER then

  -- Getters/setters --

  function ENT:IsUpdatingSpeed()
    return self._DrGBaseUpdateSpeed or false
  end
  function ENT:SetUpdateSpeed(bool)
    if bool then self._DrGBaseUpdateSpeed = true
    else self._DrGBaseUpdateSpeed = false end
  end

  function ENT:SetSpeed(speed)
    self:SetNW2Float("DrGBaseSpeed", speed)
    self.loco:SetDesiredSpeed(speed*self:GetScale())
  end

  function ENT:IsClimbingLadder(ladder)
    if IsValid(ladder) then
      return self:IsClimbingLadder() and ladder == self._DrGBaseClimbLadder
    else
      if not self:IsClimbing() then return false end
      return IsValid(self._DrGBaseClimbLadder), self._DrGBaseClimbLadder
    end
  end
  function ENT:IsClimbingLedge()
    return self:IsClimbing() and not IsValid(self._DrGBaseClimbLadder)
  end

  -- Functions --

  function ENT:Approach(pos, nb)
    if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
    if self:OnMove(pos) == false then return end
    --[[local tr = self:TraceLine((pos - self:GetPos())*999999)
    if IsValid(tr.Entity) and tr.Entity:DrG_IsDoor() then
      self:OnDoor(tr.Entity, tr.Entity:DrG_DoorOpener(self))
    end]]
    self.loco:Approach(pos, nb or 1)
  end
  function ENT:FaceTowards(pos)
    if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
    if self:OnMove(pos) == false then return end
    self.loco:FaceTowards(pos)
  end
  function ENT:FaceInstant(pos)
    if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
    local angle = (pos - self:GetPos()):Angle()
    self:SetAngles(Angle(0, angle.y, 0))
  end
  function ENT:FaceTo(toface)
    while true do
      local pos = toface
      if isentity(pos) then
        if not IsValid(pos) then return end
        pos = pos:NearestPoint(self:GetPos())
      end
      local angle = (pos - self:GetPos()):Angle()
      if math.NormalizeAngle(math.Round(self:GetAngles().y)) == math.NormalizeAngle(math.Round(angle.y)) then return end
      self:FaceTowards(pos)
      self:YieldCoroutine(true)
    end
  end

  function ENT:MoveTowards(pos)
    if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
    self:FaceTowards(pos)
    self:Approach(pos)
  end
  function ENT:MoveForwardTo(pos)
    if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
    self:FaceTowards(pos)
    self:MoveForward()
  end
  function ENT:MoveAwayFrom(pos, face)
    if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
    local away = self:GetPos()*2 - pos
    if face then
      self:FaceTowards(pos)
      self:Approach(away)
    else self:MoveTowards(away) end
  end

  function ENT:MoveForward()
    self:Approach(self:GetPos() + self:GetForward())
  end
  function ENT:MoveBackward()
    self:Approach(self:GetPos() - self:GetForward())
  end
  function ENT:MoveRight()
    self:Approach(self:GetPos() + self:GetRight())
  end
  function ENT:MoveLeft()
    self:Approach(self:GetPos() - self:GetRight())
  end

  function ENT:ObstacleAvoidance(forwardOnly, duration, callback)
    if not isnumber(duration) or duration <= 0 then
      local hulls = self:CollisionHulls(nil, forwardOnly)
      if forwardOnly then
        if hulls.NorthWest.Hit and hulls.NorthEast.Hit then
          direction = "N"
          self:MoveBackward()
        elseif hulls.NorthWest.Hit then
          direction = "NW"
          self:MoveBackward()
          self:MoveRight()
        elseif hulls.NorthEast.Hit then
          direction = "NE"
          self:MoveBackward()
          self:MoveLeft()
        else return false end
        return true, direction
      else
        local nbHit = 0
        for k, tr in pairs(hulls) do
          if tr.Hit then nbHit = nbHit+1 end
        end
        if nbHit == 3 then
          if not hulls.NorthWest.Hit then
            direction = "SE"
            self:MoveForward()
            self:MoveLeft()
          elseif not hulls.NorthEast.Hit then
            direction = "SW"
            self:MoveForward()
            self:MoveRight()
          elseif not hulls.SouthEast.Hit then
            direction = "NW"
            self:MoveBackward()
            self:MoveRight()
          elseif not hulls.SouthWest.Hit then
            direction = "NE"
            self:MoveBackward()
            self:MoveLeft()
          end
        elseif nbHit == 2 then
          if hulls.NorthWest.Hit and hulls.NorthEast.Hit then
            direction = "N"
            self:MoveBackward()
          elseif hulls.NorthEast.Hit and hulls.SouthEast.Hit then
            direction = "E"
            self:MoveLeft()
          elseif hulls.SouthEast.Hit and hulls.SouthWest.Hit then
            direction = "S"
            self:MoveForward()
          elseif hulls.SouthWest.Hit and hulls.NorthWest.Hit then
            direction = "W"
            self:MoveRight()
          end
        elseif nbHit == 1 then
          if hulls.SouthEast.Hit then
            direction = "SE"
            self:MoveForward()
            self:MoveLeft()
          elseif hulls.SouthEast.Hit then
            direction = "SW"
            self:MoveForward()
            self:MoveRight()
          elseif hulls.NorthWest.Hit then
            direction = "NW"
            self:MoveBackward()
            self:MoveRight()
          elseif hulls.NorthEast.Hit then
            direction = "SE"
            self:MoveBackward()
            self:MoveLeft()
          end
        elseif nbHit == 0 then return false end
        return true, direction or "ALL"
      end
    else
      if callback == nil then callback = function() end end
      local delay = CurTime() + duration
      local direction
      while CurTime() < delay do
        if self:IsDying() then return false end
        if callback(delay - CurTime(), direction) then return end
        local avoided, direction = self:ObstacleAvoidance(forwardOnly)
        if not avoided then return false end
        self:YieldCoroutine(true)
      end
      return true
    end
  end

  -- Complex --

  function ENT:MoveCloserTo(pos, options)
    if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
    if self.loco:IsStuck() then
      self:HandleStuck(pos)
      return "stuck"
    end
    options = options or {}
    options.tolerance = options.tolerance or 20
    local selfpos = self:GetPos()
    if navmesh.IsLoaded() and (not self:IsOnGround() or
    selfpos:DistToSqr(navmesh.GetNearestNavArea(selfpos):GetClosestPointOnArea(selfpos)) < options.tolerance^2) then
      pos = navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos) or pos
      options.lookahead = options.lookahead or 300
      local path = self:GetPath()
      path:SetGoalTolerance(options.tolerance)
      path:SetMinLookAheadDistance(options.lookahead)
      if not IsValid(path) then
        path:Compute(self, pos, options.generator)
      else
        local tolerance = (options.tolerance*(path:LastSegment().distanceFromStart-path:GetCurrentGoal().distanceFromStart))/200
        if tolerance < options.tolerance then tolerance = options.tolerance end
        if path:GetEnd():DistToSqr(pos) > tolerance^2 then
          path:Compute(self, pos, options.generator)
        end
      end
      if not self._DrGBaseComputeSuccess and not IsValid(path) then return "unreachable" end
      if options.draw then path:Draw() end
      local current = path:GetCurrentGoal()
      local ladder = current.ladder
      local ledge = self:FindLedge()
      if current.type == 4 then
        if not self.ClimbLaddersUp then return "unreachable" end
        if self:GetHullRangeSquaredTo(ladder:GetBottom()) < self.LaddersUpDistance^2 then
          self:ClimbLadderUp(ladder)
          path:Invalidate()
          return "ladder_up", ladder
        elseif not self:ObstacleAvoidance(true) then
          self:MoveTowards(current.pos)
          return "moving", ladder
        else return "obstacle" end
      elseif current.type == 5 then
        if not self.ClimbLaddersDown then
          local drop = ladder:GetTop().z - ladder:GetBottom().z
          if drop <= self.loco:GetDeathDropHeight() then
            self:MoveTowards(self:GetPos() + current.forward)
            return "moving"
          else return "unreachable" end
        elseif self:GetHullRangeSquaredTo(ladder:GetTop()) < self.LaddersDownDistance^2 then
          self:ClimbLadderDown(ladder)
          path:Invalidate()
          return "ladder_down", ladder
        elseif not self:ObstacleAvoidance(true) then
          self:MoveTowards(current.pos)
          return "moving", ladder
        else return "obstacle" end
      elseif isvector(ledge) then
        self:ClimbLedge(ledge)
        path:Invalidate()
        return "ledge", ledge
      elseif not self._DrGBaseLastComputeSuccess and
      path:GetCurrentGoal().distanceFromStart == path:LastSegment().distanceFromStart then
        return "unreachable"
      elseif not self:ObstacleAvoidance(true) then
        path:Update(self)
        if not IsValid(path) then return "reached"
        else return "moving" end
      else return "obstacle" end
    else
      local ledge = self:FindLedge()
      if isvector(ledge) then
        self:ClimbLedge(ledge)
      elseif not self:ObstacleAvoidance(true) then
        self:MoveTowards(pos)
        if self:GetHullRangeSquaredTo(pos) < options.tolerance^2 then
          return "reached"
        else return "moving" end
      else return "obstacle" end
    end
  end

  function ENT:_GoTo(pos, options, callback)
    options = options or {}
    options.maxage = options.maxage or math.huge
    if not isfunction(callback) then callback = function() end end
    local stop = CurTime() + options.maxage
    while true do
      if not isvector(pos) and not IsValid(pos) then
        return "invalid"
      end
      if CurTime() > stop then return "timeout" end
      local str = callback()
      if isstring(str) then return str end
      local res = self:MoveCloserTo(pos, options)
      if res == "reached" then return "ok"
      elseif res == "unreachable" then return "failed"
      elseif res == "stuck" then return "stuck" end
      self:YieldCoroutine(true)
    end
  end

  function ENT:MoveToPos(pos, options, callback)
    if not isvector(pos) then return end
    return self:_GoTo(pos, options, callback)
  end

  function ENT:ChaseEntity(ent, options, callback)
    if not isentity(ent) then return end
    return self:_GoTo(ent, options, callback)
  end

  -- Climbing --

  -- Ladders
  function ENT:ClimbLadder(ladder, down)
    if self:IsClimbing() then return end
    local height = math.abs(ladder:GetTop().z - ladder:GetBottom().z)
    local res = self:OnStartClimbing(ladder, height, down)
    if res == false then return end
    self:SetNW2Bool("DrGBaseClimbing", true)
    self:SetNW2Bool("DrGBaseClimbingDown", down)
    self._DrGBaseClimbLadder = ladder
    if res ~= true then
      local offset = self:CalcOffset(self.ClimbOffset)
      offset.z = 0
      local lastHeight = self:GetPos().z
      local lastTime = CurTime()
      while not self:IsDying() do
        self:FaceTowards(self:GetPos() - ladder:GetNormal())
        local pos
        if down then
          pos = ladder:GetPosAtHeight(lastHeight - self:GetSpeed()*self:GetScale()*(CurTime()-lastTime))
          self:SetPos(pos + offset)
          if ladder:GetBottom().z - pos.z <= 0 then break end
          if self:WhileClimbing(ladder, ladder:GetBottom().z - pos.z, true) then break end
        else
          pos = ladder:GetPosAtHeight(lastHeight + self:GetSpeed()*self:GetScale()*(CurTime()-lastTime))
          self:SetPos(pos + offset)
          if ladder:GetTop().z - pos.z <= 0 then break end
          if self:WhileClimbing(ladder, ladder:GetTop().z - pos.z, false) then break end
        end
        lastHeight = pos.z
        lastTime = CurTime()
        self:YieldCoroutine(false)
      end
      local pos = self:GetPos()
      if down then
        self:OnStopClimbing(ladder, ladder:GetBottom().z - pos.z, true)
      else self:OnStopClimbing(ladder, ladder:GetTop().z - pos.z, false) end
    else self:CustomClimbing(ladder, height, down) end
    self:SetNW2Bool("DrGBaseClimbing", false)
    self._DrGBaseClimbLadder = nil
    self:SetVelocity(Vector(0, 0, 0))
  end
  function ENT:ClimbLadderUp(ladder)
    return self:ClimbLadder(ladder, false)
  end
  function ENT:ClimbLadderDown(ladder)
    return self:ClimbLadder(ladder, true)
  end

  -- Ledges
  local function IsEntityClimbable(self, ent)
    if not IsValid(ent) then return false end
    return ent:GetClass() == "func_lod" or (self.ClimbProps and ent:GetClass() == "prop_physics")
  end
  function ENT:FindLedge()
    if not self.ClimbLedges then return end
    if not self:IsMoving() then return end
    local hull = self:TraceHull(self:GetVelocity():GetNormalized()*self.LedgeDetectionDistance, true)
    if not hull.Hit then return end
    --if IsValid(hull.Entity) then print(hull.Entity, hull.Entity:GetCollisionGroup(), IsValid(hull.Entity)) end
    if hull.HitWorld or IsEntityClimbable(self, hull.Entity) then
      local up = self:TraceHull(self:GetUp()*999999).HitPos
      local height = up.z - self:GetPos().z
      local i = 1
      local tr = {Hit = true, HitNonWorld = true}
      while true do
        if i*10 > height then return end
        tr = self:TraceHull(self:GetForward()*self.LedgeDetectionDistance*3, false, {
          start = self:GetPos() + Vector(0, 0, i*10)
        })
        if not tr.Hit then break end
        if IsValid(tr.Entity) and not IsEntityClimbable(self, tr.Entity) then return end
        i = i+1
      end
      local tr2 = self:TraceHull(self:GetUp()*-999, false, {
        start = tr.HitPos
      })
      if tr2.HitPos.z - self:GetPos().z > self.ClimbLedgesMaxHeight then return end
      local trRad = self:TraceHullRadial(999, 360, true, {
        collisiongroup = COLLISION_GROUP_DEBRIS,
        maxs = Vector(0.5, 0.5, self:Height()),
        mins = Vector(-0.5, -0.5, self:GetStepHeight())
      })
      local pos = self:GetPos()
      local mins, maxs = self:GetCollisionBounds()
      mins.z = maxs.z
      local ledge = self:TraceLine(trRad[1].Normal*mins:Distance(maxs)/1.41, {
        collisiongroup = COLLISION_GROUP_DEBRIS,
        start = Vector(pos.x, pos.y, tr2.HitPos.z - 1)
      }).HitPos
      local height = ledge.z - self:GetPos().z
      if math.Clamp(height, self.ClimbLedgesMinHeight, self.ClimbLedgesMaxHeight) == height then
        return ledge
      end
    end
  end
  function ENT:ClimbLedge(ledge)
    --debugoverlay.Sphere(ledge, 2, 60, nil, true)
    if self:IsClimbing() then return end
    local height = math.abs(ledge.z - self:GetPos().z)
    local res = self:OnStartClimbing(ledge, height, false)
    if res == false then return end
    self:SetNW2Bool("DrGBaseClimbing", true)
    self:SetNW2Bool("DrGBaseClimbingDown", false)
    if res ~= true then
      local offset = self:CalcOffset(self.ClimbOffset)
      offset.z = 0
      local lastPos = self:GetPos()
      local lastTime = CurTime()
      while not self:IsDying() do
        self:FaceTowards(ledge)
        local pos = lastPos + lastPos:DrG_Direction(ledge):GetNormalized()*self:GetSpeed()*self:GetScale()*(CurTime()-lastTime)
        if pos.z > ledge.z then pos.z = ledge.z end
        self:SetPos(pos + offset)
        local remaining = math.abs(ledge.z - self:GetPos().z)
        if remaining == 0 then break end
        if self:WhileClimbing(ledge, remaining, false) then break end
        lastPos = pos
        lastTime = CurTime()
        self:YieldCoroutine(false)
      end
      self:OnStopClimbing(ledge, math.abs(ledge.z - self:GetPos().z), false)
    else self:CustomClimbing(ledge, height, false) end
    self:SetNW2Bool("DrGBaseClimbing", false)
    self:SetVelocity(Vector(0, 0, 0))
  end

  -- Hooks --

  function ENT:OnMove() end
  function ENT:OnRun() end

  function ENT:OnStartClimbing() end
  function ENT:WhileClimbing() end
  function ENT:OnStopClimbing() end
  function ENT:CustomClimbing() end

  function ENT:HandleStuck()
    self.loco:ClearStuck()
  end

  function ENT:UpdateSpeed(run)
    if self:IsClimbing() then return self.ClimbSpeed
    elseif run then return self.RunSpeed
    else return self.WalkSpeed end
  end

  -- Handlers --

  function ENT:_HandleSpeed()
    local run
    if self:IsPossessed() then
      run = self:GetPossessor():KeyDown(IN_SPEED)
    else run = self:ShouldRun() end
    self:SetSpeed(self:UpdateSpeed((run and self:OnRun() ~= false) or false))
  end

end
