
if SERVER then

  function ENT:BodyUpdate()
    if self.EnableBodyMoveXY then
      self:BodyMoveXY()
    else
      local moveX = math.Round(self:GetPoseParameter("move_x"), 1)
      local moveY = math.Round(self:GetPoseParameter("move_y"), 1)
      if self:IsMovingForward() then
        self:SetPoseParameter("move_x", moveX+0.1)
      elseif self:IsMovingBackward() then
        self:SetPoseParameter("move_x", moveX-0.1)
      elseif moveX > 0 then
        self:SetPoseParameter("move_x", moveX-0.1)
      elseif moveX < 0 then
        self:SetPoseParameter("move_x", moveX+0.1)
      end
      if self:IsMovingRight() then
        self:SetPoseParameter("move_y", moveY+0.1)
      elseif self:IsMovingLeft() then
        self:SetPoseParameter("move_y", moveY-0.1)
      elseif moveY > 0 then
        self:SetPoseParameter("move_y", moveY-0.1)
      elseif moveY < 0 then
        self:SetPoseParameter("move_y", moveY+0.1)
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

  function ENT:AddSequenceCallback(seq, cycles, callback)
    if isstring(seq) then seq = self:LookupSequence(seq) end
    self._DrGBaseSequenceCallbacks[seq] = self._DrGBaseSequenceCallbacks[seq] or {}
    if not istable(cycles) then cycles = {cycles} end
    for i, cycle in ipairs(cycles) do
      table.insert(self._DrGBaseSequenceCallbacks[seq], {
        cycle = cycle,
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
    local seq, rate
    if self:EnableSyncedAnimations() then
      seq, rate = self:SyncAnimation(self:Speed(), self:IsOnGround(), self:IsFlying())
    else
      seq = self:GetSequence()
      rate = self:GetPlaybackRate()
    end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    local callbacks = self._DrGBaseSequenceCallbacks[seq]
    if callbacks ~= nil then
      for i, todo in ipairs(callbacks) do
        if self._DrGBaseLastAnimCycle < todo.cycle and self:GetCycle() >= todo.cycle then
          todo.callback(todo.cycle, self:GetCycle())
        end
      end
    end
    self._DrGBaseLastAnimCycle = self:GetCycle()
    self:SetPlaybackRate(rate or 1)
    if seq ~= -1 and (seq ~= self:GetSequence() or self:GetCycle() == 1) then
      self:ResetSequence(seq)
    end
  end
  function ENT:SyncAnimation() end

else



end
