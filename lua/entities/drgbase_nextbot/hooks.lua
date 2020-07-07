if SERVER then

  -- Water level --

  hook.Add("OnEntityWaterLevelChanged", "DrGBaseNextbotWaterLevel", function(ent, old, new)
    if not ent.IsDrGNextbot then return end
    ent:OnWaterLevelChange(old, new)
    ent:ReactInCoroutine(ent.DoOnWaterLevelChange, old, new)
  end)
  function ENT:OnWaterLevelChange() end

  -- Touch/leave ground --

  function ENT:_DrGBaseOnLandOnGround(...)
    self:ReactInCoroutine(self.DoOnLandOnGround, ...)
  end
  function ENT:OnLandOnGround() end

  function ENT:_DrGBaseOnLeaveGround(...)
    self:ReactInCoroutine(self.DoOnLeaveOnGround, ...)
  end
  function ENT:OnLeaveGround() end

end