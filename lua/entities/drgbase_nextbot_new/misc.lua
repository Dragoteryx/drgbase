if SERVER then

  function ENT:Attack(attack, callback)
    if isfunction(callback) then
      self:Timer(isnumber(attack.delay) and attack.delay or 0, function(self)
        local hit = self:Attack(attack)
        callback(self, hit)
      end)
    else
      -- attack code
    end
  end

  -- Meta --

  local entMETA = FindMetaTable("Entity")

  local old_GetVelocity = entMETA.GetVelocity
  function entMETA:GetVelocity(...)
    if self.IsDrGNextbot2 then
      return self.loco:GetVelocity()
    else return old_GetVelocity(self, ...) end
  end

  local old_SetVelocity = entMETA.SetVelocity
  function entMETA:SetVelocity(velocity, ...)
    if self.IsDrGNextbot2 then
      return self.loco:SetVelocity(velocity, ...)
    else return old_SetVelocity(self, velocity, ...) end
  end

end