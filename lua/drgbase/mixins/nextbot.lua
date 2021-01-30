return function(ENT)

  if SERVER then

    -- Damage hooks --

    if isfunction(ENT.OnTraceAttack) then
      local old_OnTraceAttack = ENT.OnTraceAttack
      function ENT:OnTraceAttack(...)
        local res = old_OnTraceAttack(self, ...)
        self:DrG_OnTraceAttack(...)
        return res
      end
    end

    if isfunction(ENT.OnInjured) then
      function ENT:OnInjured(...)
        self:DrG_OnInjured(...)
      end
    end

    if isfunction(ENT.OnKilled) then
      function ENT:OnKilled(...)
        self:DrG_OnKilled(...)
      end
    end

    -- Misc hooks --

    if isfunction(ENT.OnLandOnGround) then
      local old_OnLandOnGround = ENT.OnLandOnGround
      function ENT:OnLandOnGround(...)
        self:DrG_OnLandOnGround(...)
        return old_OnLandOnGround(self, ...)
      end
    end

    if isfunction(ENT.OnLeaveGround) then
      local old_OnLeaveGround = ENT.OnLeaveGround
      function ENT:OnLeaveGround(...)
        self:DrG_OnLeaveGround(...)
        return old_OnLeaveGround(self, ...)
      end
    end

    if isfunction(ENT.OnIgnite) then
      local old_OnIgnite = ENT.OnIgnite
      function ENT:OnIgnite(...)
        self:DrG_OnIgnite(...)
        return old_OnIgnite(self, ...)
      end
    end

    if isfunction(ENT.OnContact) then
      local old_OnContact = ENT.OnContact
      function ENT:OnContact(ent, ...)
        self:DrG_OnContact(ent, ...)
        return old_OnContact(self, ent, ...)
      end
    end

    if isfunction(ENT.OnNavAreaChanged) then
      local old_OnNavAreaChanged = ENT.OnNavAreaChanged
      function ENT:OnNavAreaChanged(old, new, ...)
        self:DrG_OnNavAreaChanged(old, new, ...)
        return old_OnNavAreaChanged(self, old, new, ...)
      end
    end

    -- HandleAnimEvent --

    if isfunction(ENT.HandleAnimEvent) then
      local old_HandleAnimEvent = ENT.HandleAnimEvent
      function ENT:HandleAnimEvent(event, time, cycle, type, options)
        local res = self:OnAnimEvent(options, event, self:GetPos(), self:GetAngles(), time)
        self:ReactInCoroutine(self.DoAnimEvent, options, event, self:GetPos(), self:GetAngles(), time)
        local res2 = old_HandleAnimEvent(self, event, time, cycle, type, options)
        if res == true or res2 == true then return true end
      end
    end

  else

    -- FireAnimationEvent --

    if isfunction(ENT.FireAnimationEvent) then
      local old_FireAnimationEvent = ENT.FireAnimationEvent
      function ENT:FireAnimationEvent(pos, angle, event, name)
        local res = self:OnAnimEvent(name, event, pos, angle, CurTime())
        local res2 = old_FireAnimationEvent(self, pos, angle, event, name)
        if res == true or res2 == true then return true end
      end
    end

  end

end