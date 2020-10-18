-- ConVars --

local ComputeDelay = DrGBase.ConVar("drgbase_compute_delay", "0.1")
local AvoidObstacles = DrGBase.ConVar("drgbase_avoid_obstacles", "1")
local MultSpeed = DrGBase.ConVar("drgbase_multiplier_speed", "1")

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

if SERVER then

  -- Getters/setters --

  function ENT:SetSpeed(speed)
    self.loco:SetDesiredSpeed(speed*MultSpeed:GetFloat())
  end

  function ENT:IsRunning()
    if self:IsMoving() then
      if self:IsPossessed() then
        return self:GetPossessor():KeyDown(IN_SPEED)
      else return self:ShouldRun() end
    else return false end
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
  function ENT:FaceInstant(pos)
    if isentity(pos) then pos = pos:GetPos() end
    local angle = (pos - self:GetPos()):Angle()
    self:SetAngles(Angle(0, angle.y, 0))
  end
  function ENT:FaceTo(toface)
    while true do
      local pos = toface
      if isentity(pos) then
        if not IsValid(pos) then return end
        pos = pos:GetPos()
      end
      local angle = (pos - self:GetPos()):Angle()
      if math.NormalizeAngle(math.Round(self:GetAngles().y)) == math.NormalizeAngle(math.Round(angle.y)) then return end
      self:FaceTowards(pos)
      self:Yield(true)
    end
  end
  function ENT:FaceEnemy()
    if self:HasEnemy() then self:FaceTowards(self:GetEnemy()) end
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

  -- FollowPath & friends --

  local function ShouldCompute(self, path, pos)
    if not IsValid(path) then return true end
    local segments = #path:GetAllSegments()
    if path:GetAge() >= ComputeDelay:GetFloat()*segments then
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
    if navmesh.IsLoaded() and self:GetGroundEntity():IsWorld() then
      local path = self:GetPath()
      if isnumber(options.tolerance) then path:SetGoalTolerance(options.tolerance) end
      if isnumber(options.lookahead) then path:SetMinLookAheadDistance(options.lookahead) end
      local area = navmesh.GetNearestNavArea(pos)
      if IsValid(area) then pos = area:GetClosestPointOnArea(pos) end
      if ShouldCompute(self, path, pos) then path:Compute(self, pos, options.generator) end
      if not IsValid(path) then return "unreachable" end
      if self:GetRangeSquaredTo(pos) <= path:GetGoalTolerance()^2 then return "reached" end
      --local current = path:GetCurrentGoal()
      path:Update(self)
    else

    end
  end

  function ENT:GoTo(pos, options, fn, ...)
    if isfunction(options) then return self:GoTo(pos, nil, options) end
    if isentity(pos) then pos = pos:GetPos() end
    while true do
      local res = self:FollowPath(pos, options)
      if res == "reached" then return true
      elseif res == "unreachable" then return false
      elseif isfunction(fn) then
        res = fn(self, ...)
        if res ~= nil then return res end
      end
      self:YieldThread(true)
    end
  end

  function ENT:ChaseEntity(ent, options, fn, ...)
    if isfunction(options) then return self:ChaseEntity(ent, nil, options) end
    if not isentity(ent) then return false end
    while IsValid(ent) do
      local res = self:FollowPath(ent, options)
      if res == "reached" then return true
      elseif res == "unreachable" then return false
      elseif isfunction(fn) then
        res = fn(self, ...)
        if res ~= nil then return res end
      end
      self:YieldThread(true)
    end
    return false
  end

  -- Climbing --

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
        if ok then speed = vec:Length()/self:SequenceDuration(seq) end
      else speed = self:GetSequenceGroundSpeed(self:GetSequence()) end
      if not isnumber(speed) or speed <= 0 then speed = 1 end
    end
    self:SetSpeed(speed)
  end

end