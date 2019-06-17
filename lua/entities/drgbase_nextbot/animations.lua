
-- Getters/setters --

-- Functions --

function ENT:SelectRandomSequence(anim)
  return self:SelectWeightedSequenceSeeded(anim, math.random(0, 255))
end

function ENT:SequenceEvent(seq, cycles, callback)
  if istable(seq) then
    for i, se in ipairs(seq) do
      self:SequenceEvent(se, cycles, callback)
    end
  else
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    self._DrGBaseSequenceEvents[seq] = self._DrGBaseSequenceEvents[seq] or {}
    local event = self._DrGBaseSequenceEvents[seq]
    if isnumber(cycles) then cycles = {cycles} end
    for i, cycle in ipairs(cycles) do
      event[cycle] = event[cycle] or {}
      table.insert(event[cycle], callback)
    end
  end
end

-- Hooks --

function ENT:OnSequenceEvent() end

-- Handlers --

function ENT:_InitAnimations()
  if SERVER then
    self._DrGBaseUpdateAnimation = true
    self._DrGBaseCurrentGestures = {}
    self._DrGBaseAnimAttacks = {}
    self:LoopTimer(0.1, function(self)
      if not self:IsUpdatingAnimation() then return end
      local anim, rate = self:UpdateAnimation()
      local current = self:GetSequence()
      local validAnim = false
      if isnumber(anim) then
        local seq = self:SelectRandomSequence(anim)
        validAnim = seq ~= -1
        if validAnim and (self:GetCycle() == 1 or anim ~= self:GetSequenceActivity(current)) then
          self:ResetSequence(seq)
        end
      elseif isstring(anim) then
        local seq = self:LookupSequence(anim)
        validAnim = seq ~= -1
        if validAnim and (self:GetCycle() == 1 or seq ~= current) then
          self:ResetSequence(seq)
        end
      end
      if validAnim and not self.AnimMatchSpeed and not self._DrGBasePlayingAnimation then
        self:SetPlaybackRate(rate or 1)
      end
    end)
  end
  self._DrGBaseLastAnimCycle = 0
  self._DrGBaseSequenceEvents = {}
end

