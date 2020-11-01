if SERVER then

  -- Water level --

  hook.Add("OnEntityWaterLevelChanged", "DrG/NextbotWaterLevel", function(ent, old, new)
    if not ent.IsDrGNextbot then return end
    ent:OnWaterLevelChanged(old, new)
    ent:ReactInThread(ent.DoWaterLevelChanged, old, new)
  end)
  function ENT:OnWaterLevelChanged() end

  -- Fire --

  function ENT:OnIgnite() end
  function ENT:DrG_OnIgnite(...)
    self:ReactInThread(self.DoIgnite, ...)
    self.DrG_OnFire = true
  end

  function ENT:OnExtinguish() end

  -- Touch/leave ground --

  function ENT:OnLandOnGround() end
  function ENT:DrG_OnLandOnGround(...)
    self:ReactInThread(self.DoLandOnGround, ...)
    self:InvalidatePath()
  end

  function ENT:OnLeaveGround() end
  function ENT:DrG_OnLeaveGround(...)
    self:ReactInThread(self.DoLeaveOnGround, ...)
  end

  -- Misc --

  function ENT:Use() end
  function ENT:DrG_Use(...)
    self:ReactInThread(self.DoUse, ...)
  end
  function ENT:DrG_OnContact(...)
    self:ReactInThread(self.DoContact, ...)
  end

end