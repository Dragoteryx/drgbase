if CLIENT then return end

local pathMETA = FindMetaTable("PathFollower")

function pathMETA:DrG_Compute(nextbot, pos, generator)
  if nextbot.IsDrGNextbot then
  	return DrGBase.Navmesh.ComputePath(self, nextbot, pos, generator)
  else return self:Compute(nextbot, pos, generator) end
end
