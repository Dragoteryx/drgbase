
function ENT:PrintPoseParameters()
  for i = 0, self:GetNumPoseParameters() - 1 do
  	local min, max = self:GetPoseParameterRange(i)
  	print(self:GetPoseParameterName(i).." "..min.." / "..max)
  end
end

function ENT:PrintAnimations()
  for i, seq in pairs(self:GetSequenceList()) do
    print(i.." - "..seq.." / "..self:GetSequenceActivityName(i))
  end
end

if SERVER then

  function ENT:BodyUpdate()
    if self.AnimationType == DRGBASE_ANIMTYPE_SIMPLE or self:IsClimbing() then
      self:FrameAdvance()
    elseif self.AnimationType == DRGBASE_ANIMTYPE_COMPLEX then
      if self:IsPossessed() then
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
      else
        self:SetPoseParameter("move_x", 1)
        self:SetPoseParameter("move_y", 0)
      end
      self:FrameAdvance()
    elseif self.AnimationType == DRGBASE_ANIMTYPE_BODYMOVEXY then
      self:BodyMoveXY()
    end
  end

  function ENT:PlaySequenceAndWait(seq, speed, callback)
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return end
    speed = speed or 1
    if callback == nil then callback = function() end end
    local synced = self:EnableSyncedAnimations()
    self:EnableSyncedAnimations(false)
    local len = self:SetSequence(seq)
    self:ResetSequenceInfo()
    self:SetCycle(0)
    self:SetPlaybackRate(speed)
    local delay = CurTime() + len/speed
    while CurTime() < delay and not self:IsDying() do
      if callback() then break end
      coroutine.yield()
    end
    self:EnableSyncedAnimations(synced)
    return len/speed
  end
  function ENT:PlayAnimationAndWait(anim, speed, callback)
    if isnumber(anim) then
      anim = self:SelectWeightedSequenceSeeded(anim, math.random(0, 255))
    end
    return self:PlaySequenceAndWait(anim, speed, callback)
  end

  function ENT:PlaySequenceAndMove(seq, speed, callback)
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return end
    local cycle = 0
    if callback == nil then callback = function() end end
    local res = self:PlaySequenceAndWait(seq, speed, function()
      local success, vec, angles = self:GetSequenceMovement(seq, cycle, self:GetCycle())
      cycle = self:GetCycle()
      if success then
        self:SetVelocity(Vector(0, 0, 10))
        self:SetPos(self:GetPos() + vec)
        self:SetAngles(self:GetAngles() + angles)
      end
      return callback()
    end)
    return res
  end
  function ENT:PlayAnimationAndMove(anim, speed, callback)
    if isnumber(anim) then
      anim = self:SelectWeightedSequenceSeeded(anim, math.random(0, 255))
    end
    return self:PlaySequenceAndMove(anim, speed, callback)
  end

  function ENT:PlayGesture(seq)
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return false end
    if self._DrGBaseCurrentGestures[seq] ~= nil and CurTime() <= self._DrGBaseCurrentGestures[seq] then return end
    self._DrGBaseCurrentGestures[seq] = CurTime() + self:SequenceDuration(seq)
    self:AddGestureSequence(seq)
    return self:SequenceDuration(seq)
  end
  function ENT:PlayAnimation(anim)
    if isnumber(anim) then
      anim = self:SelectWeightedSequenceSeeded(anim, math.random(0, 255))
    end
    return self:PlayGesture(anim)
  end

  function ENT:AddSequenceCallback(seq, cycles, callback)
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return end
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

  function ENT:GetHeadYaw()
    return self:GetPoseParameter(self.HeadYaw)
  end
  function ENT:GetHeadPitch()
    return self:GetPoseParameter(self.HeadPitch)
  end
  function ENT:SetHeadYaw(yaw)
    self:SetPoseParameter(self.HeadYaw, yaw)
  end
  function ENT:SetHeadPitch(pitch)
    self:SetPoseParameter(self.HeadPitch, pitch)
  end

  function ENT:GetAimYaw()
    return self:GetPoseParameter(self.AimYaw)
  end
  function ENT:GetAimPitch()
    return self:GetPoseParameter(self.AimPitch)
  end
  function ENT:SetAimYaw(yaw)
    self:SetPoseParameter(self.AimYaw, yaw)
  end
  function ENT:SetAimPitch(pitch)
    self:SetPoseParameter(self.AimPitch, pitch)
  end

  function ENT:LookAt(pos)
    if not isvector(pos) and not isentity(pos) then
      self:SetHeadYaw(0)
      self:SetHeadPitch(0)
    else
      if isentity(pos) then pos = pos:WorldSpaceCenter() end
      local tr = util.TraceLine({
        start = self:EyePos(),
        endpos = pos,
        filter = {self, self:GetActiveWeapon()}
      })
      local angle = tr.Normal:Angle()
      self:SetHeadYaw(math.AngleDifference(angle.y, self:GetAngles().y))
      self:SetHeadPitch(math.AngleDifference(angle.p, self:GetAngles().p))
    end
  end

  function ENT:AimAt(pos)
    if not isvector(pos) and not isentity(pos) then
      self:SetAimYaw(0)
      self:SetAimPitch(0)
    else
      if isentity(pos) then pos = pos:WorldSpaceCenter() end
      local tr = util.TraceLine({
        start = self:EyePos(),
        endpos = pos,
        filter = {self, self:GetActiveWeapon()}
      })
      local angle = tr.Normal:Angle()
      self:SetAimYaw(math.AngleDifference(angle.y, self:GetAngles().y))
      self:SetAimPitch(math.AngleDifference(angle.p, self:GetAngles().p))
    end
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
      seq, rate = self:SyncAnimation(self:SpeedCached(true))
    else
      seq = self:GetSequence()
      rate = self:GetPlaybackRate()
    end
    if isnumber(seq) then seq = self:SelectWeightedSequenceSeeded(seq, self:GetDrGVar("DrGBaseAnimationSeed")) end
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
    if seq ~= nil and seq ~= -1 and (seq ~= self:GetSequence() or self:GetCycle() == 1) then
      self:ResetSequence(seq)
      self:SetDrGVar("DrGBaseAnimationSeed", math.random(0, 255))
    end
  end

  function ENT:SyncAnimation(speed)
    if self:IsClimbing() then return self.ClimbAnimation, self.ClimbAnimRate
    elseif not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
    elseif speed > self.WalkSpeed*1.1 then return self.RunAnimation, self.RunAnimRate
    elseif speed > 0 then return self.WalkAnimation, self.WalkAnimRate
    else return self.IdleAnimation, self.IdleAnimRate end
  end

else



end
