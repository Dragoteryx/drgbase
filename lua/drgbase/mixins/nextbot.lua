return function(ENT)

  if SERVER then

    -- Damage hooks --

    if isfunction(ENT.OnTraceAttack) then
      local OnTraceAttack = ENT.OnTraceAttack
      function ENT:OnTraceAttack(...)
        local res = OnTraceAttack(self, ...)
        self:DrG_OnTraceAttack(...)
        return res
      end
    end

    if isfunction(ENT.OnInjured) then
      local OnInjured = ENT.OnInjured
      function ENT:OnInjured(...)
        local res = OnInjured(self, ...)
        self:DrG_OnInjured(...)
        return res
      end
    end

    if isfunction(ENT.OnKilled) then
      local OnKilled = ENT.OnKilled
      function ENT:OnKilled(...)
        local res = OnKilled(self, ...)
        self:DrG_OnKilled(...)
        return res
      end
    end

    -- Misc hooks --

    if isfunction(ENT.OnLandOnGround) then
      local OnLandOnGround = ENT.OnLandOnGround
      function ENT:OnLandOnGround(...)
        self:DrG_OnLandOnGround(...)
        return OnLandOnGround(self, ...)
      end
    end

    if isfunction(ENT.OnLeaveGround) then
      local OnLeaveGround = ENT.OnLeaveGround
      function ENT:OnLeaveGround(...)
        self:DrG_OnLeaveGround(...)
        return OnLeaveGround(self, ...)
      end
    end

    if isfunction(ENT.OnIgnite) then
      local OnIgnite = ENT.OnIgnite
      function ENT:OnIgnite(...)
        self:DrG_OnIgnite(...)
        return OnIgnite(self, ...)
      end
    end

    if isfunction(ENT.OnContact) then
      local OnContact = ENT.OnContact
      function ENT:OnContact(ent, ...)
        self:DrG_OnContact(ent, ...)
        return OnContact(self, ent, ...)
      end
    end

    if isfunction(ENT.OnNavAreaChanged) then
      local OnNavAreaChanged = ENT.OnNavAreaChanged
      function ENT:OnNavAreaChanged(old, new, ...)
        self:DrG_OnNavAreaChanged(old, new, ...)
        return OnNavAreaChanged(self, old, new, ...)
      end
    end

    -- HandleAnimEvent --

    if isfunction(ENT.HandleAnimEvent) then
      local HandleAnimEvent = ENT.HandleAnimEvent
      function ENT:HandleAnimEvent(event, time, cycle, type, options)
        local res = self:OnAnimEvent(options, event, self:GetPos(), self:GetAngles(), time)
        self:ReactInCoroutine(self.DoAnimEvent, options, event, self:GetPos(), self:GetAngles(), time)
        local res2 = HandleAnimEvent(self, event, time, cycle, type, options)
        if res == true or res2 == true then return true end
      end
    end

  else

    -- FireAnimationEvent --

    if isfunction(ENT.FireAnimationEvent) then
      local FireAnimationEvent = ENT.FireAnimationEvent
      function ENT:FireAnimationEvent(pos, angle, event, name)
        local res = self:OnAnimEvent(name, event, pos, angle, CurTime())
        local res2 = FireAnimationEvent(self, pos, angle, event, name)
        if res == true or res2 == true then return true end
      end
    end

  end

end