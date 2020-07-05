if SERVER then

  local function RandomSequence(self, act)
    return self:SelectWeightedSequenceSeeded(act, math.random(0, 255))
  end

  local function SequenceOrActivity(anim)
    if isnumber(anim) then return "activity"
    elseif isstring(anim) then
      if string.StartWith(string.upper(anim), "ACT_") then
        return "activity"
      else return "sequence" end
    else return "none" end
  end

  local function ResetSequence(self, seq)
    local len = self:SetSequence(seq)
    self:ResetSequenceInfo()
    self:SetCycle(0)
    return len
  end

  -- PSAW and friends --

  function ENT:PlaySequenceAndWait(sequence, options, fn)
    if isnumber(options) then return self:PlaySequenceAndWait(sequence, {rate = options}, fn) end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if not isnumber(seq) or seq == -1 then return false end
    if not istable(options) then options = {} end
    if not isnumber(options.rate) then options.rate = 1 end
    if not isbool(options.cancellable) then options.cancellable = false end
    if not isbool(options.transitions) then options.transitions = false end
    ResetSequence(self, seq)
    self:SetPlaybackRate(options.rate)
    self._DrGBaseTransitionToSequence = nil
    local previous = -1
    while true do
      if self._DrGBaseTransitionToSequence then
        if options.transitions then
          local tr = self._DrGBaseTransitionToSequence
          return self:PlaySequenceAndWait(tr.sequence, setmetatable(tr.options, options), fn)
        else self._DrGBaseTransitionToSequence = nil end
      end
      local cycle = self:GetCycle()
      if previous > cycle then return true end
      if previous == cycle and cycle == 1 then return true end
      if isfunction(fn) then
        local res = fn(self, cycle, previous, sequence)
        if res ~= nil then return res end
      end
      previous = cycle
      if self:YieldCoroutineNoUpdate(options.cancellable) then
        return false
      end
    end
  end
  function ENT:PlayActivityAndWait(act, ...)
    return self:PlaySequenceAndWait(RandomSequence(self, act), ...)
  end
  function ENT:PlayAnimationAndWait(anim, ...)
    local kind = SequenceOrActivity(anim)
    if kind == "sequence" then
      return self:PlaySequenceAndWait(anim, ...)
    elseif kind == "activity" then
      return self:PlayActivityAndWait(anim, ...)
    else return false end
  end

  function ENT:PlaySequenceAndMove(sequence, options, fn)
    if isnumber(options) then return self:PlaySequenceAndMove(sequence, {rate = options}, fn) end
    if not istable(options) then options = {} end
    if not isbool(options.gravity) then options.gravity = true end
    if not isbool(options.collide) then options.collide = true end
    if not isbool(options.stoponcollide) then options.stoponcollide = true end
    return self:PlaySequenceAndWait(sequence, options, function(self, cycle, previous, ...)

      if isfunction(fn) then return fn(self, cycle, previous, ...) end
    end)
  end
  function ENT:PlayActivityAndMove(act, ...)
    return self:PlaySequenceAndMove(RandomSequence(self, act), ...)
  end
  function ENT:PlayAnimationAndMove(anim, ...)
    local kind = SequenceOrActivity(anim)
    if kind == "sequence" then
      return self:PlaySequenceAndMove(anim, ...)
    elseif kind == "activity" then
      return self:PlayActivityAndMove(anim, ...)
    else return false end
  end

  function ENT:PlaySequenceAndMoveAbsolute(sequence, options, fn)
    if isnumber(options) then return self:PlaySequenceAndMoveAbsolute(sequence, {rate = options}, fn) end
    if not istable(options) then options = {} end
    options.gravity = false
    options.collide = false
    return self:PlaySequenceAndMove(sequence, options, fn)
  end
  function ENT:PlayActivityAndMoveAbsolute(act, ...)
    return self:PlaySequenceAndMoveAbsolute(RandomSequence(self, act), ...)
  end
  function ENT:PlayAnimationAndMoveAbsolute(anim, ...)
    local kind = SequenceOrActivity(anim)
    if kind == "sequence" then
      return self:PlaySequenceAndMoveAbsolute(anim, ...)
    elseif kind == "activity" then
      return self:PlayActivityAndMoveAbsolute(anim, ...)
    else return false end
  end

  function ENT:TransitionToSequence(sequence, options)
    if isnumber(options) then return self:TransitionToSequence(sequence, {rate = options}) end
    if not isnumber(options.rate) then options.rate = 1 end
    self._DrGBaseTransitionToSequence = {sequence = sequence, options = options}
  end
  function ENT:TransitionToActivity(act, ...)
    return self:TransitionToSequence(RandomSequence(self, act), ...)
  end
  function ENT:TransitionToAnimation(anim, ...)
    local kind = SequenceOrActivity(anim)
    if kind == "sequence" then
      return self:TransitionToSequence(anim, ...)
    elseif kind == "activity" then
      return self:TransitionToActivity(anim, ...)
    else return false end
  end

  -- Hooks --

  function ENT:BodyUpdate()
    self:BodyMoveXY()
  end

  function ENT:OnUpdateAnimation()
    --[[if self:IsDown() or self:IsDead() then return end
    if self:IsClimbingUp() then return self.ClimbUpAnimation, self.ClimbAnimRate
    elseif self:IsClimbingDown() then return self.ClimbDownAnimation, self.ClimbAnimRate
    elseif not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
    else]]if self:IsRunning() then return self.RunAnimation, self.RunAnimRate
    elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
    else return self.IdleAnimation, self.IdleAnimRate end
  end

  -- Internal --

  function ENT:UpdateAnimation()
    local anim, rate = self:OnUpdateAnimation()
    local type = SequenceOrActivity(anim)
    local current = self:GetSequence()
    local valid = false
    if type == "sequence" then
      local seq = self:LookupSequence(anim)
      valid = seq ~= -1
      if valid and (self:GetCycle() == 1 or seq ~= current) then
        ResetSequence(self, seq)
      end
    elseif type == "activity" then
      local seq = RandomSequence(self, anim)
      valid = seq ~= -1
      local act = self:GetSequenceActivity(current)
      if valid and (self:GetCycle() == 1 or anim ~= act) then
        ResetSequence(self, seq)
      end
    end
  end

  -- Meta --

  local nextbotMETA = FindMetaTable("NextBot")

  local old_GetActivity = nextbotMETA.GetActivity
  function nextbotMETA:GetActivity(...)
    if self.IsDrGNextbot2 then
      return self:GetSequenceActivity(self:GetSequence())
    else return old_GetActivity(self, ...) end
  end

  local old_StartActivity = nextbotMETA.StartActivity
  function nextbotMETA:StartActivity(act, ...)
    if self.IsDrGNextbot2 then
      local current = self:GetActivity()
      if current == act then return end
      ResetSequence(self, RandomSequence(self, act))
    else return old_StartActivity(self, act, ...) end
  end

end