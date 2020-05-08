if SERVER then

  -- Helpers --

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
    ResetSequence(self, seq)
    self:SetPlaybackRate(options.rate)
    local previous = -1
    while true do
      local cycle = self:GetCycle()
      if previous > cycle then return true end
      if previous == cycle and cycle == 1 then return true end
      previous = cycle
      if isfunction(fn) then
        local res = fn(self, cycle, previous)
        if res != nil then return res end
      end
      if self:YieldCoroutineNoUpdate(options.cancellable) then
        return false
      end
    end
  end
  function ENT:PlayActivityAndWait(act, options, fn)
    return self:PlaySequenceAndWait(RandomSequence(self, act), options, fn)
  end
  function ENT:PlayAnimationAndWait(anim, options, fn)
    local kind = SequenceOrActivity(anim)
    if kind == "sequence" then
      return self:PlaySequenceAndWait(anim, options, fn)
    elseif kind == "activity" then
      return self:PlayActivityAndWait(anim, options, fn)
    else return false end
  end

  function ENT:PlaySequenceAndMove(sequence, options, fn)
    if isnumber(options) then return self:PlaySequenceAndMove(sequence, {rate = options}, fn) end
    if isbool(options) then return self:PlaySequenceAndMove(sequence, {gravity = options}, fn) end
    if not istable(options) then options = {} end
    if not isbool(options.gravity) then options.gravity = true end
    if not isbool(options.collide) then options.collide = true end
    if not isbool(options.stoponcollide) then options.stoponcollide = true end
    return self:PlaySequenceAndWait(sequence, options, function(self, cycle, previous)

      return fn(self, cycle, previous)
    end)
  end
  function ENT:PlayActivityAndMove(act, options, fn)
    return self:PlaySequenceAndMove(RandomSequence(self, act), options, fn)
  end
  function ENT:PlayAnimationAndMove(anim, options, fn)
    local kind = SequenceOrActivity(anim)
    if kind == "sequence" then
      return self:PlaySequenceAndMove(anim, options, fn)
    elseif kind == "activity" then
      return self:PlayActivityAndMove(anim, options, fn)
    else return false end
  end

  function ENT:PlaySequenceAndMoveAbsolute(sequence, options, fn)
    if isnumber(options) then return self:PlaySequenceAndMoveAbsolute(sequence, {rate = options}, fn) end
    if not istable(options) then options = {} end
    options.gravity = false
    options.collide = false
    return self:PlaySequenceAndMove(sequence, options, fn)
  end
  function ENT:PlayActivityAndMoveAbsolute(act, options, fn)
    return self:PlaySequenceAndMoveAbsolute(RandomSequence(self, act), options, fn)
  end
  function ENT:PlayAnimationAndMoveAbsolute(anim, options, fn)
    local kind = SequenceOrActivity(anim)
    if kind == "sequence" then
      return self:PlaySequenceAndMoveAbsolute(anim, options, fn)
    elseif kind == "activity" then
      return self:PlayActivityAndMoveAbsolute(anim, options, fn)
    else return false end
  end

  -- Hooks --

  function ENT:OnUpdateAnimation()

  end

  -- Internal --

  function ENT:_DrGBaseUpdateAnimation()
    local anim, rate = self:OnUpdateAnimation()
    local kind = SequenceOrActivity(self, anim)
    if kind == "sequence" then

    elseif kind == "activity" then

    end
  end

end