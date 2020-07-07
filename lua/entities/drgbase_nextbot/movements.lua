-- Getters --

function ENT:IsMoving()
  return not self:GetVelocity():IsZero()
end

if SERVER then

  -- Getters --

  function ENT:IsRunning()
    if self:IsMoving() then
      if self:IsPossessed() then
        return self:GetPossessor():KeyDown(IN_SPEED)
      else return self:ShouldRun() end
    else return false end
  end

  -- Hooks --

  function ENT:OnUpdateSpeed()
    --[[if self:IsClimbing() then return self.ClimbSpeed
    else]]if self.UseWalkframes then return -1
    elseif self:IsRunning() then return self.RunSpeed
    else return self.WalkSpeed end
  end

  function ENT:UpdateSpeed()
    --print("speed")
  end

end