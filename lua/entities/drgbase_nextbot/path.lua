if CLIENT then return end

-- Convars --

local ComputeDelay = CreateConVar("drgbase_compute_delay", "0.1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local ComputeOptim = CreateConVar("drgbase_compute_optimisation", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- Getters/setters --

function ENT:GetPath()
  self._DrGBasePath = self._DrGBasePath or Path("Follow")
  return self._DrGBasePath
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
  return path:Compute(self, pos, generator)
end

-- Hooks --

local function MultiplyCost(nextbot, callback, cost, dist, ...)
  local res = callback(nextbot, ...)
  local mult = math.Clamp(res, 0, math.huge)+1
  return cost + dist*mult, res < 0
end
function ENT:OnComputePath(from, to) return 0 end
function ENT:OnComputePathLadderUp(from, to, ladder) return 1 end
function ENT:OnComputePathLadderDown(from, to, ladder) return 1 end
function ENT:OnComputePathLedge(from, to, height) return 1 end
function ENT:OnComputePathStep(from, to, height) return 0 end
function ENT:OnComputePathJump(from, to, height) return 1 end
function ENT:OnComputePathDrop(from, to, drop) return 1 end
function ENT:OnComputePathUnderwater(cost, dist) return 1 end

-- Meta --

local pathMETA = FindMetaTable("PathFollower")

local old_Compute = pathMETA.Compute
function pathMETA:Compute(nextbot, pos, generator, meta)
  if nextbot.IsDrGNextbot then
    local delay = math.Clamp(ComputeDelay:GetFloat()*(1+(#DrGBase.GetNextbots()-1)/(10/ComputeOptim:GetFloat())), 0.1, math.huge)
    if not IsValid(self) or CurTime() > nextbot._DrGBaseLastComputeTime + delay or meta == "stupid metatables" then
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
          local unreach = false
      		local cost = dist + fromArea:GetCostSoFar()
      		local height = fromArea:ComputeAdjacentConnectionHeightChange(area)
          if height > 0 then
            if IsValid(ladder) and (not nextbot.ClimbLaddersUp or
            height < nextbot.ClimbLaddersUpMinHeight or
            height > nextbot.ClimbLaddersUpMaxHeight or
            height < nextbot.loco:GetStepHeight() or
            height < nextbot.loco:GetJumpHeight()) then return -1 end
            if IsValid(ladder) then
              cost, unreach = MultiplyCost(nextbot, nextbot.OnComputePathLadderUp, cost, dist, fromArea, area, ladder)
              if unreach then return -1 end
            elseif height < nextbot.loco:GetStepHeight() then
              cost, unreach = MultiplyCost(nextbot, nextbot.OnComputePathStep, cost, dist, fromArea, area, height)
              if unreach then return -1 end
            elseif height < nextbot.loco:GetJumpHeight() then
              cost, unreach = MultiplyCost(nextbot, nextbot.OnComputePathJump, cost, dist, fromArea, area, height)
              if unreach then return -1 end
            elseif nextbot.ClimbLedges then
              if height < nextbot.ClimbLedgesMinHeight then return -1 end
              if height > nextbot.ClimbLedgesMaxHeight then return -1 end
              cost, unreach = MultiplyCost(nextbot, nextbot.OnComputePathLedge, cost, dist, fromArea, area, height)
              if unreach then return -1 end
            else return -1 end
      		elseif height < 0 then
            local drop = -height
            if IsValid(ladder) and (not nextbot.ClimbLaddersDown or
            drop < nextbot.ClimbLaddersDownMinHeight or
            drop > nextbot.ClimbLaddersDownMaxHeight or
            drop < nextbot.loco:GetDeathDropHeight()) then return -1 end
            if IsValid(ladder) then
              cost, unreach = MultiplyCost(nextbot, nextbot.OnComputePathLadderDown, cost, dist, fromArea, area, ladder)
              if unreach then return -1 end
            elseif drop < nextbot.loco:GetDeathDropHeight() then
              cost, unreach = MultiplyCost(nextbot, nextbot.OnComputePathDrop, cost, dist, fromArea, area, drop)
              if unreach then return -1 end
            else return -1 end
      		end
          if area:IsUnderwater() then
            cost, unreach = MultiplyCost(nextbot, nextbot.OnComputePathUnderwater, cost, dist, fromArea, area)
            if unreach then return -1 end
          end
          cost, unreach = MultiplyCost(nextbot, nextbot.OnComputePath, cost, dist, fromArea, area)
          if unreach then return -1 end
          return cost
        end
      end
      nextbot._DrGBaseLastComputeTime = CurTime()
      nextbot._DrGBaseLastComputeSuccess = old_Compute(self, nextbot, pos, generator, "stupid metatables")
      return nextbot._DrGBaseLastComputeSuccess
    else
      self:ResetAge()
      return nextbot._DrGBaseLastComputeSuccess
    end
  else return old_Compute(self, nextbot, pos, generator) end
end
