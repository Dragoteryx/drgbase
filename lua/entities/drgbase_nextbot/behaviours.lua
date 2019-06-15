
-- Getters/setters --

function ENT:IsWaiting()
  return self:GetNW2Bool("DrGBaseWaiting")
end

if SERVER then

  -- Functions --

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

  function ENT:QuickJump(pos)
    if not self:IsOnGround() then return end
    if isvector(pos) then
      self:FaceInstant(pos)
      self.loco:JumpAcrossGap(pos, self:GetForward())
    elseif isnumber(pos) then
      local jumpheight = self.loco:GetMaxJumpHeight()
      self.loco:SetJumpHeight(pos*self:GetScale())
      self.loco:Jump()
      self.loco:SetJumpHeight(jumpheight)
    else self:QuickJump(self.loco:GetJumpHeight()) end
  end

  function ENT:Jump(pos, callback)
    self:QuickJump(pos)
    if callback == nil then callback = function() end end
    while not self:IsOnGround() and not self:IsDying() do
      if callback() then return end
      self:YieldCoroutine(true)
    end
  end

  function ENT:Glide(pos, options, callback)
    options = options or {}
    if callback == nil then callback = function() end end
    self:Jump(pos, function()
      local velocity = self:GetVelocity()
      if velocity.z < 0 and options.pitch ~= nil and options.speed ~= nil then
        local forward = self:GetForward()
        forward.z = -math.tan(math.rad(options.pitch))
        forward:Normalize()
        self:SetVelocity(forward*options.speed*self:GetScale())
      end
      return callback(options)
    end)
  end

end
