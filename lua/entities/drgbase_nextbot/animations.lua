
-- Getters/setters --

-- Functions --

function ENT:SelectRandomSequence(anim)
  return self:SelectWeightedSequenceSeeded(anim, math.random(0, 255))
end

function ENT:DefineSequenceCallback(seq, cycles, callback)
  if istable(seq) then
    for i, se in ipairs(seq) do
      self:DefineSequenceCallback(se, cycles, callback)
    end
  else
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if not isnumber(seq) then return end
    if isnumber(cycles) then cycles = {cycles} end
    if not istable(cycles) then return end
    self._DrGBaseSequenceCallbacks[seq] = {
      cycles = cycles, callback = callback
    }
  end
end
function ENT:RemoveSequenceCallback(seq)
  if istable(seq) then
    for i, se in ipairs(seq) do
      self:DefineSequenceCallback(se, cycles, callback)
    end
  else
    if isstring(seq) then seq = self:LookupSequence(seq) end
    self._DrGBaseSequenceCallbacks[seq] = nil
  end
end

-- Hooks --

-- Handlers --

function ENT:_InitAnimations()
  if SERVER then
    self._DrGBaseUpdateAnimation = true
    self._DrGBaseAnimSeed = math.random(0, 255)
    self._DrGBaseCurrentGestures = {}
    self:LoopTimer(0.1, function(self)
      if not self:IsUpdatingAnimation() then return true end
      local seq, rate = self:UpdateAnimation()
      if isnumber(seq) then
        seq = self:SelectWeightedSequenceSeeded(seq, self._DrGBaseAnimSeed)
      elseif isstring(seq) then seq = self:LookupSequence(seq) end
      if isnumber(seq) and seq ~= -1 then
        local current = self:GetSequence()
        if seq ~= current or self:GetCycle() == 1 then
          self:ResetSequence(seq)
          self._DrGBaseAnimSeed = math.random(0, 255)
        end
      end
      if not self.AnimMatchSpeed or not self:IsOnGround() or self:IsClimbing() then self:SetPlaybackRate(rate or 1) end
    end)
  end
  self._DrGBaseLastAnimCycle = 0
  self._DrGBaseSequenceCallbacks = {}
end

function ENT:_HandleAnimations()
  local current = self:GetSequence()
  local action = self._DrGBaseSequenceCallbacks[current]
  if action ~= nil then
    for i, cycle in ipairs(action.cycles) do
      if self._DrGBaseLastAnimCycle < cycle and self:GetCycle() >= cycle then
        action.callback(self, cycle, self:GetCycle())
        break
      end
    end
  end
  self._DrGBaseLastAnimCycle = self:GetCycle()
end

if SERVER then

  -- Getters/setters --

  function ENT:IsPlayingAnimation()
    return self._DrGBasePlayingAnimation or false
  end

  function ENT:IsUpdatingAnimation()
    return self._DrGBaseUpdateAnimation or false
  end
  function ENT:SetUpdateAnimation(bool)
    if bool then self._DrGBaseUpdateAnimation = true
    else self._DrGBaseUpdateAnimation = false end
  end

  -- Functions --

  function ENT:PlaySequenceAndWait(seq, rate, callback)
    if self:IsPlayingAnimation() then return end
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    if callback == nil then callback = function() end end
    rate = rate or 1
    local upd = self:IsUpdatingAnimation()
    self:SetUpdateAnimation(false)
    local len = self:SetSequence(seq)
    self:ResetSequenceInfo()
    self:SetCycle(0)
    self:SetPlaybackRate(rate)
    local delay = CurTime() + len/rate
    self._DrGBasePlayingAnimation = true
    while CurTime() < delay and not self:IsDying() do
      local cycle = self:GetCycle()
      if callback(cycle) then break end
      coroutine.yield()
    end
    self._DrGBasePlayingAnimation = false
    self:SetUpdateAnimation(upd)
    return len/rate
  end
  function ENT:PlayAnimationAndWait(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequenceAndWait(anim, rate, callback)
  end

  function ENT:PlaySequenceAndMove(seq, rate, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    if callback == nil then callback = function() end end
    local previousCycle = 0
    return self:PlaySequenceAndWait(seq, rate, function(cycle)
      local success, vec, angles = self:GetSequenceMovement(seq, previousCycle, cycle)
      if success then
        vec:Rotate(self:GetAngles() + angles)
        if not self:TraceHull(vec, true).Hit then
          self:SetPos(self:GetPos() + vec)
          self:SetAngles(self:LocalToWorldAngles(angles))
        end
      end
      previousCycle = cycle
      return callback(cycle)
    end)
  end
  function ENT:PlayAnimationAndMove(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequenceAndMove(anim, rate, callback)
  end

  function ENT:PlaySequenceAndMoveAbsolute(seq, rate, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    if callback == nil then callback = function() end end
    local startpos = self:GetPos()
    local lastpos = self:GetPos()
    local res = self:PlaySequenceAndWait(seq, rate, function(cycle)
      local success, vec, angles = self:GetSequenceMovement(seq, 0, cycle)
      if success then
        vec:Rotate(self:GetAngles() + angles)
        lastpos = startpos + vec
        self:SetPos(lastpos)
        self:SetAngles(self:LocalToWorldAngles(angles))
      end
      return callback(cycle)
    end)
    self:SetPos(lastpos)
    self:SetVelocity(Vector(0, 0, 0))
    return res
  end
  function ENT:PlayAnimationAndMoveAbsolute(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequenceAndMoveAbsolute(anim, rate, callback)
  end

  function ENT:PlaySequence(seq, rate, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
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
        first = false
        callback(cycle, layerID)
        coroutine.yield()
      end
    end)
    return duration
  end
  function ENT:PlayAnimation(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequence(anim, rate, callback)
  end

  function ENT:DirectPoseParametersAt(pos, pitch, yaw, center)
    if isentity(pos) then
      return self:DirectPoseParametersAt(pos:WorldSpaceCenter(), pitch, yaw)
    elseif isvector(pos) then
      center = center or self:WorldSpaceCenter()
      local angle = (pos - center):Angle()
      self:SetPoseParameter(pitch, math.AngleDifference(angle.p, self:GetAngles().p))
      self:SetPoseParameter(yaw, math.AngleDifference(angle.y, self:GetAngles().y))
    else
      self:SetPoseParameter(pitch, 0)
      self:SetPoseParameter(yaw, 0)
    end
  end

  -- Hooks --

  function ENT:BodyUpdate()
    self:BodyMoveXY({
      rate = self.AnimMatchSpeed,
      direction = self.AnimMatchDirection
    })
  end

  function ENT:UpdateAnimation()
    if self:IsClimbingUp() then return self.ClimbUpAnimation, self.ClimbAnimRate
    elseif self:IsClimbingDown() then return self.ClimbDownAnimation, self.ClimbAnimRate
    elseif not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
    elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate
    elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
    else return self.IdleAnimation, self.IdleAnimRate end
  end

  -- Handlers --

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
