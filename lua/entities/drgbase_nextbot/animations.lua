
if SERVER then

  function ENT:BodyUpdate()
    if self.EnableBodyMoveXY then
      self:BodyMoveXY()
    else
      if self:IsPossessed() then
        local moveX = math.Round(self:GetPoseParameter("move_x"), 1)
        local moveY = math.Round(self:GetPoseParameter("move_y"), 1)
        local possessor = self:GetPossessor()
        local front = possessor:KeyDown(IN_FORWARD)
        local back = possessor:KeyDown(IN_BACK)
        local left = possessor:KeyDown(IN_MOVELEFT)
        local right = possessor:KeyDown(IN_MOVERIGHT)
        if front and not back then
          self:SetPoseParameter("move_x", moveX+0.1)
        elseif back and not front then
          self:SetPoseParameter("move_x", moveX-0.1)
        elseif moveX > 0 then
          self:SetPoseParameter("move_x", moveX-0.1)
        elseif moveX < 0 then
          self:SetPoseParameter("move_x", moveX+0.1)
        end
        if right and not left then
          self:SetPoseParameter("move_y", moveY+0.1)
        elseif left and not right then
          self:SetPoseParameter("move_y", moveY-0.1)
        elseif moveY > 0 then
          self:SetPoseParameter("move_y", moveY-0.1)
        elseif moveY < 0 then
          self:SetPoseParameter("move_y", moveY+0.1)
        end
      else
        self:SetPoseParameter("move_x", 1)
        self:SetPoseParameter("move_y", 0)
      end
      self:FrameAdvance()
    end
  end

  function ENT:PlaySequenceAndWait(name, speed, callback)
    local len = self:SetSequence(name)
    speed = speed or 1
    if callback == nil then callback = function() end end
    self:ResetSequenceInfo()
    self:SetCycle(0)
    self:SetPlaybackRate(speed)
    local synced = self:EnableSyncedAnimations()
    self:EnableSyncedAnimations(false)
    local delay = CurTime() + len/speed
    while CurTime() < delay and not self:IsDying() do
      if callback() then break end
      coroutine.yield()
    end
    self:EnableSyncedAnimations(synced)
  end

  function ENT:PlayGesture(seq)
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if self._DrGBaseCurrentGestures[seq] ~= nil and CurTime() <= self._DrGBaseCurrentGestures[seq] then return false end
    self._DrGBaseCurrentGestures[seq] = CurTime() + self:SequenceDuration(seq)
    self:AddGestureSequence(seq)
    return true
  end

  function ENT:AddSequenceCallback(seq, delays, callback)
    if isstring(seq) then seq = self:LookupSequence(seq) end
    self._DrGBaseSequenceCallbacks[seq] = self._DrGBaseSequenceCallbacks[seq] or {}
    if not istable(delays) then delays = {delays} end
    for i, delay in ipairs(delays) do
      table.insert(self._DrGBaseSequenceCallbacks[seq], {
        delay = delay,
        callback = callback
      })
    end
  end

  function ENT:RemoveSequenceCallbacks(seq)
    if isstring(seq) then seq = self:LookupSequence(seq) end
    self._DrGBaseSequenceCallbacks[seq] = {}
  end

  -- Handlers --

  function ENT:EnableSyncedAnimations(bool)
    if bool == nil then return self._DrGBaseSyncAnimations
    elseif bool then self._DrGBaseSyncAnimations = true
    else self._DrGBaseSyncAnimations = false end
  end

  function ENT:_HandleAnimations()
    if self:IsOnGround() then
      local angles = self:GetAngles()
      angles.p = 0
      angles.r = 0
      self:SetAngles(angles)
    end
    if CurTime() < self._DrGBaseHandleAnimDelay then return end
    self._DrGBaseHandleAnimDelay = CurTime() + 0.1
    local curr = self._DrGBaseCurrentAnimCount
    local speed = self:Speed()
    local upOnly = false
    local downOnly = false
    if self:IsFlying() then
      if self:IsPossessed() then
        local possessor = self:GetPossessor()
        local up = possessor:KeyDown(IN_JUMP)
        local down = possessor:KeyDown(IN_DUCK)
        upOnly = up and not down
        downOnly = down and not up
      end
    end
    local seq, rate
    if self:EnableSyncedAnimations() then
      seq, rate = self:SyncAnimation(speed, self:IsOnGround(), self:IsFlying(), upOnly, downOnly)
    else seq = self:GetSequenceName(self:GetSequence()) end
    if seq == nil then return end
    seq = string.lower(seq)
    if rate == nil then
      if self:EnableSyncedAnimations() then rate = 1
      else rate = self:GetPlaybackRate() end
    end
    if self._DrGBaseCurrentAnimLastCycle > self:GetCycle() or
    seq ~= self._DrGBaseCurrentAnim or
    math.Round(rate, 1) ~= math.Round(self._DrGBaseCurrentAnimRate, 1) then
      self:ResetSequence(seq)
      self:SetPlaybackRate(rate)
      self._DrGBaseCurrentAnimCount = self._DrGBaseCurrentAnimCount + 1
      local curr = self._DrGBaseCurrentAnimCount
      if self._DrGBaseSequenceCallbacks[self:LookupSequence(seq)] ~= nil then
        for i, todo in ipairs(self._DrGBaseSequenceCallbacks[self:LookupSequence(seq)]) do
          self:Timer(todo.delay*(self:SequenceDuration(self:LookupSequence(seq))/rate), function()
            if curr ~= self._DrGBaseCurrentAnimCount then return end
            todo.callback(todo.delay, self:GetCycle())
          end)
        end
      end
    end
    self._DrGBaseCurrentAnim = string.lower(self:GetSequenceName(self:GetSequence()))
    self._DrGBaseCurrentAnimRate = self:GetPlaybackRate()
    self._DrGBaseCurrentAnimLastCycle = self:GetCycle()
  end
  function ENT:SyncAnimation() end

else



end
