
function ENT:IsWaiting()
  return self:GetNW2Bool("DrGBaseWaiting")
end
function ENT:IsJumping()
  return self:GetNW2Bool("DrGBaseJumping")
end
function ENT:IsLeaping()
  return self:GetNW2Bool("DrGBaseLeaping")
end
function ENT:IsGliding()
  return self:GetNW2Bool("DrGBaseGliding")
end

if SERVER then

  -- Misc --

  function ENT:Wait(duration, callback)
    if duration <= 0 then return end
    if callback == nil then callback = function() end end
    self:SetNW2Bool("DrGBaseWaiting", true)
    local delay = CurTime() + duration
    local targetdelay = 0
    local now = CurTime()
    while CurTime() < delay do
      if self:IsPossessed() then break end
      if self:HasEnemy() then break end
      if callback(CurTime() - now) then break end
      self:YieldCoroutine(true)
    end
    self:SetNW2Bool("DrGBaseWaiting", false)
  end

  -- Jumps --

  local function LocoJump(self)
    local seq = self:GetSequence()
    local cycle = self:GetCycle()
    self.loco:Jump()
    self:ResetSequence(seq)
    self:SetCycle(cycle)
  end
  local function LocoJumpGap(self, pos)
    local seq = self:GetSequence()
    local cycle = self:GetCycle()
    self.loco:JumpAcrossGap(pos, self:GetForward())
    self:ResetSequence(seq)
    self:SetCycle(cycle)
  end

  function ENT:LeaveGround()
    if not self:IsOnGround() then return end
    local jumpHeight = self.loco:GetJumpHeight()
    self.loco:SetJumpHeight(1)
    LocoJump(self)
    self.loco:SetJumpHeight(jumpHeight)
  end

  function ENT:Jump(height, callback)
    if isnumber(height) then
      local jumpHeight = self.loco:GetJumpHeight()
      self.loco:SetJumpHeight(height)
      LocoJump(self)
      self.loco:SetJumpHeight(jumpHeight)
    else LocoJump(self) end
    if not coroutine.running() then return end
    self:SetNW2Bool("DrGBaseJumping", true)
    local now = CurTime()
    while not self:IsOnGround() do
      if isfunction(callback) and
      callback(self, CurTime()-now) then break end
      self:YieldCoroutine(true)
    end
    self:SetNW2Bool("DrGBaseJumping", false)
  end

  function ENT:Leap(pos, callback)
    if isentity(pos) then pos = pos:WorldSpaceCenter() end
    self:FaceInstant(pos)
    LocoJumpGap(self, pos)
    if not coroutine.running() then return end
    self:SetNW2Bool("DrGBaseLeaping", true)
    local now = CurTime()
    while not self:IsOnGround() do
      if isfunction(callback) and
      callback(self, CurTime()-now) then break end
      self:YieldCoroutine(true)
    end
    self:SetNW2Bool("DrGBaseLeaping", false)
  end

  function ENT:Glide(dist, options, callback)
    if not coroutine.running() then return end
    options = options or {}
    options.speed = options.speed or self:GetSpeed()
    options.pitch = options.pitch or 15
    LocoJumpGap(self, self:GetPos() + self:GetForward()*dist)
    self:SetNW2Bool("DrGBaseGliding", true)
    local now = CurTime()
    while not self:IsOnGround() do
      if isfunction(callback) and
      callback(self, CurTime()-now) then break
      elseif self:GetVelocity().z <= 0 then
        local forward = self:GetForward()
        forward.z = -math.tan(math.rad(options.pitch))
        forward:Normalize()
        self.loco:SetVelocity(forward*options.speed*self:GetScale())
      end
      self:YieldCoroutine(true)
    end
    self:SetNW2Bool("DrGBaseGliding", false)
  end

end
