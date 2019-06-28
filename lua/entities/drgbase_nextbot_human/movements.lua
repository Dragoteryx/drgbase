
function ENT:IsCrouching()
  return self:GetNW2Bool("DrGBaseCrouching")
end
function ENT:Crouching()
  return self:IsCrouching()
end

if SERVER then

  -- Crouching --

  function ENT:SetCrouching(bool)
    self:SetNW2Bool("DrGBaseCrouching", bool)
  end
  function ENT:ToggleCrouching()
    self:SetCrouching(not self:IsCrouching())
  end

  -- Handlers --

  function ENT:OnUpdateSpeed()
    if self:IsClimbing() then return self.ClimbSpeed
    elseif self:IsCrouching() then
      if self:IsRunning() then return self.WalkSpeed
      else return self.CrouchSpeed end
    elseif self:IsRunning() then return self.RunSpeed
    else return self.WalkSpeed end
  end

end
