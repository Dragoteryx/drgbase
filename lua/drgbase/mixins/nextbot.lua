local MIXIN = {}

if SERVER then

  -- Damage hooks --

  function MIXIN:OnTakeDamage(onTakeDamage, dmg, hitgroup)
    if not isnumber(hitgroup) then return end
    return onTakeDamage(self, dmg, hitgroup)
  end

  function MIXIN:OnTraceAttack(onTraceAttack, ...)
    local res = onTraceAttack(self, ...)
    self:DrG_OnTraceAttack(...)
    return res
  end

  function MIXIN:OnInjured(onInjured, ...)
    local res = onInjured(self, ...)
    self:DrG_OnInjured(...)
    return res
  end

  function MIXIN:OnKilled(onKilled, ...)
    local res = onKilled(self, ...)
    self:DrG_OnKilled(...)
    return res
  end

  -- Misc hooks --

  function MIXIN:OnLandOnGround(onLandOnGround, ...)
    self:DrG_OnLandOnGround(...)
    return onLandOnGround(self, ...)
  end

  function MIXIN:OnLeaveGround(onLeaveGround, ...)
    self:DrG_OnLeaveGround(...)
    return onLeaveGround(self, ...)
  end

  function MIXIN:OnIgnite(onIgnite, ...)
    self:DrG_OnIgnite(...)
    return onIgnite(self, ...)
  end

  function MIXIN:OnContact(onContact, ent, ...)
    self:DrG_OnContact(ent, ...)
    return onContact(self, ent, ...)
  end

  function MIXIN:OnNavAreaChanged(onNavAreaChanged, old, new, ...)
    self:DrG_OnNavAreaChanged(old, new, ...)
    return onNavAreaChanged(self, old, new, ...)
  end

  -- HandleAnimEvent --

  function MIXIN:HandleAnimEvent(handleAnimEvent, event, time, cycle, type, options)
    local res = self:OnAnimEvent(options, event, self:GetPos(), self:GetAngles(), time)
    self:ReactInCoroutine(self.DoAnimEvent, options, event, self:GetPos(), self:GetAngles(), time)
    if not res then self:DrG_BuiltInEvents(options) end
    local res2 = handleAnimEvent(self, event, time, cycle, type, options)
    if res == true or res2 == true then return true end
  end

else

  -- FireAnimationEvent --

  function MIXIN:FireAnimationEvent(fireAnimationEvent, pos, angle, event, name)
    local res = self:OnAnimEvent(name, event, pos, angle, CurTime())
    if not res then self:DrG_BuiltInEvents(name) end
    local res2 = fireAnimationEvent(self, pos, angle, event, name)
    if res == true or res2 == true then return true end
  end

end

return MIXIN