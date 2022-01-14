-- Helpers --

local function GetNumFrames(self, seq)
  if isstring(sequence) then sequence = self:LookupSequence(sequence) end
  if not isnumber(sequence) or sequence == -1 then return end
  local seqName = self:GetSequenceName(seq)
  local seqInfo = self:GetSequenceInfo(seq)
  for i = 1, #seqInfo.anims do
    local anim = seqInfo.anims[i]
    local info = self:GetAnimInfo(anim)
    if info.label == "@"..seqName or info.label == "a_"..seqName then
      return info.numframes
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

function ENT:IsAttack(seq)
  if isstring(seq) then seq = self:LookupSequence(seq) end
  if not isnumber(seq) or seq == -1 then return false end
  local res = self:GetNW2Bool("DrG/IsAttack/"..seq, 0)
  if isbool(res) then return res end
  return string.find(string.lower(self:GetSequenceName(seq)), "attack")
  or string.find(self:GetSequenceActivityName(seq), "ATTACK")
end

function ENT:IsAttacking()
  return self:IsAttack(self:GetSequence())
end

-- Anim events --

ENT.DrG_AnimEvents = {}
function ENT:AddAnimEventCycle(seq, cycles, event)
  if isstring(seq) then seq = self:LookupSequence(seq) end
  if not isnumber(seq) or seq == -1 then return false end
  if not istable(cycles) then cycles = {cycles} end
  self.DrG_AnimEvents[seq] = self.DrG_AnimEvents[seq] or {}
  local events = self.DrG_AnimEvents[seq]
  for _, cycle in ipairs(cycles) do
    events[cycle] = events[cycle] or {}
    table.insert(events[cycle], event)
  end
end
function ENT:AddAnimEvent(seq, frames, event)
  if isstring(seq) then seq = self:LookupSequence(seq) end
  if not isnumber(seq) or seq == -1 then return false end
  if not istable(frames) then frames = {frames} end
  local numframes = GetNumFrames(self, seq)
  if not numframes then return end
  local cycles = {}
  for _, frame in ipairs(frames) do
    table.insert(cycles, frame/(numframes-1))
  end
  self:AddAnimEventCycle(seq, cycles, event)
end
function ENT:RemoveAnimEvents(seq)
  if isstring(seq) then seq = self:LookupSequence(seq) end
  if not isnumber(seq) or seq == -1 then return false end
  self.DrG_AnimEvents[seq] = nil
end

function ENT:DrG_PlayAnimEvents(seq, curCycle, lastCycle)
  local events = self.DrG_AnimEvents[seq]
  if events then for cycle, eventList in pairs(events) do
    if (curCycle > cycle and lastCycle <= cycle) or
    (curCycle < lastCycle and curCycle >= cycle) or
    (curCycle < lastCycle and lastCycle <= cycle) then
      local now = CurTime()
      for _, event in ipairs(eventList) do
        local res = self:OnAnimEvent(event, -1, self:GetPos(), self:GetAngles(), now)
        if SERVER then self:ReactInCoroutine(self.DoAnimEvent, event, -1, self:GetPos(), self:GetAngles(), now) end
        if not res then self:DrG_BuiltInEvents(event) end
      end
    end
  end end
end

function ENT:DrG_BuiltInEvents(event)
  if event == "drg.footstep" then self:EmitFootstep() end
end

