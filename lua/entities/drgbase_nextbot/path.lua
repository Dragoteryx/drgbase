if CLIENT then return end

local pathMETA = FindMetaTable("PathFollower")

function pathMETA:DrG_Compute(nextbot, pos, generator)
  if nextbot.IsDrGNextbot then
    if generator == nil then generator = function(area, fromArea, ladder, elevator, length)
    	if not IsValid(fromArea) then return 0 end
  		if not nextbot.loco:IsAreaTraversable(area) then return -1 end
  		local dist = 0
  		if IsValid(ladder) then
        if not nextbot.ClimbLadders then return -1 end
  			dist = ladder:GetLength()
  		elseif length > 0 then
  			dist = length
  		else
  			dist = (area:GetCenter() - fromArea:GetCenter()):GetLength()
  		end
  		local cost = dist + fromArea:GetCostSoFar()
  		local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange(area)
      if deltaZ < -nextbot.loco:GetDeathDropHeight() then
  			return -1
      elseif deltaZ >= nextbot.loco:GetStepHeight() then
        if not IsValid(ladder) and deltaZ >= nextbot.loco:GetMaxJumpHeight() then
          if nextbot.ClimbWalls then
            if deltaZ > nextbot.ClimbWallsMaxHeight or deltaZ < nextbot.ClimbWallsMinHeight then
              return -1
            end
  				else return -1 end
  			end
  			cost = cost + dist
  		end
  		return cost
  	end end
    nextbot._DrGBaseLastComputeInfraction = nextbot._DrGBaseLastComputeInfraction or 0
  	if CurTime() < nextbot._DrGBaseLastComputeInfraction + 7 then return false end
  	local now = CurTime()
  	local compute = self:Compute(nextbot, pos, generator)
  	if CurTime() - now > 0.005 then
  		nextbot._DrGBaseLastComputeInfraction = CurTime()
  	end
  	return compute
  else return self:Compute(nextbot, pos, generator) end
end
