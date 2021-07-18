if SERVER then

  -- Water level --

  hook.Add("OnEntityWaterLevelChanged", "DrG/NextbotWaterLevel", function(ent, old, new)
    if not ent.IsDrGNextbot then return end
    ent:OnWaterLevelChanged(old, new)
    ent:ReactInCoroutine(ent.DoWaterLevelChanged, old, new)
  end)
  function ENT:OnWaterLevelChanged() end

  -- Fire --

  function ENT:OnIgnite() end
  function ENT:DrG_OnIgnite(...)
    self:ReactInCoroutine(self.DoIgnite, ...)
    self.DrG_OnFire = true
  end

  function ENT:OnExtinguish() end

  -- Touch/leave ground --

  function ENT:OnLandOnGround() end
  function ENT:DrG_OnLandOnGround(...)
    self:ReactInCoroutine(self.DoLandOnGround, ...)
    self:InvalidatePath()
  end

  function ENT:OnLeaveGround() end
  function ENT:DrG_OnLeaveGround(...)
    self:ReactInCoroutine(self.DoLeaveGround, ...)
  end

  -- Misc --

  function ENT:Use() end
  function ENT:DrG_Use(...)
    self:ReactInCoroutine(self.DoUse, ...)
  end
  function ENT:DrG_OnContact(...)
    self:ReactInCoroutine(self.DoContact, ...)
  end

  function ENT:OnAngleChange(ang)
    self:SetAngles(Angle(0, ang.y, 0))
  end

  function ENT:HandleAnimEvent() end
  function ENT:OnAnimEvent() end

else

  function ENT:FireAnimationEvent() end
  function ENT:OnAnimEvent() end

end