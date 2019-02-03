
function ENT:IsCrouching()
  return self:GetDrGVar("DrGBaseCrouching")
end
function ENT:Crouching()
  return self:IsCrouching()
end

if SERVER then

  -- Crouching --

  function ENT:ToggleCrouching(bool)
    if bool == nil then self:ToggleCrouching(not self:IsCrouching())
    elseif bool then self:SetDrGVar("DrGBaseCrouching", true)
    else self:SetDrGVar("DrGBaseCrouching", false) end
  end

  -- Handlers --

  function ENT:UpdateSpeed(run)
    if self:IsClimbing() then return self.ClimbSpeed
    elseif self:IsCrouching() then
      if run then return self.WalkSpeed
      else return self.CrouchSpeed end
    elseif run then return self.RunSpeed
    else return self.WalkSpeed end
  end

end