function ENT:_HandleAnimations()
  local current = self:GetSequence()
  local event = self._DrGBaseSequenceEvents[current]
  if event ~= nil then
    for cycle, callbacks in pairs(event) do
      local trCycle = cycle
      if trCycle == 0 then trCycle = 0.0000001 end
      if self._DrGBaseLastAnimCycle < trCycle and self:GetCycle() >= trCycle then
        if self:OnSequenceEvent(self:GetSequenceName(current), cycle, false) then break end
        for i, callback in ipairs(callbacks) do callback(self, cycle, false) end
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

  function ENT:IsPlayingSequence(seq)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return false end
    if seq == -1 then return false end
    if self._DrGBasePlayingAnimation == seq then return true end
    if self._DrGBaseCurrentGestures[seq] then return true end
    return false
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
    self._DrGBasePlayingAnimation = seq
    while CurTime() < delay and not self:IsDying() do
      local cycle = self:GetCycle()
      if callback(cycle) then break end
      self:YieldCoroutine(false)
    end
    self._DrGBasePlayingAnimation = nil
    self:SetUpdateAnimation(upd)
    return len/rate
  end
  function ENT:PlayActivityAndWait(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequenceAndWait(anim, rate, callback)
  end

  function ENT:PlaySequenceAndMove(seq, rate, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    if isnumber(options) then options = {options}
    elseif not istable(options) then options = {} end
    if callback == nil then callback = function() end end
    local previousCycle = 0
    return self:PlaySequenceAndWait(seq, options.rate or 1, function(cycle)
      local success, vec, angles = self:GetSequenceMovement(seq, previousCycle, cycle)
      if success then
        if isvector(options.multiply) then
          vec = Vector(vec.x*options.multiply.x, vec.y*options.multiply.y, vec.z*options.multiply.z)
        end
        vec:Rotate(self:GetAngles() + angles)
        if not self:TraceHull(vec, true).Hit then
          self:SetPos(self:GetPos() + vec*self:GetModelScale())
          self:SetAngles(self:LocalToWorldAngles(angles))
        end
      end
      previousCycle = cycle
      return callback(cycle)
    end)
  end
  function ENT:PlayActivityAndMove(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequenceAndMove(anim, rate, callback)
  end

  function ENT:PlaySequenceAndMoveAbsolute(seq, options, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    if isnumber(options) then options = {options}
    elseif not istable(options) then options = {} end
    if callback == nil then callback = function() end end
    local startpos = self:GetPos()
    local lastpos = self:GetPos()
    local res = self:PlaySequenceAndWait(seq, options.rate or 1, function(cycle)
      local success, vec, angles = self:GetSequenceMovement(seq, 0, cycle)
      if success then
        if isvector(options.multiply) then
          vec = Vector(vec.x*options.multiply.x, vec.y*options.multiply.y, vec.z*options.multiply.z)
        end
        vec:Rotate(self:GetAngles() + angles)
        lastpos = startpos + vec*self:GetModelScale()
        self:SetPos(lastpos)
        self:SetAngles(self:LocalToWorldAngles(angles))
      else self:SetPos(lastpos) end
      return callback(cycle)
    end)
    self:SetPos(lastpos)
    self:SetVelocity(Vector(0, 0, 0))
    return res
  end
  function ENT:PlayActivityAndMoveAbsolute(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequenceAndMoveAbsolute(anim, rate, callback)
  end

  function ENT:PlaySequence(seq, rate, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    if callback == nil then callback = function() end end
    rate = rate or 1
    if self._DrGBaseCurrentGestures[seq] then return end
    self._DrGBaseCurrentGestures[seq] = true
    local duration = self:SequenceDuration(seq)/rate
    local layerID = self:AddGestureSequence(seq)
    self:SetLayerPlaybackRate(layerID, rate)
    coroutine.DrG_Create(function()
      local first = true
      local lastCycle = 0
      while IsValid(self) do
        local cycle = self:GetLayerCycle(layerID)
        if lastCycle > 0 and cycle == 0 then break end
        local event = self._DrGBaseSequenceEvents[seq]
        if event ~= nil then
          for eventCycle, callbacks in pairs(event) do
            local trCycle = eventCycle
            if trCycle == 0 then trCycle = 0.0000001 end
            if lastCycle < trCycle and cycle >= trCycle then
              if self:OnSequenceEvent(self:GetSequenceName(seq), eventCycle, true) then break end
              for i, callback in ipairs(callbacks) do callback(self, eventCycle, true) end
              break
            end
          end
        end
        lastCycle = cycle
        callback(cycle, layerID)
        coroutine.yield()
      end
      self._DrGBaseCurrentGestures[seq] = false
    end)
    return duration
  end
  function ENT:PlayActivity(anim, rate, callback)
    if isnumber(anim) then anim = self:SelectRandomSequence(anim) end
    return self:PlaySequence(anim, rate, callback)
  end

  function ENT:PlayClimbSequence(seq, animheight, realheight, callback)
    return self:PlaySequenceAndMoveAbsolute(seq, {
      multiply = Vector(1, 1, realheight/animheight/self:GetModelScale())
    }, callback)
  end
  function ENT:PlayAppropriateClimbSequence(height, climbs, callback)
    height = height/self:GetModelScale()
    for i, climb in ipairs(climbs) do
      local prior = climbs[i-1]
      if height < climb.height then
        return self:PlayClimbSequence(climb.seq, climb.height, height*self:GetModelScale(), callback)
      elseif prior ~= nil and math.Clamp(height, prior.height, climb.height) == height then
        local avg = (prior.height + climb.height)/2
        if height < avg then
          return self:PlayClimbSequence(prior.seq, prior.height, height*self:GetModelScale(), callback)
        else return self:PlayClimbSequence(climb.seq, climb.height, height*self:GetModelScale(), callback) end
      elseif climbs[i+1] == nil then
        return self:PlayClimbSequence(climb.seq, climb.height, height*self:GetModelScale(), callback)
      end
    end
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
