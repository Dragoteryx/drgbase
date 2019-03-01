
-- Speed --

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

-- Getters --

function ENT:IsMoving()
  return self:SpeedSqr() ~= 0
end
function ENT:IsRunning()
  return self:IsSpeedMore(self.WalkSpeed*1.5, true)
end
function ENT:IsClimbing()
  return self:GetDrGVar("DrGBaseClimbing")
end

local DebugPath = CreateConVar("drgbase_debug_path", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local DebugAvoidance = CreateConVar("drgbase_debug_avoid", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

if SERVER then

  -- Getters --

  function ENT:IsMovingForward()
    if not self:IsMoving() then return false end
    return math.Round(math.DrG_DegreeAngle(self:GetForward(), self.loco:GetGroundMotionVector())) < 90
  end
  function ENT:IsMovingBackward()
    if not self:IsMoving() then return false end
    return math.Round(math.DrG_DegreeAngle(self:GetForward(), self.loco:GetGroundMotionVector())) > 90
  end
  function ENT:IsMovingLeft()
    if not self:IsMoving() then return false end
    return math.Round(math.DrG_DegreeAngle(self:GetRight(), self.loco:GetGroundMotionVector())) > 90
  end
  function ENT:IsMovingRight()
    if not self:IsMoving() then return false end
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
      self:_Debug("speed change: "..self:GetSpeed().." => "..speed..".", "drgbase_debug_movement")
      self:SetDrGVar("DrGBaseSpeed", speed)
    end
    return self.loco:SetDesiredSpeed(speed*self:GetScale())
  end

  -- Coroutine (the big bois) --

  function ENT:MoveToPos(pos, options, callback)
    options = options or {}
    options.tolerance = options.tolerance or 20
    options.lookahead = options.lookahead or 300
    if self:IsFlying() then
      return self:_MoveToPosFlying(pos, options, callback)
    else
      self._DrGBaseMovingToPos = true
      local res = self:_MoveToPosGround(pos, options, callback)
      self._DrGBaseMovingToPos = false
      return res
    end
  end

  function ENT:_MoveToPosFlying(pos, options, callback)
    options.maxage = options.maxage or math.huge
    local delay = CurTime() + options.maxage
    while self:GetRangeSquaredTo(pos) > options.tolerance^2 do
      if self:IsDying() then return "dying" end
      local res = callback(path, options)
      if isstring(res) then return res
      elseif isvector(res) then pos = res end
      if self:CanMove(pos) then
        local vector, data = math.DrG_BallisticTrajectory(self:GetPos(), pos, {
          magnitude = self:GetRangeTo(pos), recursive = true
        })
        self:MoveTowards(self:GetPos() + vector, true)
      end
      if CurTime() > delay then return "timeout" end
      coroutine.yield()
    end
    return "ok"
  end

  function ENT:_MoveToPosGround(pos, options, callback)
    if callback == nil then callback = function() end end
    if not navmesh.IsLoaded() then
      options.maxage = options.maxage or math.huge
      local delay = CurTime() + options.maxage
      while self:GetRangeSquaredTo(pos) > options.tolerance^2 do
        if self:IsDying() then return "dying" end
        self._DrGBaseMovingToPos = false
        local res = callback(path, options)
        self._DrGBaseMovingToPos = true
        if isstring(res) then return res
        elseif isvector(res) then pos = res end
        if self:CanMove(pos) then
          if not self:_DynamicAvoidance(true) and not self:OnMove() then
            self:MoveTowards(pos, true)
          end
        end
        if CurTime() > delay then return "timeout" end
        coroutine.yield()
      end
      return "ok"
    else
      if options.draw == nil then options.draw = GetConVar("developer"):GetBool() and DebugPath:GetBool() end
      self._DrGBasePath = self._DrGBasePath or Path("Follow")
      local path = self:GetPath()
      path:SetMinLookAheadDistance(options.lookahead)
      path:SetGoalTolerance(options.tolerance)
      pos = navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos) or pos
      if self:GetRangeSquaredTo(pos) <= options.tolerance^2 then return "ok" end
      if not IsValid(path) or pos:DistToSqr(path:LastSegment().pos) > options.tolerance^2 then
        path:DrG_Compute(self, pos, options.generator)
      else path:ResetAge() end
      if not IsValid(path) then return "failed" end
      while IsValid(path) do
        if self:IsDying() then return "dying" end
        self._DrGBaseMovingToPos = false
        local res = callback(path, options)
        self._DrGBaseMovingToPos = true
        if isstring(res) then return res
        elseif isvector(res) then
          pos = navmesh.GetNearestNavArea(res):GetClosestPointOnArea(res)
        end
        if options.draw then path:Draw() end
        if self:CanMove() then
          if not self:_DynamicAvoidance(true) then
            if not self:OnMove(pos, path) then
              local current = path:GetCurrentGoal()
              if current ~= nil then
                local type = current.type
                if type == 2 then
                  local next = path:DrG_GetNextSegment()
                  if next == nil then path:Update(self)
                  else
                    local deltaZ = next.pos.z - self:GetPos().z
                    if deltaZ < self.loco:GetMaxJumpHeight() then
                      self:Jump(next.pos)
                    elseif self:GetRangeSquaredTo(current.pos) <= options.tolerance^2 then
                      local normal = Vector(next.forward.x, next.forward.y, 0):GetNormalized()
                      local up = self:TraceHull({
                        start = self:GetPos(),
                        endpos = self:GetPos() + Vector(0, 0, 999999999),
                        filter = {self, self:GetWeapon()}
                      })
                      local maxheight = up.HitPos.z - self:GetPos().z
                      local tr = {Hit = true}
                      local incr = 0
                      while tr.Hit do
                        if incr > maxheight then return end
                        local start = self:GetPos() + Vector(0, 0, incr)
                        tr = self:TraceHull({
                          start = start,
                          endpos = start + normal*50,
                          filter = {self, self:GetWeapon()}
                        })
                        incr = incr+10
                      end
                      local tr2 = self:TraceHull({
                        start = tr.HitPos,
                        endpos = tr.HitPos + Vector(0, 0, -999999999),
                        filter = {self, self:GetWeapon()}
                      })
                      local height = tr2.HitPos.z - self:GetPos().z
                      local tr3 = {Hit = true}
                      incr = 0
                      while tr3.Hit do
                        local start = tr.HitPos + normal*incr
                        tr3 = util.TraceLine({
                          start = start,
                          endpos = start + Vector(0, 0, -height - 1),
                          filter = {self, self:GetWeapon()}
                        })
                        incr = incr+1
                      end
                      local ledge = tr3.HitPos + Vector(0, 0, 1)
                      debugoverlay.Sphere(ledge, 3)
                      if self:OnStartClimbing() ~= false then

                      end
                    else path:Update(self) end
                  end
                elseif type == 3 then
                  local next = path:DrG_GetNextSegment()
                  if next == nil then path:Update(self)
                  else self:Jump(next.pos) end
                elseif type == 4 then
                  local ladder = current.ladder
          				if IsValid(ladder) and
                  self:GetRangeSquaredTo(ladder:GetPosAtHeight(self:GetPos().z)) <= options.tolerance^2 then
          					self:ClimbLadder(current.ladder)
                    path:MoveCursorToClosestPosition(self:GetPos())
                  else path:Update(self) end
                elseif type == 5 then
                  self.loco:FaceTowards(self:GetPos() + current.forward)
                  self.loco:Approach(self:GetPos() + current.forward, 1)
                  path:MoveCursorToClosestPosition(self:GetPos())
                else path:Update(self) end
              end
            end
          end
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
        if options.repath and path:GetAge() > options.repath then
          if not IsValid(path) or pos:DistToSqr(path:LastSegment().pos) > options.tolerance^2 then
            path:DrG_Compute(self, pos, options.generator)
            if not IsValid(path) then return "failed" end
          else path:ResetAge() end
        end
      	coroutine.yield()
      end
      if self:GetRangeSquaredTo(pos) <= options.tolerance^2 then return "ok"
      else return "moved" end
    end
  end
  function ENT:OnMove() end

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

  function ENT:FollowEntityMemory(ent, options, callback)
    if not self:HasSpottedEntity(ent) then return "not spotted" end
    if self:HasLostEntity(ent) then
      local res = self:MoveToPos(self._DrGBaseMemory[ent:GetCreationID()].pos, options, function(path)
        if not IsValid(ent) then return "invalid" end
        local res = callback(path, options)
        if isstring(res) then return res
        elseif not IsValid(ent) then return "invalid"
        else return ent:GetPos() end
      end)
      if res == "ok" and self:HasLostEntity(ent) then return "lost"
      else return res end
    else return self:FollowEntity(ent, options, callback) end
  end

  -- Instant (the smol bois) --

  function ENT:MoveTowards(pos, face)
    if not self:CanMove() then return end
    if self:IsFlying() then self:FlyTowards(pos, face)
    else
      self.loco:Approach(pos, 1)
      if face then self:FaceTowards(pos) end
    end
  end
  function ENT:StepTowardsPos(pos)
    if self:IsFlying() then return end
    if not self:CanMove() then return end
    self:FaceTowards(pos)
    self:GoForward()
  end
  function ENT:StepAwayFromPos(pos)
    if self:IsFlying() then return end
    if not self:CanMove() then return end
    self:FaceTowards(pos)
    self:GoBackward()
  end

  function ENT:FacePos(pos)
    local angle = (pos - self:GetPos()):Angle()
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
    if not self:CanMove() then return end
    self:MoveTowards(self:GetPos() + self:GetForward())
  end
  function ENT:GoBackward()
    if not self:CanMove() then return end
    self:MoveTowards(self:GetPos() - self:GetForward())
  end
  function ENT:StrafeLeft()
    if not self:CanMove() then return end
    self:MoveTowards(self:GetPos() - self:GetRight())
  end
  function ENT:StrafeRight()
    if not self:CanMove() then return end
    self:MoveTowards(self:GetPos() + self:GetRight())
  end

  -- Climbing --

  function ENT:ClimbLadder(ladder)
    if self:IsFlying() then return end
    if self:IsClimbing() then return end
    local stopclimb = self:OnStartClimbing(ladder)
    if stopclimb == false then return
    elseif not isnumber(stopclimb) then stopclimb = 0 end
    self:SetDrGVar("DrGBaseClimbing", true)
    local blockyaw = self:PossessionBlockYaw()
    self:PossessionBlockYaw(true)
    local length = ladder:GetLength()
    while self:GetPos().z + stopclimb < ladder:GetTop().z and not self:IsDying() do
      if self:WhileClimbing(ladder, ladder:GetTop().z - self:GetPos().z - stopclimb) then break end
      self.loco:FaceTowards(ladder:GetPosAtHeight(self:GetPos().z))
		  self:SetPos(ladder:GetPosAtHeight(self:GetSpeed()/50 + self:GetPos().z))
      coroutine.wait(0.025)
    end
    self:OnStopClimbing(ladder)
    local pos = self:GetPos()
    self:SetPos(navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos))
    self:SetDrGVar("DrGBaseClimbing", false)
    self:PossessionBlockYaw(blockyaw)
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

  -- Dynamic avoidance --

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
    if not self:CanMove() then return end
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
      return avoided, direction, hulls
    end
  end

  -- Handlers --

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
    if CurTime() < self._DrGBaseHandleMovementDelay then return end
    self._DrGBaseHandleMovementDelay = CurTime() + 0.1
    if self:EnableUpdateSpeed() then
      local run
      if self:IsPossessed() then run = self:KeyDown(IN_SPEED)
      else run = self:ShouldRun(self:GetState()) end
      self:SetSpeed(self:UpdateSpeed(run))
    end
  end

else



end
