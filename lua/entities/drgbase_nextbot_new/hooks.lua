if SERVER then

  -- Water level --

  hook.Add("OnEntityWaterLevelChanged", "DrGBaseNextbotWaterLevel", function(ent, old, new)
    if not ent.IsDrGNextbot2 then return end
    if isfunction(ent.OnWaterLevelChange) then
      ent:OnWaterLevelChange(old, new)
    end
    if isfunction(ent.OnWaterLevelChanged) then
      ent:ReactInCoroutine(ent.OnWaterLevelChanged, old, new)
    end
  end)

  -- Touch/leave ground --

  function ENT:_DrGBaseOnLandOnGround(...)
    if isfunction(self.OnLandedOnGround) then
      self:ReactInCoroutine(self.OnLandedOnGround, ...)
    end
  end

  function ENT:_DrGBaseOnLeaveGround(...)
    if isfunction(self.OnLeftGround) then
      self:ReactInCoroutine(self.OnLeftOnGround, ...)
    end
  end

end