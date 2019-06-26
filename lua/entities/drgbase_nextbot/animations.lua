
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

function ENT:DirectPoseParametersAt(pos, pitch, yaw, center)
    if isentity(pos) then pos = pos:WorldSpaceCenter() end
    if isvector(pos) then
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

function ENT:OnSequenceEvent() end

-- Handlers --

function ENT:_InitAnimations()
  if SERVER then
    self._DrGBaseCurrentGestures = {}
    self._DrGBaseAnimAttacks = {}
    self:LoopTimer(0.1, self.UpdateAnimation)
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
    return isnumber(self._DrGBasePlayingAnimation) or false
  end

  function ENT:IsPlayingSequence(seq)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return false end
    if seq == -1 then return false end
    if self._DrGBasePlayingAnimation == seq then return true end
    if self._DrGBaseCurrentGestures[seq] then return true end
    return false
  end

  function ENT:IsPlayingActivity(act)
    if not isnumber(self._DrGBasePlayingAnimation) then return false end
    return self:GetSequenceActivity(self._DrGBasePlayingAnimation) == act
  end

  -- Functions --

  function ENT:PlaySequenceAndWait(seq, rate, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    rate = isnumber(rate) and rate or 1
    if callback == nil then callback = function() end end
    self._DrGBasePlayingAnimation = seq
    local len = self:SetSequence(seq)
    self:ResetSequenceInfo()
    self:SetCycle(0)
    self:SetPlaybackRate(rate)
    local delay = CurTime() + len/rate
    while CurTime() < delay do
      if seq == self._DrGBasePlayingAnimation then
        local cycle = self:GetCycle()
        if callback(self, cycle) then break end
        self:YieldCoroutine(false)
      else break end
    end
    self._DrGBasePlayingAnimation = nil
    self:Timer(0, self.UpdateAnimation)
    return len/rate
  end
  function ENT:PlayActivityAndWait(act, rate, callback)
    local seq = self:SelectRandomSequence(act)
    return self:PlaySequenceAndWait(seq, rate, callback)
  end
  function ENT:PlayAnimationAndWait(anim, rate, callback)
    if isstring(anim) then self:PlaySequenceAndWait(anim, rate, callback)
    elseif isnumber(anim) then self:PlayActivityAndWait(anim, rate, callback) end
  end

  function ENT:PlaySequenceAndMove(seq, options, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    if isnumber(options) then options = {rate = options}
    elseif not istable(options) then options = {} end
    if callback == nil then callback = function() end end
    local previousCycle = 0
    return self:PlaySequenceAndWait(seq, options.rate or 1, function(self, cycle)
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
      return callback(self, cycle)
    end)
  end
  function ENT:PlayActivityAndMove(act, options, callback)
    local seq = self:SelectRandomSequence(act)
    return self:PlaySequenceAndMove(seq, options, callback)
  end
  function ENT:PlayAnimationAndMove(anim, rate, callback)
    if isstring(anim) then self:PlaySequenceAndMove(anim, rate, callback)
    elseif isnumber(anim) then self:PlayActivityAndMove(anim, rate, callback) end
  end

  function ENT:PlaySequenceAndMoveAbsolute(seq, options, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    if isnumber(options) then options = {rate = options}
    elseif not istable(options) then options = {} end
    if callback == nil then callback = function() end end
    local startpos = self:GetPos()
    local lastpos = self:GetPos()
    local res = self:PlaySequenceAndWait(seq, options.rate or 1, function(self, cycle)
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
      return callback(self, cycle)
    end)
    self:SetPos(lastpos)
    self:SetVelocity(Vector(0, 0, 0))
    return res
  end
  function ENT:PlayActivityAndMoveAbsolute(act, options, callback)
    local seq = self:SelectRandomSequence(act)
    return self:PlaySequenceAndMoveAbsolute(seq, options, callback)
  end
  function ENT:PlayAnimationAndMoveAbsolute(anim, rate, callback)
    if isstring(anim) then self:PlaySequenceAndMoveAbsolute(anim, rate, callback)
    elseif isnumber(anim) then self:PlayActivityAndMoveAbsolute(anim, rate, callback) end
  end

  function ENT:PlaySequence(seq, rate, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    rate = isnumber(rate) and rate or 1
    if callback == nil then callback = function() end end
    if self._DrGBaseCurrentGestures[seq] then return end
    local duration = self:SequenceDuration(seq)/rate
    local layerID = self:AddGestureSequence(seq)
    if layerID == -1 then return 0 end
    self._DrGBaseCurrentGestures[seq] = true
    self:SetLayerPlaybackRate(layerID, rate)
    coroutine.DrG_Create(function()
      local first = true
      local lastCycle = 0
      while IsValid(self) do
        local cycle = self:GetLayerCycle(layerID)
        if cycle < lastCycle then break end
        --if cycle == lastCycle and cycle == 1 then break end
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
        if not callback(self, cycle, layerID) then
          lastCycle = cycle
          coroutine.yield()
        else break end
      end
      self._DrGBaseCurrentGestures[seq] = false
    end)
    return duration
  end
  function ENT:PlayActivity(act, rate, callback)
    local seq = self:SelectRandomSequence(act)
    return self:PlaySequence(seq, options, callback)
  end
  function ENT:PlayAnimation(anim, rate, callback)
    if isstring(anim) then self:PlaySequence(anim, rate, callback)
    elseif isnumber(anim) then self:PlayActivity(anim, rate, callback) end
  end

  local function PlayClosestClimbSequence(self, seqs, height, rate, callback)
    local climbs = {}
    for i, seq in ipairs(seqs) do
      if isstring(seq) then seq = self:LookupSequence(seq)
      elseif not isnumber(seq) then continue end
      if seq == -1 then continue end
      local success, vec, angles = self:GetSequenceMovement(seq, 0, 1)
      if not success then continue end
      table.insert(climbs, {seq = seq, height = vec.z})
    end
    table.sort(climbs, function(climb1, climb2)
      return climb1.height < climb2.height
    end)
    height = height/self:GetModelScale()
    for i, climb in ipairs(climbs) do
      local prior = climbs[i-1]
      if height < climb.height then
        return self:PlayClimbSequence(climb.seq, height*self:GetModelScale(), rate, callback)
      elseif prior ~= nil and math.Clamp(height, prior.height, climb.height) == height then
        local avg = (prior.height + climb.height)/2
        if height < avg then
          return self:PlayClimbSequence(prior.seq, height*self:GetModelScale(), rate, callback)
        else return self:PlayClimbSequence(climb.seq, height*self:GetModelScale(), rate, callback) end
      elseif climbs[i+1] == nil then
        return self:PlayClimbSequence(climb.seq, height*self:GetModelScale(), rate, callback)
      end
    end
  end

  function ENT:PlayClimbSequence(seq, height, rate, callback)
    if not istable(seq) then
      if isstring(seq) then seq = self:LookupSequence(seq)
      elseif not isnumber(seq) then return end
      if seq == -1 then return end
      local success, vec, angles = self:GetSequenceMovement(seq, 0, 1)
      if not success then return end
      return self:PlaySequenceAndMoveAbsolute(seq, {
        rate = rate,
        multiply = Vector(1, 1, height/vec.z/self:GetModelScale())
      }, function(self, cycle)
        if not self:TraceHull(self:GetForward()*self.LedgeDetectionDistance*2).Hit then return true end
        if isfunction(callback) then return callback(self, cycle) end
      end)
    else return PlayClosestClimbSequence(self, seq, height, rate, callback) end
  end
  function ENT:PlayClimbActivity(act, height, rate, callback)
    local seq = self:SelectRandomSequence(act)
    return self:PlayClimbSequence(seq, options, callback)
  end
  function ENT:PlayClimbAnimation(anim, height, rate, callback)
    if isstring(anim) then self:PlayClimbSequence(anim, height, rate, callback)
    elseif isnumber(anim) then self:PlayClimbActivity(anim, height, rate, callback) end
  end

  -- Update --

  function ENT:UpdateAnimation()
    if self:IsPlayingAnimation() then return end
    local anim, rate = self:OnUpdateAnimation()
    local current = self:GetSequence()
    local validAnim = false
    if isnumber(anim) then
      local seq = self:SelectRandomSequence(anim)
      validAnim = seq ~= -1
      local activity = self:GetSequenceActivity(current)
      if validAnim and (self:GetCycle() == 1 or anim ~= activity) then
        self:ResetSequence(seq)
      end
    elseif isstring(anim) then
      local seq = self:LookupSequence(anim)
      validAnim = seq ~= -1
      if validAnim and (self:GetCycle() == 1 or seq ~= current) then
        self:ResetSequence(seq)
      end
    end
    if validAnim and not self.AnimMatchSpeed then
      self:SetPlaybackRate(rate or 1)
    end
  end
  function ENT:OnUpdateAnimation()
    if self:IsDown() then return end
    if self:IsClimbingUp() then return self.ClimbUpAnimation, self.ClimbAnimRate
    elseif self:IsClimbingDown() then return self.ClimbDownAnimation, self.ClimbAnimRate
    elseif not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
    elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate
    elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
    else return self.IdleAnimation, self.IdleAnimRate end
  end

  -- Hooks --

  function ENT:BodyUpdate()
    self:BodyMoveXY({
      rate = self.AnimMatchSpeed,
      direction = self.AnimMatchDirection
    })
  end

  -- Handlers --

  -- Meta --

  local nextbotMETA = FindMetaTable("NextBot")

  local old_BodyMoveXY = nextbotMETA.BodyMoveXY
  function nextbotMETA:BodyMoveXY(options)
    if self.IsDrGNextbot then
      options = options or {}
      if options.rate == nil then options.rate = true end
      if options.direction == nil then options.direction = true end
      if options.frameadvance == nil then options.frameadvance = true end
      if options.frameadvance and
      (self:IsPlayingAnimation() or self:IsClimbing() or not self:IsOnGround() or not self:IsMoving()) then
        return self:FrameAdvance()
      end
      if not options.rate or not options.direction or not options.frameadvance or self.UseWalkframes then
        if options.rate and not self:IsPlayingAnimation() and
        not self:IsClimbing() and self:IsOnGround() and self:IsMoving() then
          local velocity = self:GetVelocity()
          velocity.z = 0
          if not velocity:IsZero() then
            local speed = velocity:Length()
            local seqspeed = self:GetSequenceGroundSpeed(self:GetSequence())
            if seqspeed ~= 0 then self:SetPlaybackRate(speed/seqspeed) end
          end
        end
        if self.UseWalkframes then
          self:SetPoseParameter("move_x", 1)
          self:SetPoseParameter("move_y", 0)
        elseif options.direction then
          local velocity = self.loco:GetGroundMotionVector()
          local moveX = (-(velocity:DrG_Degrees(self:GetForward())-90))/45
          if moveX > 1 then moveX = 1
          elseif moveX < -1 then moveX = -1 end
          if moveX == moveX then self:SetPoseParameter("move_x", moveX) end
          local moveY = (-(velocity:DrG_Degrees(self:GetRight())-90))/45
          if moveY > 1 then moveY = 1
          elseif moveY < -1 then moveY = -1 end
          if moveY == moveY then self:SetPoseParameter("move_y", moveY) end
        end
        if options.frameadvance then
          self:FrameAdvance()
        end
      else return old_BodyMoveXY(self) end
    else return old_BodyMoveXY(self) end
  end

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
