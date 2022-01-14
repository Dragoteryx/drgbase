-- Getters --

function ENT:GetSpeed()
  return self:GetNW2Float("DrG/Speed", 300)
end

function ENT:GetMovement(ignoreZ)
  if not self:IsMoving() then return Vector(0, 0, 0) end
  local dir = self:GetVelocity()
  if ignoreZ then dir.z = 0 end
  return (self:GetAngles()-dir:Angle()):Forward()
end

function ENT:IsMoving()
  return not self:GetVelocity():IsZero()
end
function ENT:IsMovingUp()
  return math.Round(self:GetMovement().z, 2) > 0
end
function ENT:IsMovingDown()
  return math.Round(self:GetMovement().z, 2) < 0
end
function ENT:IsMovingForward()
  return math.Round(self:GetMovement().x, 2) > 0
end
function ENT:IsMovingBackward()
  return math.Round(self:GetMovement().x, 2) < 0
end
function ENT:IsMovingRight()
  return math.Round(self:GetMovement().y, 2) > 0
end
function ENT:IsMovingLeft()
  return math.Round(self:GetMovement().y, 2) < 0
end
function ENT:IsMovingForwardLeft()
  return self:IsMovingForward() and self:IsMovingLeft()
end
function ENT:IsMovingForwardRight()
  return self:IsMovingForward() and self:IsMovingRight()
end
function ENT:IsMovingBackwardLeft()
  return self:IsMovingBackward() and self:IsMovingLeft()
end
function ENT:IsMovingBackwardRight()
  return self:IsMovingBackward() and self:IsMovingRight()
end

function ENT:IsTurningLeft()
  return false
end
function ENT:IsTurningRight()
  return false
end

