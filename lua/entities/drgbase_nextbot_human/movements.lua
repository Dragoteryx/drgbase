
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

  function ENT:OnUpdateSpeed(run)
    if self:IsClimbing() then return self.ClimbSpeed
    elseif self:IsCrouching() then
      if run then return self.WalkSpeed
      else return self.CrouchSpeed end
    elseif run then return self.RunSpeed
    else return self.WalkSpeed end
  end

end
