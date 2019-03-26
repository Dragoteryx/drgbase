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

-- Functions --

-- Hooks --

function ENT:OnSpeedChange() end

-- Handlers --

function ENT:_InitMovements()
  if SERVER then
    self:ForwardMovement(self.ForwardOnly)
    self:SetTurnRate(self.TurnRate)
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

  function ENT:ForwardMovement(bool)
    if bool == nil then return self._DrGBaseForwardMovement
    elseif bool then self._DrGBaseForwardMovement = true
    else self._DrGBaseForwardMovement = false end
  end

  function ENT:GetTurnRate()
    return self.loco:GetMaxYawRate()
  end
  function ENT:SetTurnRate(rate)
    self.loco:SetMaxYawRate(rate)
  end

  -- Functions --

  function ENT:MoveToPos(pos, options, callback)
    if not isvector(pos) then return "failed" end
    if not isfunction(callback) then callback = function() end end
    options = options or {}
    options.tolerance = options.tolerance or 20
    options.maxage = options.maxage or math.huge
    return self:_MoveToPosGround(pos, options, callback)
  end

  function ENT:_MoveToPosGround(pos, options, callback)
    options.maxage = options.maxage or math.huge
    if not navmesh.IsLoaded() then
      local delay = CurTime() + options.maxage
      while self:GetRangeSquaredTo(pos) > options.tolerance^2 do
        if self:IsDying() then return "dying" end
        local res = callback(path, options)
        if isstring(res) then return res
        elseif isvector(res) then pos = res end
        if self:CanMove() and not (options.avoid and self:AvoidObstacles(true)) then
          if self:ForwardMovement() then
            self:MoveForwardTo(pos)
          else self:MoveTowards(pos) end
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
        if path:GetAge() >= options.repath then
          if pos:DistToSqr(path:GetEnd()) > options.tolerance^2 then
            path:Compute(self, pos, options.generator)
          else path:ResetAge() end
        end
        if not IsValid(path) then return "failed" end
        if options.draw then path:Draw() end
        if self:CanMove() and not (options.avoid and self:AvoidObstacles(true)) then
          if self:ForwardMovement() then
            local cursor = path:GetCursorData()
            self:MoveForwardTo(self:GetPos() + cursor.forward)
            path:MoveCursorToClosestPosition(self:GetPos(), nil, 1)
          else path:Update(self) end
        end
        if not IsValid(path) then return "ok" end
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

  function ENT:MoveAwayFrom(pos)
    local away = self:GetPos()*2 - pos
    if not self:ForwardMovement() then
      self:FaceTowards(pos)
      self:Approach(away)
    else self:MoveForwardTo(away) end
  end
  function ENT:MoveAwayFromEntity(ent)
    self:MoveAwayFrom(ent:GetPos())
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

  -- Hooks --

  function ENT:HandleStuck()
    self.loco:ClearStuck()
  end

  function ENT:CanMove() return true end
  function ENT:CanRun() return true end

  function ENT:UpdateSpeed(run)
    if run then return self.RunSpeed
    else return self.WalkSpeed end
  end

  -- Handlers --

  function ENT:_HandleSpeed()
    if self:CanRun() then
      local run
      if self:IsPossessed() then
        run = self:GetPossessor():KeyDown(IN_SPEED)
      else run = self:ShouldRun(self:GetState()) end
      self:SetSpeed(self:UpdateSpeed(run))
    else self:SetSpeed(self:UpdateSpeed(false)) end
  end

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
