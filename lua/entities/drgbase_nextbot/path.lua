if CLIENT then return end

-- Getters/setters --

function ENT:GetPath()
  self._DrGBasePath = self._DrGBasePath or Path("Follow")
  return self._DrGBasePath
end

function ENT:GetPathComputeDelay()
  return self._DrGBasePathComputeDelay or 0.1
end
function ENT:SetPathComputeDelay(delay)
  self._DrGBasePathComputeDelay = delay
end

-- Functions --

function ENT:InvalidatePath()
  local path = self:GetPath()
  if not IsValid(path) then return end
  return path:Invalidate()
end

function ENT:DrawPath()
  local path = self:GetPath()
  if not IsValid(path) then return end
  return path:Draw()
end

function ENT:UpdatePath()
  local path = self:GetPath()
  if not IsValid(path) then return end
  return path:Update(self)
end

function ENT:ComputePath(pos, generator)
  local path = self:GetPath()
  if not IsValid(path) then return end
  path:Compute(self, pos, generator)
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
  return cost + dist
  --return cost + dist*2
end

-- Meta --

local pathMETA = FindMetaTable("PathFollower")
DrGBase_pathMETA = DrGBase_pathMETA or false

if not DrGBase_pathMETA then
  DrGBase_pathMETA = true

  local old_Update = pathMETA.Update
  function pathMETA:Update(nextbot)
    if nextbot.IsDrGNextbot and IsValid(self) then
      local pos = self:GetCurrentGoal().pos
      --[[local tr = self:TraceLine(pos - nextbot:GetPos())
      if IsValid(tr.Entity) and tr.Entity:DrG_IsDoor() then
        self:OnDoor(tr.Entity, tr.Entity:DrG_DoorOpener(self))
      end]]
      if nextbot:OnMove(pos) == false then
        self:MoveCursorToClosestPosition(nextbot:GetPos())
      else return old_Update(self, nextbot) end
    else return old_Update(self, nextbot) end
  end

  local old_Compute = pathMETA.Compute
  function pathMETA:Compute(nextbot, pos, generator)
    if nextbot.IsDrGNextbot then
      nextbot._DrGBaseLastCompute = nextbot._DrGBaseLastCompute or 0
      local delay = nextbot:GetPathComputeDelay()*(1.05^(#DrGBase.GetNextbots()-1))
      if delay > 2 then delay = 2 end
      if IsValid(self) and CurTime() < nextbot._DrGBaseLastCompute + delay then
        self:ResetAge()
        return nextbot._DrGBaseLastComputeSuccess
      else
        nextbot._DrGBaseLastCompute = CurTime()
        if not isfunction(generator) then
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
              height < nextbot.ClimbLaddersUpMinHeight or
              height > nextbot.ClimbLaddersUpMaxHeight or
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
              if IsValid(ladder) and (not nextbot.ClimbLaddersDown or
              drop < nextbot.ClimbLaddersDownMinHeight or
              drop > nextbot.ClimbLaddersDownMaxHeight or
              drop < nextbot.loco:GetDeathDropHeight()) then return -1 end
              if IsValid(ladder) then
                cost = nextbot:OnComputePathClimbLadderDown(cost, dist, self, area, fromArea, ladder, elevator, length)
              elseif drop < nextbot.loco:GetDeathDropHeight() then
                cost = nextbot:OnComputePathDrop(cost, dist, self, area, fromArea, ladder, elevator, length)
              else return -1 end
        		end
            if area:IsUnderwater() then
              cost = nextbot:OnComputePathUnderwater(cost, dist, self, area, fromArea, ladder, elevator, length)
            end
        		return nextbot:OnComputePath(cost, dist, self, area, fromArea, ladder, elevator, length)
          end
        end
        nextbot._DrGBaseLastComputeSuccess = old_Compute(self, nextbot, pos, generator)
        return nextbot._DrGBaseLastComputeSuccess
      end
    else return old_Compute(self, nextbot, pos, generator) end
  end

end
