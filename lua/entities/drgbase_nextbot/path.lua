if CLIENT then return end

-- Getters/setters --

function ENT:GetPath()
  self._DrGBasePath = self._DrGBasePath or Path("Follow")
  return self._DrGBasePath
end

-- Functions --

function ENT:InvalidatePath()
  local path = self:GetPath()
  if not IsValid(path) then return end
  path:Invalidate()
end

function ENT:DrawPath()
  local path = self:GetPath()
  if not IsValid(path) then return end
  path:Draw()
end

function ENT:ForcePathRefresh()
  if not IsValid(self:GetPath()) then return end
  self._DrGBaseForcePathRefresh = true
end

-- Hooks --

function ENT:OnComputePath(cost) return cost end
function ENT:OnComputePathClimbLadderUp(cost, dist)
  return cost + dist
end
function ENT:OnComputePathClimbLadderDown(cost, dist)
  return cost + dist
end
function ENT:OnComputePathClimbWall(cost, dist)
  return cost + dist*2
end
function ENT:OnComputePathStep(cost, dist)
  return cost
end
function ENT:OnComputePathJump(cost, dist)
  return cost + dist
end
function ENT:OnComputePathDrop(cost, dist)
  return cost + dist
end
function ENT:OnComputePathUnderwater(cost, dist)
  return cost + dist*2
end

-- Meta --

local pathMETA = FindMetaTable("PathFollower")

local old_Compute = pathMETA.Compute
function pathMETA:Compute(nextbot, pos, generator)
  if nextbot.IsDrGNextbot and not isfunction(generator) then
    generator = function(area, fromArea, ladder, elevator, length)
      if not IsValid(fromArea) then return 0 end
	    if not nextbot.loco:IsAreaTraversable(area) then return -1 end
		  local dist = 0
  		if IsValid(ladder) then
        if not nextbot.ClimbLadders then return -1 end
  			dist = ladder:GetLength()
  		elseif length > 0 then dist = length
  		else dist = fromArea:GetCenter():Distance(area:GetCenter()) end
  		local cost = dist + fromArea:GetCostSoFar()
  		local height = fromArea:ComputeAdjacentConnectionHeightChange(area)
      if height > 0 then
        if IsValid(ladder) and (not nextbot.ClimbLaddersUp or
        height < nextbot.loco:GetStepHeight() or
        height < nextbot.loco:GetJumpHeight()) then return -1 end
        if IsValid(ladder) then
          cost = nextbot:OnComputePathClimbLadderUp(cost, dist, self, area, fromArea, ladder, elevator, length)
        elseif height < nextbot.loco:GetStepHeight() then
          cost = nextbot:OnComputePathStep(cost, dist, self, area, fromArea, ladder, elevator, length)
        elseif height < nextbot.loco:GetJumpHeight() then
          cost = nextbot:OnComputePathJump(cost, dist, self, area, fromArea, ladder, elevator, length)
        elseif nextbot.ClimbWalls then
          if height < nextbot.ClimbWallsMinHeight then return -1 end
          if height > nextbot.ClimbWallsMaxHeight then return -1 end
          cost = nextbot:OnComputePathClimbWall(cost, dist, self, area, fromArea, ladder, elevator, length)
        else return -1 end
  		elseif height < 0 then
        local drop = -height
        if IsValid(ladder) and not nextbot.ClimbLaddersDown then return -1 end
        if IsValid(ladder) then
          cost = nextbot:OnComputePathClimbLadderDown(cost, dist, self, area, fromArea, ladder, elevator, length)
        elseif drop < nextbot.loco:GetDeathDropHeight() then
          cost = nextbot:OnComputePathDrop(cost, dist, self, area, fromArea, ladder, elevator, length)
        else return -1 end
  		end
      if area:IsUnderwater() then cost = nextbot:OnComputePathUnderwater(cost, dist, self, area, fromArea, ladder, elevator, length) end
  		return nextbot:OnComputePath(cost, dist, self, area, fromArea, ladder, elevator, length)
    end
  end
  return old_Compute(self, nextbot, pos, generator)
end

function pathMETA:DrG_GetSegment(i)
  if not IsValid(self) then return end
  return self:GetAllSegments()[i]
end
function pathMETA:DrG_SegmentNumber(segment)
  if not IsValid(self) then return end
  return table.KeyFromValue(self:GetAllSegments(), segment or self:GetCurrentGoal())
end
function pathMETA:DrG_RelativeSegment(i)
  if not IsValid(self) then return end
  local current = self:DrG_SegmentNumber()
  if current > -1 then return self:DrG_GetSegment(current + i) end
end
function pathMETA:DrG_PriorSegment()
  if not IsValid(self) then return end
  return self:DrG_RelativeSegment(-1)
end
function pathMETA:DrG_NextSegment()
  if not IsValid(self) then return end
  return self:DrG_RelativeSegment(1)
end
