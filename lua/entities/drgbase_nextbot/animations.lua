-- Helpers --

local function GetAnimInfoSequence(self, seq)
  if isstring(sequence) then sequence = self:LookupSequence(sequence) end
  if not isnumber(sequence) or sequence == -1 then return {} end
  local seqName = self:GetSequenceName(seq)
  local seqInfo = self:GetSequenceInfo(seq)
  for i = 1, #seqInfo.anims do
    local anim = seqInfo.anims[i]
    local info = self:GetAnimInfo(anim)
    if info.label == "@"..seqName or info.label == "a_"..seqName then
      return info
    end
  end
end

ENT.DrG_ActIDsFromNames = {}
local function GetActivityIDFromName(self, name)
  if isnumber(self.DrG_ActIDsFromNames[name]) then
    return self.DrG_ActIDsFromNames[name]
  else
    for i in pairs(self:GetSequenceList()) do
      if self:GetSequenceActivityName(i) == name then
        local id = self:GetSequenceActivity(i)
        self.DrG_ActIDsFromNames[name] = id
        return id
      end
    end
    self.DrG_ActIDsFromNames[name] = ACT_INVALID
    return ACT_INVALID
  end
end

function ENT:IsAttack(sequence)
  if isstring(sequence) then sequence = self:LookupSequence(sequence) end
  if not isnumber(sequence) or sequence == -1 then return false end
  return string.find(string.lower(self:GetSequenceName(sequence)), "attack") or
  string.find(self:GetSequenceActivityName(sequence), "ATTACK")
end

-- Anim events --

ENT.DrG_AnimEvents = {}
function ENT:AddAnimEvent(sequence, frames, event)
  if isstring(sequence) then sequence = self:LookupSequence(sequence) end
  if not isnumber(sequence) or sequence == -1 then return false end
  if not istable(frames) then frames = {frames} end

end
function ENT:RemoveAnimEvents(sequence)
  if isstring(sequence) then sequence = self:LookupSequence(sequence) end
  if not isnumber(sequence) or sequence == -1 then return false end

end

