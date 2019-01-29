
local entMETA = FindMetaTable("Entity")

local old_EyePos = entMETA.EyePos
function entMETA:EyePos()
  if self.IsDrGNextbot then
    local bound1, bound2 = self:GetCollisionBounds()
    local eyepos = self:GetPos() + (bound1 + bound2)/2
    if isstring(self.EyeBone) then
      local boneid = self:LookupBone(self.EyeBone)
      if boneid ~= nil then
        eyepos = self:GetBonePosition(boneid)
      end
    end
    eyepos = eyepos +
    self:GetForward()*self.EyeOffset.x*self:GetModelScale() +
    self:GetRight()*self.EyeOffset.y*self:GetModelScale() +
    self:GetUp()*self.EyeOffset.z*self:GetModelScale()
    return eyepos
  else return old_EyePos(self) end
end

local old_EyeAngles = entMETA.EyeAngles
function entMETA:EyeAngles()
  if self.IsDrGNextbot then
    if isstring(self.EyeBone) then
      local boneid = self:LookupBone(self.EyeBone)
      if boneid ~= nil then
        local pos, angle = self:GetBonePosition(boneid)
        return angle + self.EyeAngle
      end
    end
    return self:GetAngles() + self.EyeAngle
  else return old_EyeAngles(self) end
end

if SERVER then

  local old_GetVelocity = entMETA.GetVelocity
  function entMETA:GetVelocity()
    if self.IsDrGNextbot then
      return self.loco:GetVelocity()
    else return old_GetVelocity(self) end
  end

  local old_SetVelocity = entMETA.SetVelocity
  function entMETA:SetVelocity(velocity)
    if self.IsDrGNextbot then
      return self.loco:SetVelocity(velocity)
    else return old_SetVelocity(self, velocity) end
  end

else

  local old_Health = entMETA.Health
  function entMETA:Health()
    if self.IsDrGNextbot then
      return self:GetDrGVar("DrGBaseHealth")
    else return old_Health(self) end
  end

  local old_GetMaxHealth = entMETA.GetMaxHealth
  function entMETA:GetMaxHealth()
    if self.IsDrGNextbot then
      return self:GetDrGVar("DrGBaseMaxHealth")
    else return old_GetMaxHealth(self) end
  end

end
