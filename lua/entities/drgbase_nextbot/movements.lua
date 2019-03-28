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

function ENT:IsRunning()
  return self:IsOnGround() and self:IsSpeedMoreEqual((self.WalkSpeed + self.RunSpeed)/2, true)
end
function ENT:IsMoving()
  return self:IsSpeedMore(0)
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

-- Functions --

-- Hooks --

function ENT:OnSpeedChange() end

-- Handlers --

function ENT:_InitMovements()
  if SERVER then
    self._DrGBaseUpdateSpeed = true
    self:LoopTimer(0.1, self._HandleSpeed)
  end
  self:SetNWVarProxy("DrGBaseSpeed", function(self, name, old, new)
    if old ~= new then self:OnSpeedChange(old, new) end
  end)
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
  function ENT:IsClimbingWall()
    return self:IsClimbing() and not IsValid(self._DrGBaseClimbLadder)
  end

  -- Functions --

  function ENT:MoveToPos(pos, options, callback)
    if not isvector(pos) then return "failed" end
    if not isfunction(callback) then callback = function() end end
    options = options or {}
    options.tolerance = options.tolerance or 20
    options.maxage = options.maxage or math.huge
    local res = 0
    while res == 0 do
      res = self:_MoveToPosGround(pos, options, callback)
      coroutine.yield()
    end
    return res
  end

  function ENT:_MoveToPosGround(pos, options, callback)
    options.maxage = options.maxage or math.huge
    if options.avoid == nil then options.avoid = true end
    if not navmesh.IsLoaded() then
      local delay = CurTime() + options.maxage
      while self:GetRangeSquaredTo(pos) > options.tolerance^2 do
        if self:IsDying() then return "dying" end
        local res = callback(path, options)
        if isstring(res) then return res
        elseif isvector(res) then pos = res end
        if self:CanMove() and not (options.avoid and self:AvoidObstacles(true)) then
          self:MoveTowards(pos)
        end
        if self.loco:IsStuck() then
      		self:HandleStuck()
      		return "stuck"
      	end
        if CurTime() > delay then return "timeout" end
        coroutine.yield()
      end
      return "ok"
    else
      local path = self:GetPath()
      options.lookahead = options.lookahead or 300
      options.repath = options.repath or math.huge
      path:SetMinLookAheadDistance(options.lookahead)
      path:SetGoalTolerance(options.tolerance)
      if not IsValid(path) or pos:DistToSqr(path:GetEnd()) > options.tolerance^2 then
        path:Compute(self, pos, options.generator)
      end
      if not IsValid(path) then return "failed" end
      local delay = CurTime() + options.maxage
      while true do
        if self:IsDying() then return "dying" end
        if not IsValid(path) then return "failed" end
        local res = callback(path, options)
        if isstring(res) then return res
        elseif isvector(res) then pos = res end
        if self._DrGBaseForcePathRefresh or path:GetAge() >= options.repath then
          if self._DrGBaseForcePathRefresh or pos:DistToSqr(path:GetEnd()) > options.tolerance^2 then
            self._DrGBaseForcePathRefresh = false
            path:Compute(self, pos, options.generator)
          else path:ResetAge() end
        end
        if not IsValid(path) then return "failed" end
        if options.draw then path:Draw() end
        if self:CanMove() then
          local current = path:GetCurrentGoal()
          if current.type == 4 then
            if self.ClimbLaddersUp then
              if self:GetHullRangeSquaredTo(current.ladder:GetBottom()) < options.tolerance^2 then
                self:ClimbLadderUp(current.ladder)
                self:InvalidatePath()
                return 0
              elseif not options.avoid or not self:AvoidObstacles(true) then
                self:MoveTowards(current.pos)
              end
            else self:MoveTowards(self:GetPos() + current.forward) end
          elseif current.type == 5 then
            if self.ClimbLaddersDown then
              if self:GetHullRangeSquaredTo(current.ladder:GetTop()) < options.tolerance^2 then
                self:ClimbLadderDown(current.ladder)
                self:InvalidatePath()
                return 0
              elseif not options.avoid or not self:AvoidObstacles(true) then
                self:MoveTowards(current.pos)
              end
            else self:MoveTowards(self:GetPos() + current.forward) end
          elseif not options.avoid or not self:AvoidObstacles(true) then
            path:Update(self)
          end
        end
        if not IsValid(path) then return "ok" end
        if self:GetHullRangeSquaredTo(path:GetEnd()) <= options.tolerance^2 then
          self:InvalidatePath()
          return "ok"
        end
        if self.loco:IsStuck() then
      		self:HandleStuck()
      		return "stuck"
      	end
        if CurTime() > delay then return "timeout" end
        coroutine.yield()
      end
    end
  end

  function ENT:MoveToEntity(ent, options, callback)
    return self:MoveToPos(ent:GetPos(), options, callback)
  end

  function ENT:FollowEntity(ent, options, callback)
    if not isfunction(callback) then callback = function() end end
    return self:MoveToPos(ent:GetPos(), options, function(path)
      if not IsValid(ent) then return "invalid" end
      local res = callback(path)
      if isstring(res) then return res
      elseif not IsValid(ent) then return "invalid"
      else return ent:GetPos() end
    end)
  end

  function ENT:FollowEntityMemory(ent, options, callback)
    if not self:HasSpottedEntity(ent) then return "not spotted" end
    if not isfunction(callback) then callback = function() end end
    local pos = self:HasLostEntity(ent) and self._DrGBaseMemory[ent:GetCreationID()].pos or ent:GetPos()
    local res = self:MoveToPos(pos, options, function(path)
      if not IsValid(ent) then return "invalid" end
      local res = callback(path)
      if isstring(res) then return res
      elseif not IsValid(ent) then return "invalid"
      elseif not self:HasSpottedEntity(ent) then return "not spotted"
      elseif self:HasLostEntity(ent) then
        return self._DrGBaseMemory[ent:GetCreationID()].pos
      else return ent:GetPos() end
    end)
    if res == "ok" and self:HasLostEntity(ent) then return "lost"
    else return res end
  end

  -- Decomposed moving stuff

  function ENT:FacePos(pos)
    local angle = (pos - self:GetPos()):Angle()
    self:SetAngles(Angle(0, angle.y, 0))
  end
  function ENT:FaceEntity(ent)
    self:FacePos(ent:GetPos())
  end

  function ENT:FaceTowards(pos)
    if not self:CanMove() then return end
    return self.loco:FaceTowards(pos)
  end
  function ENT:FaceTowardsEntity(ent)
    return self:FaceTowards(ent:GetPos())
  end

  function ENT:Approach(pos, nb)
    if not self:CanMove() then return end
    return self.loco:Approach(pos, nb or 1)
  end
  function ENT:ApproachEntity(ent, nb)
    return self:Approach(ent:GetPos(), nb)
  end

  function ENT:MoveTowards(pos)
    self:FaceTowards(pos)
    self:Approach(pos)
  end
  function ENT:MoveTowardsEntity(ent)
    self:MoveTowards(ent:GetPos())
  end

  function ENT:MoveForwardTo(pos)
    self:FaceTowards(pos)
    self:MoveForward()
  end
  function ENT:MoveForwardToEntity(ent)
    return self:MoveForwardTo(ent:GetPos())
  end

  function ENT:MoveAwayFrom(pos, face)
    local away = self:GetPos()*2 - pos
    if face then
      self:FaceTowards(pos)
      self:Approach(away)
    else self:MoveTowards(away) end
  end
  function ENT:MoveAwayFromEntity(ent, face)
    self:MoveAwayFrom(ent:GetPos(), face)
  end

  function ENT:MoveForward()
    return self:Approach(self:GetPos() + self:GetForward())
  end
  function ENT:MoveBackward()
    return self:Approach(self:GetPos() - self:GetForward())
  end
  function ENT:MoveRight()
    return self:Approach(self:GetPos() + self:GetRight())
  end
  function ENT:MoveLeft()
    return self:Approach(self:GetPos() - self:GetRight())
  end

  function ENT:AvoidObstacles(forwardOnly, duration, callback)
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
        local avoided, direction = self:AvoidObstacles(forwardOnly)
        if not avoided then return false end
        coroutine.yield()
      end
      return true
    end
  end

  -- Climbing

  function ENT:ClimbLadder(ladder, down)
    if self:IsClimbing() then return end
    if self:OnStartClimbing(ladder, down) == false then return end
    self:SetNW2Bool("DrGBaseClimbing", true)
    self:SetNW2Bool("DrGBaseClimbingDown", down)
    self._DrGBaseClimbLadder = ladder
    self:FacePos(self:GetPos() - ladder:GetNormal())
    local offset = self:GetForward()*self.ClimbOffset.x +
    self:GetRight()*self.ClimbOffset.y +
    self:GetUp()*self.ClimbOffset.z
    local wait = 0.01
    local startingHeight = self:GetPos().z
    local i = 1
    while not self:IsDying() do
      self:FacePos(self:GetPos() - ladder:GetNormal())
      if down then
        if self:GetPos().z <= ladder:GetBottom().z then break end
        local pos = ladder:GetPosAtHeight(startingHeight - self:GetSpeed()*wait*self:GetScale()*i)
        if self:WhileClimbing(ladder, pos.z - ladder:GetBottom().z, true) then break end
        self:SetPos(pos + offset)
      else
        if self:GetPos().z >= ladder:GetTop().z then break end
        local pos = ladder:GetPosAtHeight(startingHeight + self:GetSpeed()*wait*self:GetScale()*i)
        if self:WhileClimbing(ladder, ladder:GetTop().z - pos.z, false) then break end
        self:SetPos(pos + offset)
      end
      i = i+1
      coroutine.wait(wait)
    end
    if down then
      self:SetPos(ladder:GetPosAtHeight(startingHeight - self:GetSpeed()*wait*self:GetScale()*(i-1)) + offset)
    else self:SetPos(ladder:GetPosAtHeight(startingHeight + self:GetSpeed()*wait*self:GetScale()*(i-1)) + offset) end
    self:OnStopClimbing(ladder, down)
    self:SetNW2Bool("DrGBaseClimbing", false)
    self._DrGBaseClimbLadder = nil
    if not self:IsDying() then
      local pos = self:GetPos()
      self:SetPos(navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos))
    end
  end
  function ENT:ClimbLadderUp(ladder)
    return self:ClimbLadder(ladder, false)
  end
  function ENT:ClimbLadderDown(ladder)
    return self:ClimbLadder(ladder, true)
  end
  function ENT:ClimbWall()
    if self:IsClimbing() then return end
    if self:OnStartClimbing(nil, false) == false then return end
    self:SetNW2Bool("DrGBaseClimbing", true)
    self:SetNW2Bool("DrGBaseClimbingDown", false)
  end

  -- Hooks --

  function ENT:HandleStuck()
    self.loco:ClearStuck()
  end

  function ENT:CanMove() return true end
  function ENT:CanRun() return true end

  function ENT:OnStartClimbing() end
  function ENT:WhileClimbing() end
  function ENT:OnStopClimbing() end

  function ENT:UpdateSpeed(run)
    if self:IsClimbing() then return self.ClimbSpeed
    elseif run then return self.RunSpeed
    else return self.WalkSpeed end
  end

  -- Handlers --

  function ENT:_HandleSpeed()
    if self:CanRun() then
      local run
      if self:IsPossessed() then
        run = self:GetPossessor():KeyDown(IN_SPEED)
      else run = self:ShouldRun(self:GetState()) end
      self:SetSpeed(self:UpdateSpeed(run or false))
    else self:SetSpeed(self:UpdateSpeed(false)) end
  end

  -- Aliases --

  function ENT:GetStepHeight()
    return self.loco:GetStepHeight()
  end
  function ENT:SetStepHeight(height)
    return self.loco:SetStepHeight(height)
  end

  function ENT:GetJumpHeight()
    return self.loco:GetJumpHeight()
  end
  function ENT:SetJumpHeight(height)
    return self.loco:SetJumpHeight(height)
  end

  function ENT:GetDeathDropHeight()
    return self.loco:GetDeathDropHeight()
  end
  function ENT:SetDeathDropHeight(height)
    return self.loco:SetDeathDropHeight(height)
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
    return self.loco:SetDeceleration()
  end

  function ENT:GetMaxYawRate()
    return self.loco:GetMaxYawRate()
  end
  function ENT:SetMaxYawRate(rate)
    return self.loco:SetMaxYawRate(rate)
  end

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