if SERVER then

  local function RandomSequence(self, act)
    if isstring(act) then act = GetActivityIDFromName(self, act) end
    return self:SelectWeightedSequenceSeeded(act, math.random(0, 255))
  end

  local function GetSequences(self, act)
    local seqs = {}
    for i = 0, self:GetSequenceCount()-1 do
      if (isnumber(act) and self:GetSequenceActivity(i) == act) or
      (isstring(act) and self:GetSequenceActivityName(i) == act) then
        table.insert(i)
      end
    end
    return seqs
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
    local old = self:GetSequence()
    local len = self:SetSequence(seq)
    self:ResetSequenceInfo()
    self:SetCycle(0)
    if old ~= seq then self:OnAnimChange(old, seq) end
    return len
  end

  -- Helpers --

  function ENT:SetAttack(seq, attack)
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if not isnumber(seq) or seq == -1 then return end
    self:SetNW2Bool("DrG/IsAttack/"..seq, attack)
  end

  -- PSAW and friends --

  function ENT:PlaySequenceAndWait(seq, options, fn, ...)
    if istable(seq) then return self:PlaySequenceAndWait(seq[math.random(#seq)], options, fn, ...) end
    if isfunction(options) then return self:PlaySequenceAndWait(seq, 1, options, fn, ...) end
    if isnumber(options) then return self:PlaySequenceAndWait(seq, {rate = options}, fn, ...) end
    if isbool(options) then return self:PlaySequenceAndWait(seq, {cancellable = options}, fn, ...) end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if not isnumber(seq) or seq == -1 then return false end
    if not istable(options) then options = {} end
    if not isnumber(options.rate) then options.rate = 1 end
    if not isbool(options.gravity) then options.gravity = true end
    local args, n = table.DrG_Pack(...)
    ResetSequence(self, seq)
    self:SetPlaybackRate(options.rate)
    local gravity = self:GetGravity()
    local lastCycle = -1
    local res = nil
    while true do
      local cycle = self:GetCycle()
      if lastCycle == 1 then
        res = true
        break
      end
      if options.forward then
        if self:IsPossessed() then self:PossessionFaceForward()
        elseif self:HasEnemy() then self:FaceTowards(self:GetEnemy()) end
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
        else res = fn(self, cycle, lastCycle) end
        if res ~= nil then break end
      end
      lastCycle = cycle
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

  function ENT:PlaySequenceAndMove(seq, options, fn, ...)
    if istable(seq) then return self:PlaySequenceAndMove(seq[math.random(#seq)], options, fn, ...) end
    if isfunction(options) then return self:PlaySequenceAndMove(seq, 1, options, fn, ...) end
    if isnumber(options) then return self:PlaySequenceAndMove(seq, {rate = options}, fn, ...) end
    if isbool(options) then return self:PlaySequenceAndMove(seq, {cancellable = options}, fn, ...) end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if not isnumber(seq) or seq == -1 then return false end
    if not istable(options) then options = {} end
    if not isbool(options.absolute) then options.absolute = false end
    if not isbool(options.collide) then options.collide = false end
    if not isbool(options.rotate) then options.rotate = true end
    local args, n = table.DrG_Pack(...)
    local pos = self:GetPos()
    local res = self:PlaySequenceAndWait(seq, options, function(self, cycle, lastCycle)
      local ok, vec, angles = self:GetSequenceMovement(seq, lastCycle == -1 and 0 or lastCycle, cycle)
      if ok then
        vec = vec*self:GetModelScale()
        if isnumber(options.multiply) or isvector(options.multiply) then vec = vec*options.multiply end
        if options.rotate then self:SetAngles(self:LocalToWorldAngles(angles)) end
        vec:Rotate(self:LocalToWorldAngles(angles))
        if options.absolute then
          self:SetVelocity(Vector())
          pos = pos + vec
          if options.collide and self:TraceHull({direction = vec, step = true}).Hit then
            return false
          else self:SetPos(pos) end
        elseif options.collide then
          local tr = self:TraceHull({direction = vec, step = true})
          if not tr.Hit then
            pos = self:GetPos() + vec
            self:SetPos(pos)
          else return false end
        else
          local trX = self:TraceHull({direction = Vector(vec.x, 0, 0), step = true})
          local trY = self:TraceHull({direction = Vector(0, vec.y, 0), start = trX.HitPos, step = true})
          local trZ = self:TraceHull({direction = Vector(0, 0, vec.z), start = trY.HitPos, step = true})
          pos = trZ.HitPos
          self:SetPos(pos)
        end
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

  function ENT:PlaySequenceAndClimb(seq, options, ...)
    if isnumber(options) then return self:PlaySequenceAndClimb(seq, {height = options}, fn, ...) end
    if not istable(options) or not isnumber(options.height) then return false end
    if istable(seq) then
      local best = nil
      local height = nil
      for _, se in ipairs(seq) do
        if isstring(se) then se = self:LookupSequence(se) end
        if not isnumber(se) or se == -1 then continue end
        local ok, vec = self:GetSequenceMovement(se, 0, 1)
        if not ok or vec.z <= 0 then continue end
        local seHeight = vec.z*self:GetModelScale()
        if not best or math.abs(options.height - height) > math.abs(options.height - seHeight) then
          height = seHeight
          best = se
        end
      end
      if not best then return false end
      return self:PlaySequenceAndClimb(best, options, ...)
    else
      if isstring(seq) then seq = self:LookupSequence(seq) end
      if not isnumber(seq) or seq == -1 then return false end
      local ok, vec = self:GetSequenceMovement(seq, 0, 1)
      if not ok then return false end
      options.absolute = true
      options.multiply = Vector(1, 1, options.height/vec.z/self:GetModelScale())
      return self:PlaySequenceAndMove(seq, options, ...)
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

  function ENT:PlaySequence(seq, options, fn, ...)
    if istable(seq) then return self:PlaySequence(seq[math.random(#seq)], options, fn, ...) end
    if isfunction(options) then return self:PlaySequence(seq, 1, options, fn, ...) end
    if isnumber(options) then return self:PlaySequence(seq, {rate = options}, fn, ...) end
    if isstring(seq) then seq = self:LookupSequence(seq) end
    if not isnumber(seq) or seq == -1 then return false end
    if not istable(options) then options = {} end
    if not isnumber(options.rate) then options.rate = 1 end
    local args, n = table.DrG_Pack(...)
    local layer = self:AddGestureSequence(seq, true)
    if layer == -1 then return false end
    self:SetLayerPlaybackRate(layer, options.rate)
    self:SetLayerWeight(layer, 1)
    self:ParallelCoroutine(function(self)
      local lastCycle = -1
      while self:GetLayerSequence(layer) == seq do
        local cycle = self:GetLayerCycle(layer)
        self:DrG_PlayAnimEvents(seq, cycle, math.max(lastCycle, 0))
        lastCycle = cycle
        if isfunction(fn) then
          if n > 0 then fn(self, table.DrG_Unpack(args, n))
          else fn(self, cycle, lastCyle) end
        end
        coroutine.yield()
      end
    end)
    return true, layer
  end
  function ENT:PlayActivity(act, ...)
    return self:PlaySequence(RandomSequence(self, act), ...)
  end
  function ENT:PlayAnimation(anim, ...)
    local kind = SequenceOrActivity(anim)
    if istable(anim) or kind == SEQUENCE then
      return self:PlaySequence(anim, ...)
    elseif kind == ACTIVITY then
      return self:PlayActivity(anim, ...)
    else return false end
  end

  -- Hooks --

  function ENT:BodyUpdate()
    self:BodyMoveXY({rate = false})
  end

  function ENT:OnAnimChange(_old, _new) end
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
    if validAnim and isnumber(rate) then self:SetPlaybackRate(rate) end
    self:BodyMoveXY({frameadvance = false, direction = false})
  end

  function ENT:OnUpdateAnimation()
    --[[if self:IsClimbingUp() then return self.ClimbUpAnimation, self.ClimbAnimRate
    elseif self:IsClimbingDown() then return self.ClimbDownAnimation, self.ClimbAnimRate]]
    if not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
    elseif self:IsCrouching() then
      if self:IsRunning() then return self.CrouchRunAnimation, self.CrouchRunAnimRate
      elseif self:IsMoving() then return self.CrouchWalkAnimation, self.CrouchWalkAnimRate
      else return self.CrouchIdleAnimation, self.CrouchIdleAnimRate end
    else
      if self:IsRunning() then return self.RunAnimation, self.RunAnimRate
      elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
      elseif self.EnableTurning then
        if self:IsTurningLeft() then return self.TurnLeftAnimation, self.TurnLeftAnimRate
        elseif self:IsTurningRight() then return self.TurnRightAnimation, self.TurnRightAnimRate end
      end
      return self.IdleAnimation, self.IdleAnimRate
    end
  end

  -- Meta --

  local nbMETA = FindMetaTable("NextBot")

  local GetActivity = nbMETA.GetActivity
  function nbMETA:GetActivity(...)
    if self.IsDrGNextbot then
      return self:GetSequenceActivity(self:GetSequence())
    else return GetActivity(self, ...) end
  end

  local StartActivity = nbMETA.StartActivity
  function nbMETA:StartActivity(act, ...)
    if self.IsDrGNextbot then
      if isstring(act) then act = GetActivityIDFromName(self, act) end
      if not isnumber(act) or act == ACT_INVALID then return end
      if act == self:GetActivity() then return end
      local seq = RandomSequence(self, act)
      if seq ~= -1 then ResetSequence(self, act) end
    else return StartActivity(self, act, ...) end
  end

  local BodyMoveXY = nbMETA.BodyMoveXY
  function nbMETA:BodyMoveXY(options, ...)
    if self.IsDrGNextbot then
      if self.IsDrGNextbotSprite then return end
      if not istable(options) then options = {} end
      if options.frameadvance ~= false then self:FrameAdvance() end
      if self:IsMoving() then
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
          local velocity = self:GetVelocity()
          if self:IsOnGround() then
            velocity.z = 0
            if velocity:IsZero() then return end
            local speed = velocity:Length()
            local seqspeed = self:GetSequenceGroundSpeed(self:GetSequence())
            if seqspeed ~= 0 then self:SetPlaybackRate(speed/seqspeed) end
          elseif not velocity:IsZero() then
            local speed = velocity:Length()
            local ok, vec = self:GetSequenceMovement(self:GetSequence(), 0, 1)
            if not ok or vec.z == 0 then return end
            local seqspeed = (vec:Length()/self:SequenceDuration())*self:GetModelScale()
            if seqspeed ~= 0 then self:SetPlaybackRate(speed/seqspeed) end
          end
        end
      end
    else return BodyMoveXY(self, options, ...) end
  end

end