if SERVER then

  local function CalcRadius(self)
    local mins = self:GetCollisionBounds()
    return math.sqrt((math.abs(mins.x)^2)*2)/2
  end

  local function CollisionHulls(self, distance)
    if not isnumber(distance) then distance = 1 end
    local radius = CalcRadius(self)+1*distance
    local mins, maxs = self:GetCollisionBounds()
    mins.x = mins.x/2
    mins.y = mins.y/2
    maxs.x = maxs.x/2
    maxs.y = maxs.y/2
    return self:TraceHull(Vector(1, -1):GetNormalized()*radius, {step = true, mins = mins, maxs = maxs}),
      self:TraceHull(Vector(1, 1):GetNormalized()*radius, {step = true, mins = mins, maxs = maxs}),
      self:TraceHull(Vector(-1, -1):GetNormalized()*radius, {step = true, mins = mins, maxs = maxs}),
      self:TraceHull(Vector(-1, 1):GetNormalized()*radius, {step = true, mins = mins, maxs = maxs})
  end

  -- Getters/setters --

  function ENT:SetSpeed(speed)
    self.loco:SetDesiredSpeed(speed*DrGBase.SpeedMultiplier:GetFloat()*self:GetModelScale())
  end

  function ENT:IsRunning()
    if not self:IsMoving() then return false end
    if self:IsPossessed() then
      return self:GetPossessor():KeyDown(IN_SPEED)
    else return self:ShouldRun() end
  end

  function ENT:IsCrouching()
    if not self.EnableCrouching then return false end
    if self:IsPossessed() then
      return self:GetPossessor():KeyDown(IN_DUCK)
    else return self:ShouldCrouch() end
  end

  -- Movements --

  function ENT:Approach(pos, nb)
    if isentity(pos) then pos = pos:GetPos() end
    self.loco:Approach(pos, nb or 1)
  end
  function ENT:FaceTowards(pos)
    if isentity(pos) then pos = pos:GetPos() end
    self.loco:FaceTowards(pos)
  end
  function ENT:FaceEnemy()
    if not self:HasEnemy() then return end
    self:FaceTowards(self:GetEnemy())
  end
  function ENT:FaceInstant(pos)
    if isentity(pos) then pos = pos:GetPos() end
    local angle = (pos - self:GetPos()):Angle()
    self:SetAngles(Angle(0, angle.y, 0))
  end
  function ENT:FaceTo(toface)
    while true do
      local pos = toface
      if isentity(pos) then
        if not IsValid(pos) then return false end
        pos = pos:GetPos()
      end
      local angle = (pos - self:GetPos()):Angle()
      if math.NormalizeAngle(math.Round(self:GetAngles().y)) == math.NormalizeAngle(math.Round(angle.y)) then return true end
      self:FaceTowards(pos)
      if self:YieldCoroutine(true) then return false end
    end
  end

  function ENT:MoveTowards(pos)
    if isentity(pos) then pos = pos:GetPos() end
    self:FaceTowards(pos)
    self:Approach(pos)
  end
  function ENT:MoveAwayFrom(pos, face)
    if isentity(pos) then pos = pos:GetPos() end
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

  -- FollowPath & friends --

  local function ShouldCompute(self, path, pos)
    if not IsValid(path) then return true end
    local segments = #path:GetAllSegments()
    if path:GetAge() >= DrGBase.ComputeDelay:GetFloat()*segments then
      return path:GetEnd():DistToSqr(pos) > path:GetGoalTolerance()^2
    else return false end
  end
  function ENT:FollowPath(pos, options)
    if isentity(pos) then
      if not IsValid(pos) then return "unreachable" end
      if pos:GetClass() == "npc_barnacle" then
        pos = util.DrG_TraceLine({
          start = pos:GetPos(), endpos = pos:GetPos()-Vector(0, 0, 999999),
          collisiongroup = COLLISION_GROUP_DEBRIS
        }).HitPos
      else pos = pos:GetPos() end
    end
    if not istable(options) then options = {} end
    if navmesh.IsLoaded() and DrGBase.PathfindingMode:GetString() ~= "none" and IsValid(self:CurrentNavArea()) then
      local path = self:GetPath()
      if isnumber(options.tolerance) then path:SetGoalTolerance(options.tolerance) end
      if isnumber(options.lookahead) then path:SetMinLookAheadDistance(options.lookahead) end
      local area = navmesh.GetNearestNavArea(pos)
      if IsValid(area) then pos = area:GetClosestPointOnArea(pos) end
      if ShouldCompute(self, path, pos) then path:Compute(self, pos, options.generator) end
      if not IsValid(path) then return "unreachable" end
      --local current = path:GetCurrentGoal()
      if DrGBase.AvoidObstacles:GetBool() and
      not self.DrG_UnstuckDelay or self.DrG_UnstuckDelay < CurTime() then
        self.DrG_UnstuckDelay = CurTime() + 0.25
        local nw, ne, sw, se = CollisionHulls(self)
        if nw.Hit or ne.Hit or sw.Hit or se.Hit then
          if self:Unstuck() then self.loco:ClearStuck()
          else return "stuck" end
        end
      end
      if self.loco:IsStuck() then
        self:HandleStuck()
        return "stuck"
      end
      path:Update(self)
      if not IsValid(path) then return "reached" end
    else
      local tolerance = isnumber(options.tolerance) and options.tolerance or 20
      if DrGBase.AvoidObstacles:GetBool() and
      not self.DrG_UnstuckDelay or self.DrG_UnstuckDelay < CurTime() then
        self.DrG_UnstuckDelay = CurTime() + 0.25
        local nw, ne, sw, se = CollisionHulls(self)
        if nw.Hit or ne.Hit or sw.Hit or se.Hit then
          if self:Unstuck() then self.loco:ClearStuck()
          else return "stuck" end
        end
      end
      if self.loco:IsStuck() then
        self:HandleStuck()
        return "stuck"
      end
      self:MoveTowards(pos)
      if self:GetRangeSquaredTo(pos) <= tolerance^2 then return "reached" end
    end
  end

  function ENT:GoTo(pos, options, fn, ...)
    if isfunction(options) then return self:GoTo(pos, nil, options, ...) end
    if isentity(pos) then pos = pos:GetPos() end
    while true do
      local res = self:FollowPath(pos, options)
      if res == "reached" then return true
      elseif res == "unreachable" then return false
      elseif isfunction(fn) then
        res = fn(self, ...)
        if res ~= nil then return res end
      end
      self:YieldCoroutine(true)
    end
  end

  function ENT:ChaseEntity(ent, options, fn, ...)
    if isfunction(options) then return self:ChaseEntity(ent, nil, options, ...) end
    if not isentity(ent) then return false end
    while IsValid(ent) do
      local res = self:FollowPath(ent, options)
      if res == "reached" then return true
      elseif res == "unreachable" then return false
      elseif isfunction(fn) then
        res = fn(self, ...)
        if res ~= nil then return res end
      end
      self:YieldCoroutine(true)
    end
    return false
  end

  local NORTH = Vector(999999999, 0)
  local SOUTH = -NORTH
  local EAST = Vector(0, 999999999)
  local WEST = -EAST
  function ENT:Unstuck()
    while true do
      local nw, ne, sw, se = CollisionHulls(self, 5)
      local hit = 0
      if nw.Hit then hit = hit+1 end
      if ne.Hit then hit = hit+1 end
      if sw.Hit then hit = hit+1 end
      if se.Hit then hit = hit+1 end
      if hit == 3 then
        if sw.Hit and nw.Hit and ne.Hit then self:Approach(SOUTH + EAST)
        elseif nw.Hit and ne.Hit and se.Hit then self:Approach(SOUTH + WEST)
        elseif se.Hit and sw.Hit and nw.Hit then self:Approach(NORTH + EAST)
        elseif ne.Hit and se.Hit and sw.Hit then self:Approach(NORTH + WEST) end
      elseif hit == 2 then
        if nw.Hit and ne.Hit then self:Approach(SOUTH)
        elseif sw.Hit and se.Hit then self:Approach(NORTH)
        elseif nw.Hit and sw.Hit then self:Approach(EAST)
        elseif ne.Hit and se.Hit then self:Approach(WEST)
        else return false end
      elseif hit == 1 then
        if nw.Hit then self:Approach(SOUTH + EAST)
        elseif ne.Hit then self:Approach(SOUTH + WEST)
        elseif sw.Hit then self:Approach(NORTH + EAST)
        elseif se.Hit then self:Approach(NORTH + WEST) end
      else return hit == 0 end
      self:YieldCoroutine(true)
    end
  end

  function ENT:HandleStuck()
    self.loco:ClearStuck()
  end

  -- Climbing --

  function ENT:IsClimbing()
    return false
  end

  function ENT:ClimbLadder(ladder, fn)

  end

  function ENT:ClimbLedge(ledge, fn)

  end

  -- Update --

  function ENT:OnUpdateSpeed()
    if self.UseWalkframes then return -1
    --[[if self:IsClimbing() then return self.ClimbSpeed]]
    elseif self:IsRunning() then return self.RunSpeed
    else return self.WalkSpeed end
  end

  function ENT:UpdateSpeed()
    local speed = self:OnUpdateSpeed()
    if not isnumber(speed) or speed < 0 then
      if not self:IsOnGround() then
        local ok, vec = self:GetSequenceMovement(self:GetSequence(), 0, 1)
        if ok then speed = vec:Length()/self:SequenceDuration() end
      else speed = self:GetSequenceGroundSpeed(self:GetSequence())/self:GetModelScale() end
      if not isnumber(speed) or speed <= 0 then speed = 1 end
    end
    self:SetSpeed(speed)
  end

end