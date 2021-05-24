local physMETA = FindMetaTable("PhysObj")

function physMETA:DrG_AimAt(target, speed, feet)
  if self:IsDragEnabled() then self:EnableDrag(false) end
  if self:IsGravityEnabled() then
    local dir, info = self:GetPos():DrG_CalcBallisticTrajectory(target, {magnitude = speed}, true)
    if math.Round(dir:Length(), 1) > math.Round(speed, 1) then
      dir = dir:GetNormalized()*speed
      info.duration = -1
    end
    self:SetVelocity(dir)
    DrG_DebugTrajectory(self:GetPos(), dir, info)
    return dir, info
  else
    local dir, info = self:GetPos():DrG_CalcLineTrajectory(target, {speed = speed})
    self:SetVelocity(dir)
    DrG_DebugTrajectory(self:GetPos(), dir, info)
    return dir, info
  end
end
function physMETA:DrG_ThrowAt(target, options, recursive)
  if self:IsDragEnabled() then self:EnableDrag(false) end
  local dir, info = self:GetPos():DrG_CalcBallisticTrajectory(target, options, recursive)
  self:SetVelocity(dir)
  DrG_DebugTrajectory(self:GetPos(), dir, info)
  return dir, info
end