if SERVER then

  local function RandomSequence(self, act)
    if isstring(act) then act = GetActivityIDFromName(self, act) end
    return self:SelectWeightedSequenceSeeded(act, math.random(0, 255))
  end

  local function GetSequences(self, act)
    local sequences = {}
    for i = 0, self:GetSequenceCount()-1 do
      if (isnumber(act) and self:GetSequenceActivity(i) == act) or
      (isstring(act) and self:GetSequenceActivityName(i) == act) then
        table.insert(i)
      end
    end
    return sequences
  end

  local INVALID = -1
  local SEQUENCE = 0
  local ACTIVITY = 1
  local function SequenceOrActivity(anim)
    if isnumber(anim) then return ACTIVITY
    elseif isstring(anim) then
      if string.StartWith(anim, "ACT_") then
        return ACTIVITY
      else return SEQUENCE end
    else return INVALID end
  end

  local function ResetSequence(self, seq)
    local len = self:SetSequence(seq)
    self:ResetSequenceInfo()
    self:SetCycle(0)
    return len
  end

  -- Helpers --

  function ENT:IsAttacking()
    return self:IsAttack(self:GetSequence())
  end

  -- PSAW and friends --

  function ENT:PlaySequenceAndWait(sequence, options, fn, ...)
    if istable(sequence) then return self:PlaySequenceAndWait(sequence[math.random(#sequence)], options, fn, ...) end
    if isfunction(options) then return self:PlaySequenceAndWait(sequence, 1, options, fn, ...) end
    if isnumber(options) then return self:PlaySequenceAndWait(sequence, {rate = options}, fn, ...) end
    if isbool(options) then return self:PlaySequenceAndWait(sequence, {cancellable = options}, fn, ...) end
    if isstring(sequence) then sequence = self:LookupSequence(sequence) end
    if not isnumber(sequence) or sequence == -1 then return false end
    if not istable(options) then options = {} end
    if not isnumber(options.rate) then options.rate = 1 end
    if not isbool(options.cancellable) then options.cancellable = false end
    if not isbool(options.gravity) then options.gravity = true end
    local args, n = table.DrG_Pack(...)
    ResetSequence(self, sequence)
    self:SetPlaybackRate(options.rate)
    local gravity = self:GetGravity()
    local previous = -1
    local res = nil
    while true do
      local cycle = self:GetCycle()
      if previous >= cycle then
        res = true
        break
      end
      if not options.gravity then
        self:SetVelocity(Vector())
        self:SetGravity(0)
      elseif self:GetGravity() == 0 then
        self:SetVelocity(Vector())
        self:SetGravity(gravity)
      end
      if isfunction(fn) then
        if n > 0 then res = fn(self, table.DrG_Unpack(args, n))
        else res = fn(self, cycle, previous) end
        if res ~= nil then break end
      end
      previous = cycle
      if self:YieldNoUpdate(options.cancellable) then
        res = false
        break
      end
    end
    self:SetGravity(gravity)
    if not options.gravity then self:SetVelocity(Vector()) end
    return res
  end
  function ENT:PlayActivityAndWait(act, ...)
    return self:PlaySequenceAndWait(RandomSequence(self, act), ...)
  end
  function ENT:PlayAnimationAndWait(anim, ...)
    local kind = SequenceOrActivity(anim)
    if istable(anim) or kind == SEQUENCE then
      return self:PlaySequenceAndWait(anim, ...)
    elseif kind == ACTIVITY then
      return self:PlayActivityAndWait(anim, ...)
    else return false end
  end

  function ENT:PlaySequenceAndMove(sequence, options, fn, ...)
    if istable(sequence) then return self:PlaySequenceAndMove(sequence[math.random(#sequence)], options, fn, ...) end
    if isfunction(options) then return self:PlaySequenceAndMove(sequence, 1, options, fn, ...) end
    if isnumber(options) then return self:PlaySequenceAndMove(sequence, {rate = options}, fn, ...) end
    if isbool(options) then return self:PlaySequenceAndMove(sequence, {cancellable = options}, fn, ...) end
    if isstring(sequence) then sequence = self:LookupSequence(sequence) end
    if not isnumber(sequence) or sequence == -1 then return false end
    if not istable(options) then options = {} end
    if not isbool(options.absolute) then options.absolute = false end
    if not isbool(options.collide) then options.collide = false end
    local args, n = table.DrG_Pack(...)
    local pos = self:GetPos()
    local res = self:PlaySequenceAndWait(sequence, options, function(self, cycle, previous)
      local ok, vec, angles = self:GetSequenceMovement(sequence, previous == -1 and 0 or previous, cycle)
      if ok then
        if isnumber(options.multiply) or isvector(options.multiply) then vec = vec*options.multiply end
        self:SetAngles(self:LocalToWorldAngles(angles))
        vec:Rotate(self:LocalToWorldAngles(angles))
        if options.absolute then
          self:SetVelocity(Vector())
          pos = pos + vec
          if options.collide and self:TraceHull(vec, {step = true}).Hit then
            return false
          else self:SetPos(pos) end
        elseif not self:TraceHull(vec, {step = true}).Hit then
          pos = self:GetPos() + vec
          self:SetPos(pos)
        elseif options.collide then return false
        else pos = self:GetPos() end
      end
      if isfunction(fn) then
        if n > 0 then return fn(self, table.DrG_Unpack(args, n))
        else return fn(self, cycle, previous) end
      end
    end)
    if options.absolute then self:SetVelocity(Vector()) end
    return res
  end
  function ENT:PlayActivityAndMove(act, ...)
    return self:PlaySequenceAndMove(RandomSequence(self, act), ...)
  end
  function ENT:PlayAnimationAndMove(anim, ...)
    local kind = SequenceOrActivity(anim)
    if istable(anim) or kind == SEQUENCE then
      return self:PlaySequenceAndMove(anim, ...)
    elseif kind == ACTIVITY then
      return self:PlayActivityAndMove(anim, ...)
    else return false end
  end

  function ENT:PlaySequenceAndClimb(sequence, options, fn, ...)
    if isnumber(options) then return self:PlaySequenceAndClimb(sequence, {height = options}, fn, ...) end
    if not istable(options) or not isnumber(options.height) then return false end
    if istable(sequence) then

    else
      if isstring(sequence) then sequence = self:LookupSequence(sequence) end
      if not isnumber(sequence) or sequence == -1 then return false end
      local ok, vec = self:GetSequenceMovement(sequence, 0, 1)
      if not ok then return false end
      options.absolute = true
      options.multiply = Vector(1, 1, options.height/vec.z/self:GetModelScale())
      return self:PlaySequenceAndMove(sequence, options, function(self, ...)
        if not self:TraceHull(self:GetForward()*self.LedgeDetectionDistance*2).Hit then return false end
        if isfunction(fn) then return fn(self, ...) end
      end, ...)
    end
  end
  function ENT:PlayActivityAndClimb(act, ...)
    return self:PlaySequenceAndClimb(GetSequences(self, act), ...)
  end
  function ENT:PlayAnimationAndClimb(anim, ...)
    local kind = SequenceOrActivity(anim)
    if istable(anim) or kind == SEQUENCE then
      return self:PlaySequenceAndClimb(anim, ...)
    elseif kind == ACTIVITY then
      return self:PlayActivityAndClimb(anim, ...)
    else return false end
  end

  -- Hooks --

  function ENT:BodyUpdate()
    self:BodyMoveXY()
  end

  function ENT:DoAnimChange(_old, _new) end

  -- Update --

  function ENT:UpdateAnimation(cancellable)
    local anim, rate = self:OnUpdateAnimation()
    local type = SequenceOrActivity(anim)
    local validAnim = false
    if type == SEQUENCE then
      local current = self:GetSequence()
      local seq = self:LookupSequence(anim)
      validAnim = seq ~= -1
      if validAnim and (self:GetCycle() == 1 or seq ~= current) then
        if cancellable and seq ~= current then self:DoAnimChange(current, seq) end
        ResetSequence(self, seq, cancellable)
      end
    elseif type == ACTIVITY then
      local current = self:GetActivity()
      local currentSeq = self:GetSequence()
      local seq = RandomSequence(self, anim)
      local act = self:GetSequenceActivity(seq)
      validAnim = seq ~= -1
      if validAnim and (self:GetCycle() == 1 or act ~= current) then
        if cancellable and seq ~= currentSeq then self:DoAnimChange(currentSeq, seq) end
        ResetSequence(self, seq, cancellable)
      end
    end
    if validAnim and isnumber(rate) and (
      not self:IsOnGround() or self:GetSequenceGroundSpeed(self:GetSequence()) == 0
    ) then self:SetPlaybackRate(rate) end
  end

  function ENT:OnUpdateAnimation()
    --[[if self:IsClimbingUp() then return self.ClimbUpAnimation, self.ClimbAnimRate
    elseif self:IsClimbingDown() then return self.ClimbDownAnimation, self.ClimbAnimRate]]
    if not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
    elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate
    elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
    else return self.IdleAnimation, self.IdleAnimRate end
  end

  -- Meta --

  local nextbotMETA = FindMetaTable("NextBot")

  local old_GetActivity = nextbotMETA.GetActivity
  function nextbotMETA:GetActivity(...)
    if self.IsDrGNextbot then
      return self:GetSequenceActivity(self:GetSequence())
    else return old_GetActivity(self, ...) end
  end

  local old_StartActivity = nextbotMETA.StartActivity
  function nextbotMETA:StartActivity(act, ...)
    if self.IsDrGNextbot then
      if isstring(act) then act = GetActivityIDFromName(self, act) end
      if not isnumber(act) or act == ACT_INVALID then return end
      if act == self:GetActivity() then return end
      local seq = RandomSequence(self, act)
      if seq ~= -1 then ResetSequence(self, act) end
    else return old_StartActivity(self, act, ...) end
  end

  local old_BodyMoveXY = nextbotMETA.BodyMoveXY
  function nextbotMETA:BodyMoveXY(options, ...)
    if self.IsDrGNextbot then
      if self.IsDrGNextbotSprite then return end
      if not istable(options) then options = {} end
      if options.advance ~= false then self:FrameAdvance() end
      if self:IsMoving() and self:IsOnGround() then
        if options.direction ~= false then
          if self:LookupPoseParameter("move_x") ~= -1 and
          self:LookupPoseParameter("move_y") ~= -1 then
            local movement = self:GetMovement(true)
            self:SetPoseParameter("move_x", movement.x)
            self:SetPoseParameter("move_y", movement.y)
          elseif self:LookupPoseParameter("move_yaw") ~= -1 then
            local forward = self:GetForward()
            local velocity = self:GetVelocity()
            forward.z = 0
            velocity.z = 0
            self:SetPoseParameter("move_yaw", math.AngleDifference(
              velocity:Angle().y, forward:Angle().y
            ))
          end
        end
        if options.rate ~= false then
          -- todo
        end
      end
    else return old_BodyMoveXY(self, options, ...) end
  end

end