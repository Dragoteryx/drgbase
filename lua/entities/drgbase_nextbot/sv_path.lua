-- ConVars --

local PathfindingMode = GetConVar("drgbase_pathfinding")

-- Path --

function ENT:GetPath()
  if not self.DrG_Path then
    self.DrG_Path = Path("Follow")
    self.DrG_Path:SetGoalTolerance(20)
    self.DrG_Path:SetMinLookAheadDistance(300)
  end
  return self.DrG_Path
end

function ENT:InvalidatePath()
  return self:GetPath():Invalidate()
end

-- Nav areas --

function ENT:CurrentNavArea()
  if not navmesh.IsLoaded() then return nil end
  if not self:GetGroundEntity():IsWorld() then return nil end
  if not IsValid(self.DrG_CurrentNavArea) then self.DrG_CurrentNavArea = navmesh.GetNearestNavArea(self:GetPos(), 10) end
  if IsValid(self.DrG_CurrentNavArea) and self.DrG_CurrentNavArea:IsOverlapping(self:GetPos(), 10) then
    return self.DrG_CurrentNavArea
  else return nil end
end
function ENT:PreviousNavArea()
  if not IsValid(self:CurrentNavArea()) then
    return self.DrG_CurrentNavArea or nil
  else return self.DrG_PreviousNavArea or nil end
end

function ENT:OnNavAreaChanged() end
function ENT:DrG_OnNavAreaChanged(old, new)
  self.DrG_PreviousNavArea = old
  self.DrG_CurrentNavArea = new
end

-- Helpers --

function ENT:LastComputeResult()
  return self.DrG_LastComputeResult or false
end

function ENT:LastComputeTime()
  local path = self:GetPath()
  if not IsValid(path) then return -1 end
  return CurTime()-path:GetAge()
end

-- Compute --

local ENABLE_JUMPING = false
function ENT:PathGenerator(area, from, ladder, _elevator, length)
  if not IsValid(from) then return 0 end
  --if self:IsNavAreaBlacklisted(area) then return -1 end
  if not self.loco:IsAreaTraversable(area) then return -1 end
  local dist = 0
  if IsValid(ladder) then
    if not self.ClimbLadders then return -1 end
    dist = ladder:GetLength()
  elseif length > 0 then dist = length
  else dist = from:GetCenter():Distance(area:GetCenter()) end
  local cost = from:GetCostSoFar() + dist
  local height = from:ComputeAdjacentConnectionHeightChange(area)
  if height > 0 then
    if IsValid(ladder) then
      if not self.ClimbLaddersUp then return -1 end
      if height < self.ClimbLaddersUpMinHeight then return -1 end
      if height > self.ClimbLaddersUpMaxHeight then return -1 end
      local res = self:OnComputePathLadderUp(area, from, ladder) or 0
      if res >= 0 then cost = cost + dist*res else return -1 end
    elseif height < self.loco:GetStepHeight() then
      local res = self:OnComputePathStep(area, from, height) or 0
      if res >= 0 then cost = cost + dist*res else return -1 end
    elseif ENABLE_JUMPING and height < self.loco:GetJumpHeight() then
      local res = self:OnComputePathJump(area, from, height) or 0
      if res >= 0 then cost = cost + dist*res else return -1 end
    elseif self.ClimbLedges then
      if height < self.ClimbLedgesMinHeight then return -1 end
      if height > self.ClimbLedgesMaxHeight then return -1 end
      local res = self:OnComputePathLedge(area, from, height) or 0
      if res >= 0 then cost = cost + dist*res else return -1 end
    else return -1 end
  elseif height < 0 then
    local drop = -height
    if IsValid(ladder) then
      if not self.ClimbLaddersDown then return -1 end
      if drop < self.ClimbLaddersDownMinHeight then return -1 end
      if drop > self.ClimbLaddersDownMaxHeight then return -1 end
      local res = self:OnComputePathLadderDown(area, from, ladder) or 0
      if res >= 0 then cost = cost + dist*res else return -1 end
    elseif drop < self.loco:GetDeathDropHeight() then
      local res = self:OnComputePathDrop(area, from, drop) or 0
      if res >= 0 then cost = cost + dist*res else return -1 end
    else return -1 end
  else
    local res = self:OnComputePathFlat(area, from) or 0
    if res >= 0 then cost = cost + dist*res else return -1 end
  end
  local res = self:OnComputePath(area, from) or 0
  if res >= 0 then return cost + dist*res else return -1 end
end

function ENT:GetPathGenerator()
  return function(...)
    return self:PathGenerator(...)
  end
end

-- hooks

function ENT:OnComputePath(_area, _from) return 0 end
function ENT:OnComputePathLadderUp(_area, _from, _ladder) return 2 end
function ENT:OnComputePathLadderDown(_area, _from, _ladder) return 2 end
function ENT:OnComputePathLedge(_area, _from, _height) return 3 end
function ENT:OnComputePathStep(_area, _from, _height) return 0 end
function ENT:OnComputePathJump(_area, _from, _height) return 1 end
function ENT:OnComputePathDrop(_area, _from, _drop) return 1 end
function ENT:OnComputePathFlat(_area, _from) return 0 end

-- Meta --

local pathMETA = FindMetaTable("PathFollower")

local old_Compute = pathMETA.Compute
function pathMETA:Compute(nextbot, pos, generator, ...)
  if nextbot.IsDrGNextbot then
    local pathfinding = PathfindingMode:GetString()
    if pathfinding == "custom" then generator = nextbot:GetPathGenerator()
    elseif pathfinding ~= "default" then
      nextbot.DrG_LastComputeResult = false
      self:Invalidate()
      return false
    end
    nextbot.DrG_LastComputeResult = old_Compute(self, nextbot, pos, generator, ...)
    return nextbot.DrG_LastComputeResult
  else return old_Compute(self, nextbot, pos, generator, ...) end
end