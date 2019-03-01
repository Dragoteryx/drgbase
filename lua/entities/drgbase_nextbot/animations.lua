
-- Print --

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

-- Callbacks --

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

-- Helpers --

function ENT:SelectRandomSequence(anim)
  return self:SelectWeightedSequenceSeeded(anim, math.random(0, 255))
end

if SERVER then

  -- Debug --

  function ENT:HandleAnimEvent(event, time, cycle, type, options)

  end

  -- Play animations --

  function ENT:PlaySequenceAndWait(seq, rate, callback)
    if seq == nil then return end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return end
    if callback == nil then callback = function() end end
    rate = rate or 1
    local synced = self:EnableUpdateAnimation()
    self:EnableUpdateAnimation(false)
    local len = self:SetSequence(seq)
    self:ResetSequenceInfo()
    self:SetCycle(0)
    self:SetPlaybackRate(rate)
    local delay = CurTime() + len/rate
    while CurTime() < delay and not self:IsDying() do
      if callback(self:GetCycle()) then break end
      coroutine.yield()
    end
    self:EnableUpdateAnimation(synced)
    return len/rate
  end
  function ENT:PlayAnimationAndWait(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequenceAndWait(anim, rate, callback)
  end

  function ENT:PlaySequenceAndMove(seq, rate, callback)
    if seq == nil then return end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return end
    if callback == nil then callback = function() end end
    local previousCycle = 0
    return self:PlaySequenceAndWait(seq, rate, function(cycle)
      local success, vec, angles = self:GetSequenceMovement(seq, previousCycle, cycle)
      if success then
        vec:Rotate(self:GetAngles() + angles)
        local data = {
          endpos = self:GetPos() + vec,
          filter = {self, self:GetWeapon()}
        }
        local tr1 = self:TraceHull(data)
        if tr1.Hit then
          local tr2 = self:TraceHull(data, true)
          if not tr2.Hit then
            data.start = tr2.HitPos
            data.endpos = tr2.HitPos + Vector(0, 0, -self.loco:GetStepHeight()-1)
            local tr3 = self:TraceHull(data)
            self:SetPos(self:GetPos() + vec + Vector(0, 0, tr3.HitPos.z - self:GetPos().z))
          end
        else self:SetPos(self:GetPos() + vec) end
      end
      previousCycle = cycle
      return callback(cycle)
    end)
  end
  function ENT:PlayAnimationAndMove(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequenceAndMove(anim, rate, callback, absolute)
  end

  function ENT:PlaySequenceAndMoveAbsolute(anim, rate, callback)
    if seq == nil then return end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if seq == -1 then return end
    if callback == nil then callback = function() end end
    local startpos = self:GetPos()
    local res = self:PlaySequenceAndWait(seq, rate, function(cycle)
      local success, vec, angles = self:GetSequenceMovement(seq, 0, cycle)
      if success then
        vec:Rotate(self:GetAngles() + angles)
        self:SetPos(startpos + vec)
      end
      return callback(cycle)
    end)
    self:SetVelocity(Vector(0, 0, 0))
    return res
  end
  function ENT:PlayAnimationAndMoveAbsolute(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequenceAndMoveAbsolute(anim, rate, callback)
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
    coroutine.DrG_Create(function()
      local first = true
      while IsValid(self) do
        local cycle = self:GetLayerCycle(layerID)
        if not first and cycle == 0 then break end
        callback(cycle, layerID)
        first = false
        coroutine.yield()
      end
    end)
    return duration
  end
  function ENT:PlayAnimation(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequence(anim, rate, callback)
  end

  -- Look/aim --

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
  function ENT:LookAt(pos)
    if not isvector(pos) and not isentity(pos) then
      self:SetHeadYaw(0)
      self:SetHeadPitch(0)
    else
      if isentity(pos) then pos = pos:WorldSpaceCenter() end
      local angle = (pos - self:EyePos()):Angle()
      self:SetHeadYaw(math.AngleDifference(angle.y, self:GetAngles().y))
      self:SetHeadPitch(math.AngleDifference(angle.p, self:GetAngles().p))
    end
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
  function ENT:AimAt(pos)
    if not isvector(pos) and not isentity(pos) then
      self:SetAimYaw(0)
      self:SetAimPitch(0)
    else
      if isentity(pos) then pos = pos:WorldSpaceCenter() end
      local angle = (pos - self:EyePos()):Angle()
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

  function ENT:_HandleAnimations()
    local current = self:GetSequence()
    -- angles
    local angles = self:GetAngles()
    angles.r = 0
    if self:IsFlying() and self.FlightMatchPitch then
      local velocity = self:GetVelocity()
      if velocity.z == DRGBASE_FLIGHT_HOVER then angles.p = 0
      else angles.p = velocity:Angle().p end
    else angles.p = 0 end
    self:SetAngles(angles)
    -- sequence callbacks
    local callbacks = self._DrGBaseSequenceCallbacks[current]
    if callbacks ~= nil then
      for i, todo in ipairs(callbacks) do
        if self._DrGBaseLastAnimCycle < todo.cycle and self:GetCycle() >= todo.cycle then
          todo.callback(todo.cycle, self:GetCycle())
        end
      end
    end
    -- animation direction
    if self.AnimMatchDirection then
      local currseq = self:GetSequenceName(current)
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
    -- if update animation
    if self:EnableUpdateAnimation() then
      -- fetch seq/rate
      local seq, rate = self:UpdateAnimation()
      --[[if istable(seq) and #seq > 0 then
        seq = seq[math.random(#seq)]
      else seq = nil end]]
      if seq == nil then seq = current
      elseif isnumber(seq) then
        seq = self:SelectWeightedSequenceSeeded(seq, self._DrGBaseAnimationSeed)
      elseif isstring(seq) then seq = self:LookupSequence(seq) end
      -- change animation
      if seq ~= -1 and (seq ~= current or self:GetCycle() == 1) then
        self:ResetSequence(seq)
        self._DrGBaseAnimationSeed = math.random(0, 255)
      end
      -- animation speed
      if CurTime() > self._DrGBaseHandleAnimationDelay then
        self._DrGBaseHandleAnimationDelay = CurTime() + 0.1
        if self.AnimMatchSpeed and self:IsOnGround() and not self:IsClimbing() then
          local velocity = self:GetVelocity()
          velocity.z = 0
          if velocity:IsZero() then self:SetPlaybackRate(rate or 1)
          else
            local speed = velocity:Length()
            local seqspeed = self:GetSequenceGroundSpeed(seq)
            if seqspeed == 0 then self:SetPlaybackRate(rate or 1)
            else self:SetPlaybackRate(speed/seqspeed) end
          end
        else self:SetPlaybackRate(rate or 1) end
      end
    elseif self:GetCycle() == 1 then
      self:ResetSequence(current)
    end
    self._DrGBaseLastAnimCycle = self:GetCycle()
  end
  function ENT:ShouldReverseMoveX() end
  function ENT:ShouldReverseMoveY() end

else

  function ENT:FireAnimationEvent(pos, ang, event, name)

  end

end
