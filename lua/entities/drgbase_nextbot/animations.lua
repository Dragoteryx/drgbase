
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

function ENT:SelectRandomSequence(anim)
  return self:SelectWeightedSequenceSeeded(anim, math.random(0, 255))
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

if SERVER then

  function ENT:PlaySequenceAndWait(seq, speed, callback)
    if seq == nil then return end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return end
    speed = speed or 1
    if callback == nil then callback = function() end end
    self._DrGBaseDisableBMXY = true
    local synced = self:EnableUpdateAnimation()
    self:EnableUpdateAnimation(false)
    local len = self:SetSequence(seq)
    self:ResetSequenceInfo()
    self:SetCycle(0)
    self:SetPlaybackRate(speed)
    local delay = CurTime() + len/speed
    while CurTime() < delay and not self:IsDying() do
      if callback() then break end
      if self:IsFlying() then self:FlightHover() end
      coroutine.yield()
    end
    self._DrGBaseDisableBMXY = false
    self:EnableUpdateAnimation(synced)
    return len/speed
  end
  function ENT:PlayAnimationAndWait(anim, speed, callback)
    if isnumber(anim) then
      anim = self:SelectRandomSequence(anim)
    end
    return self:PlaySequenceAndWait(anim, speed, callback)
  end

  function ENT:PlaySequenceAndMove(seq, speed, callback, collide)
    if seq == nil then return end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return end
    if callback == nil then callback = function() end end
    local cycle = 0
    local startpos = self:GetPos()
    local safepos = self:GetPos()
    local res = self:PlaySequenceAndWait(seq, speed, function()
      local success, vec, angles = self:GetSequenceMovement(seq, 0, self:GetCycle())
      if success then
        vec:Rotate(self:GetAngles() + angles)
        if collide then
          local bound1, bound2 = self:GetCollisionBounds()
          local maxs = bound1.z > bound2.z and bound1 or bound2
          local mins = bound1.z <= bound2.z and bound1 or bound2
          local tr = util.TraceHull({
            start = self:GetPos(),
            endpos = startpos + vec,
            maxs = maxs, mins = mins,
            filter = {self, self:GetWeapon()}
          })
          if not tr.HitWorld and not IsValid(tr.Entity) then safepos = startpos + vec end
          self:SetPos(safepos)
        else self:SetPos(startpos + vec) end
      end
      return callback()
    end)
    self:SetVelocity(Vector(0, 0, 0))
    return res
  end
  function ENT:PlayAnimationAndMove(anim, speed, callback, collide)
    if isnumber(anim) then
      anim = self:SelectRandomSequence(anim)
    end
    return self:PlaySequenceAndMove(anim, speed, callback, collide)
  end

  function ENT:PlaySequence(seq, rate, callback)
    if seq == nil then return end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return false end
    if callback == nil then callback = function() end end
    rate = rate or 1
    if self._DrGBaseCurrentGestures[seq] ~= nil and CurTime() <= self._DrGBaseCurrentGestures[seq] then return end
    local duration = self:SequenceDuration(seq)/rate
    self._DrGBaseCurrentGestures[seq] = CurTime() + duration
    local layerID = self:AddGestureSequence(seq)
    self:SetLayerPlaybackRate(layerID, rate)
    self:Timer(duration, callback)
    return duration
  end
  function ENT:PlayAnimation(anim, rate, callback)
    if isnumber(anim) then
      anim = self:SelectRandomSequence(anim)
    end
    return self:PlaySequence(anim, rate, callback)
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
      local angle = math.DrG_AngleVectors(self:EyePos(), pos)
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
      local angle = math.DrG_AngleVectors(self:EyePos(), pos)
      self:SetAimYaw(math.AngleDifference(angle.y, self:GetAngles().y))
      self:SetAimPitch(math.AngleDifference(angle.p, self:GetAngles().p))
    end
  end

  -- Handlers --

  function ENT:EnableUpdateAnimation(bool)
    if bool == nil then return self._DrGBaseSyncAnimations
    elseif bool then self._DrGBaseSyncAnimations = true
    else self._DrGBaseSyncAnimations = false end
  end

  function ENT:_HandleAnimations()
    local angles = self:GetAngles()
    angles.r = 0
    if self:IsFlying() and self.FlightMatchPitch then
      local velocity = self:GetVelocity()
      if velocity.z == DRGBASE_FLIGHT_HOVER then angles.p = 0
      else angles.p = velocity:Angle().p end
    else angles.p = 0 end
    self:SetAngles(angles)
    local seq, rate
    if self:EnableUpdateAnimation() then
      seq, rate = self:UpdateAnimation()
    else
      seq = self:GetSequence()
      rate = self:GetPlaybackRate()
    end
    if isnumber(seq) then seq = self:SelectWeightedSequenceSeeded(seq, self._DrGBaseAnimationSeed) end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    local callbacks = self._DrGBaseSequenceCallbacks[seq]
    if callbacks ~= nil then
      for i, todo in ipairs(callbacks) do
        if self._DrGBaseLastAnimCycle < todo.cycle and self:GetCycle() >= todo.cycle then
          todo.callback(todo.cycle, self:GetCycle())
        end
      end
    end
    if self:EnableUpdateAnimation() then
      if self.AnimMatchSpeed and self:IsOnGround() and not self:IsClimbing() then
        local velocity = self.loco:GetGroundMotionVector()
        if velocity:IsZero() then self:SetPlaybackRate(rate or 1)
        else
          local speed = self:Speed()
          local sequence = self:GetSequenceGroundSpeed(seq)
          if sequence == 0 then self:SetPlaybackRate(rate or 1)
          else self:SetPlaybackRate(speed/sequence) end
        end
      else self:SetPlaybackRate(rate or 1) end
    end
    if self.AnimMatchDirection then
      local currseq = self:GetSequenceName(self:GetSequence())
      local velocity = self.loco:GetGroundMotionVector()
      local moveX = (-(math.DrG_DegreeAngle(velocity, self:GetForward())-90))/45
      if moveX > 1 then moveX = 1
      elseif moveX < -1 then moveX = -1 end
      if self:ShouldReverseMoveX(currseq) then moveX = -moveX end
      if moveX == moveX then self:SetPoseParameter("move_x", moveX) end
      local moveY = (-(math.DrG_DegreeAngle(velocity, self:GetRight())-90))/45
      if moveY > 1 then moveY = 1
      elseif moveY < -1 then moveY = -1 end
      if self:ShouldReverseMoveY(currseq) then moveY = -moveY end
      if moveY == moveY then self:SetPoseParameter("move_y", moveY) end
    end
    if seq ~= nil and seq ~= -1 and (seq ~= self:GetSequence() or self:GetCycle() == 1) then
      self:ResetSequence(seq)
      self._DrGBaseAnimationSeed = math.random(0, 255)
    end
    self._DrGBaseLastAnimCycle = self:GetCycle()
  end
  function ENT:ShouldReverseMoveX() end
  function ENT:ShouldReverseMoveY() end

  function ENT:UpdateAnimation()
    if self:IsFlying() then
      if self:GetVelocity().z == DRGBASE_FLIGHT_HOVER then return self.FlightHoverAnimation, self.FlightHoverAnimRate
      else
        local pitch = -math.NormalizeAngle(self:GetVelocity():Angle().p)
        if pitch >= self.FlightUpPitchThreshold then return self.FlightUpAnimation, self.FlightUpAnimRate
        elseif pitch <= self.FlightDownPitchThreshold then return self.FlightDownAnimation, self.FlightDownAnimRate
        else return self.FlightAnimation, self.FlightAnimRate end
      end
    elseif self:IsClimbing() then return self.ClimbAnimation, self.ClimbAnimRate
    elseif not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
    elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate
    elseif self:IsSpeedMore(0, true) then return self.WalkAnimation, self.WalkAnimRate
    else return self.IdleAnimation, self.IdleAnimRate end
  end

else



end
