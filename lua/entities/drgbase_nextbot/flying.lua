
-- Getters --

function ENT:IsFlying()
  return self:GetDrGVar("DrGBaseFlying")
end

if SERVER then

  -- Setters --

  function ENT:ToggleFlight(bool)
    if not self.Flight then return end
    local flying = self:IsFlying()
    if bool == nil then self:ToggleFlight(not self:IsFlying())
    elseif bool then self:SetDrGVar("DrGBaseFlying", true)
    else self:SetDrGVar("DrGBaseFlying", false) end
    if self:IsFlying() ~= flying then
      if self:IsFlying() then
        self:QuickJump(1)
        self:OnStartFlying()
      else self:OnStopFlying() end
    end
  end
  function ENT:OnStartFlying() end
  function ENT:OnStopFlying() end

  -- Movement --

  function ENT:FlyTowards(pos, face)
    if not self:IsFlying() then return end
    if not self:CanMove(self:GetPossessor()) then self:FlightHover()
    else
      local angles = (pos - self:GetPos()):Angle()
      local pitch = -math.NormalizeAngle(angles.p)
      if pitch > self.FlightMaxPitch then pitch = self.FlightMaxPitch end
      if pitch < self.FlightMinPitch then pitch = self.FlightMinPitch end
      angles.p = -pitch
      self:SetVelocity(angles:Forward()*self:GetSpeed())
      if face then self.loco:FaceTowards(pos) end
    end
  end

  function ENT:FlyForwardTo(pos)
    if not self:IsFlying() then return end
    if not self:CanMove(self:GetPossessor()) then self:FlightHover()
    else
      local angles = (pos - self:GetPos()):Angle()
      local pitch = -math.NormalizeAngle(angles.p)
      if pitch > self.FlightMaxPitch then pitch = self.FlightMaxPitch end
      if pitch < self.FlightMinPitch then pitch = self.FlightMinPitch end
      local forward = self:GetForward()
      forward.z = math.tan(math.rad(pitch))
      forward:Normalize()
      self.loco:FaceTowards(pos)
      self:SetVelocity(forward*self:GetSpeed())
    end
  end

  function ENT:FlightHover()
    if not self:IsFlying() then return end
    if self._DrGBaseHoverPos == nil then self._DrGBaseHoverPos = self:GetPos() end
    self:SetPos(self._DrGBaseHoverPos)
    self:SetVelocity(Vector(0, 0, DRGBASE_FLIGHT_HOVER))
  end

  -- Handlers --

  function ENT:_HandleFlight()
    if not self:IsFlying() then return end
    local velocity = self:GetVelocity()
    if velocity.x ~= 0 or velocity.y ~= 0 then self._DrGBaseHoverPos = nil end
    if self:IsPossessed() then
      -- stuff
    else
      local state = self:GetState()
      if state == DRGBASE_STATE_NONE or
      state == DRGBASE_STATE_AI_STANDBY then
        self:FlightHover()
      end
    end
  end

end
