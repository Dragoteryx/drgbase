local MIXIN = {}

if SERVER then

  -- Damage hooks --

  function MIXIN:OnTakeDamage(dmg, hitgroup)
    if not isnumber(hitgroup) then return end
    return self.DrG_Mixin.OnTakeDamage(self, dmg, hitgroup)
  end

  function MIXIN:OnTraceAttack(...)
    local res = self.DrG_Mixin.OnTraceAttack(self, ...)
    self:DrG_OnTraceAttack(...)
    return res
  end

  function MIXIN:OnInjured(...)
    local res = self.DrG_Mixin.OnInjured(self, ...)
    self:DrG_OnInjured(...)
    return res
  end


  function MIXIN:OnKilled(...)
    local res = self.DrG_Mixin.OnKilled(self, ...)
    self:DrG_OnKilled(...)
    return res
  end

  -- Misc hooks --

  function MIXIN:OnLandOnGround(...)
    self:DrG_OnLandOnGround(...)
    return self.DrG_Mixin.OnLandOnGround(self, ...)
  end

  function MIXIN:OnLeaveGround(...)
    self:DrG_OnLeaveGround(...)
    return self.DrG_Mixin.OnLeaveGround(self, ...)
  end

  function MIXIN:OnIgnite(...)
    self:DrG_OnIgnite(...)
    return self.DrG_Mixin.OnIgnite(self, ...)
  end

  function MIXIN:OnContact(ent, ...)
    self:DrG_OnContact(ent, ...)
    return self.DrG_Mixin.OnContact(self, ent, ...)
  end

  function MIXIN:OnNavAreaChanged(old, new, ...)
    self:DrG_OnNavAreaChanged(old, new, ...)
    return self.DrG_Mixin.OnNavAreaChanged(self, old, new, ...)
  end

  -- HandleAnimEvent --

  function MIXIN:HandleAnimEvent(event, time, cycle, type, options)
    local res = self:OnAnimEvent(options, event, self:GetPos(), self:GetAngles(), time)
    self:ReactInCoroutine(self.DoAnimEvent, options, event, self:GetPos(), self:GetAngles(), time)
    if not res then self:DrG_BuiltInEvents(options) end
    local res2 = self.DrG_Mixin.HandleAnimEvent(self, event, time, cycle, type, options)
    if res == true or res2 == true then return true end
  end

else

  -- FireAnimationEvent --

  function MIXIN:FireAnimationEvent(pos, angle, event, name)
    local res = self:OnAnimEvent(name, event, pos, angle, CurTime())
    if not res then self:DrG_BuiltInEvents(name) end
    local res2 = self.DrG_Mixin.FireAnimationEvent(self, pos, angle, event, name)
    if res == true or res2 == true then return true end
  end

end

return MIXIN