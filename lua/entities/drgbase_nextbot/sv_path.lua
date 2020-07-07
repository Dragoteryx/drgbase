function ENT:PathGenerator(area, fromArea, ladder, elevator, length)

end

-- Meta --

local pathMETA = FindMetaTable("PathFollower")

DrGBase.OLD_Compute = DrGBase.OLD_Compute or pathMETA.Compute
function pathMETA:Compute(nextbot, pos, ...)
  if nextbot.IsDrGNextbot then
    nextbot._DrGBaseLastComputeResult = DrGBase.OLD_Compute(self, nextbot, pos, function(...)
      return nextbot:PathGenerator(...)
    end)
    return nextbot._DrGBaseLastComputeResult
  else return DrGBase.OLD_Compute(self, nextbot, pos, ...) end
end