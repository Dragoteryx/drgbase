return function(ENT)

  if SERVER then

    -- Damage hooks --

    if isfunction(ENT.OnTraceAttack) then
      local old_OnTraceAttack = ENT.OnTraceAttack
      function ENT:OnTraceAttack(...)
        if self.IsDrGNextbot then self:_DrGBaseOnTraceAttack(...) end
        return old_OnTraceAttack(self, ...)
      end
    end

    if isfunction(ENT.OnInjured) then
      local old_OnInjured = ENT.OnInjured
      function ENT:OnInjured(...)
        if self.IsDrGNextbot then self:_DrGBaseOnInjured(...) end
        return old_OnInjured(self, ...)
      end
    end

    if isfunction(ENT.OnKilled) then
      local old_OnKilled = ENT.OnKilled
      function ENT:OnKilled(...)
        if self.IsDrGNextbot then self:_DrGBaseOnKilled(...) end
        return old_OnKilled(self, ...)
      end
    end

    -- Misc hooks --

    if isfunction(ENT.OnLandOnGround) then
      local old_OnLandOnGround = ENT.OnLandOnGround
      function ENT:OnLandOnGround(...)
        if self.IsDrGNextbot then self:_DrGBaseOnLandOnGround(...) end
        return old_OnLandOnGround(self, ...)
      end
    end

    if isfunction(ENT.OnLeaveGround) then
      local old_OnLeaveGround = ENT.OnLeaveGround
      function ENT:OnLeaveGround(...)
        if self.IsDrGNextbot then self:_DrGBaseOnLeaveGround(...) end
        return old_OnLeaveGround(self, ...)
      end
    end

    -- HandleAnimEvent --

    if isfunction(ENT.HandleAnimEvent) then
      local old_HandleAnimEvent = ENT.HandleAnimEvent
      function ENT:HandleAnimEvent(event, time, cycle, type, options)
        if self.IsDrGNextbot then self:OnAnimEvent(options, event, self:GetPos(), self:GetAngles()) end
        return old_HandleAnimEvent(self, event, time, cycle, type, options)
      end
    end

  else

    -- FireAnimationEvent --

    if isfunction(ENT.FireAnimationEvent) then
      local old_FireAnimationEvent = ENT.FireAnimationEvent
      function ENT:FireAnimationEvent(pos, angle, event, name)
        if self.IsDrGNextbot then self:OnAnimEvent(name, event, pos, angle) end
        return old_FireAnimationEvent(self, pos, angle, event, name)
      end
    end

  end

end