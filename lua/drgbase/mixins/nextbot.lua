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

    -- HandleAnimEvent --

    if isfunction(ENT.HandleAnimEvent) then
      local old_HandleAnimEvent = ENT.HandleAnimEvent
      function ENT:HandleAnimEvent(event, time, cycle, type, options)
        self:OnAnimEvent(options, event, self:GetPos(), self:GetAngles(), time)
        self:ReactInThread(self.DoAnimEvent, options, event, self:GetPos(), self:GetAngles(), time)
        return old_HandleAnimEvent(self, event, time, cycle, type, options)
      end
    end

  else

    -- FireAnimationEvent --

    if isfunction(ENT.FireAnimationEvent) then
      local old_FireAnimationEvent = ENT.FireAnimationEvent
      function ENT:FireAnimationEvent(pos, angle, event, name)
        if self.OnAnimEvent then self:OnAnimEvent(name, event, pos, angle, CurTime()) end
        return old_FireAnimationEvent(self, pos, angle, event, name)
      end
    end

  end

end