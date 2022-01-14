
local entMETA = FindMetaTable("Entity")

if SERVER then

  local GetVelocity = entMETA.GetVelocity
  function entMETA:GetVelocity()
    if self.IsDrGProjectile then
      local phys = self:GetPhysicsObject()
      if IsValid(phys) then
        return phys:GetVelocity()
      else return GetVelocity(self) end
    else return GetVelocity(self) end
  end

  local SetVelocity = entMETA.SetVelocity
  function entMETA:SetVelocity(velocity)
    if self.IsDrGProjectile then
      local phys = self:GetPhysicsObject()
      if IsValid(phys) then
        return phys:SetVelocity(velocity)
      else return SetVelocity(self, velocity) end
    else return SetVelocity(self, velocity) end
  end

end
