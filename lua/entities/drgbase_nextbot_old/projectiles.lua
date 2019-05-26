
if SERVER then

  function ENT:CreateProjectile(model, offset, angles, binds, class)
    offset = offset or Vector(0, 0, 0)
    angles = angles or Angle(0, 0, 0)
    local proj = DrGBase.CreateProjectile(model,
      self:GetPos() + self:GetForward()*offset.x + self:GetRight()*offset.y + self:GetUp()*offset.z,
    self:GetAngles() + angles, binds, class)
    proj:SetOwner(self)
    self._DrGBaseThrownProjectiles = self._DrGBaseThrownProjectiles or {}
    table.insert(self._DrGBaseThrownProjectiles, proj)
    proj:CallOnRemove("DrGBaseProjRemove", function()
      if not IsValid(self) then return end
      table.RemoveByValue(self._DrGBaseThrownProjectiles, proj)
    end)
    return proj
  end

  function ENT:DefineProjectile(name, model, offset, angles, binds, class)
    self._DrGBaseDefinedProjectiles = self._DrGBaseDefinedProjectiles or {}
    self._DrGBaseDefinedProjectiles[name] = {
      model = model,
      offset = offset,
      angles = angles,
      binds = binds,
      class = class
    }
  end

  function ENT:RemoveProjectile(name)
    self._DrGBaseDefinedProjectiles = self._DrGBaseDefinedProjectiles or {}
    self._DrGBaseDefinedProjectiles[name] = nil
  end

  function ENT:CallProjectile(name)
    self._DrGBaseDefinedProjectiles = self._DrGBaseDefinedProjectiles or {}
    local proj = self._DrGBaseDefinedProjectiles[name]
    if proj == nil then return end
    return self:CreateProjectile(proj.model, proj.offset, proj.angles, proj.binds, proj.class)
  end

  function ENT:CallRandomProjectile()
    self._DrGBaseDefinedProjectiles = self._DrGBaseDefinedProjectiles or {}
    if table.Count(self._DrGBaseDefinedProjectiles) == 0 then return end
    local projectile, name = table.Random(self._DrGBaseDefinedProjectiles)
    self:CallProjectile(name)
  end

  -- Helpers --

  function ENT:ThrownProjectiles()
    return self._DrGBaseThrownProjectiles or {}
  end

end
