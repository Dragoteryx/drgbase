if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_projectile"

-- Misc --
ENT.PrintName = "Missile"
ENT.Category = "DrGBase"

-- Stats --
ENT.AngleOffset = Angle(0, 0, 0)
ENT.Speed = 1000
ENT.TurnRate = 1

function ENT:IsActivated()
  return self:GetDrGVar("DrGBaseActivated")
end

function ENT:GetTarget()
  return self:GetDrGVar("DrGBaseTarget")
end

function ENT:GetSpeed()
  return self:GetDrGVar("DrGBaseSpeed")
end

function ENT:GetTurnRate()
  return self:GetDrGVar("DrGBaseTurnRate")
end

if SERVER then

  function ENT:CustomInitialize()
    self:SetSpeed(self.Speed)
    self:SetTurnRate(self.TurnRate)
    self:SetDrGVar("DrGBaseActivated", false)
  end

  function ENT:CustomThink()
    if not self:IsActivated() then return end
    local target = self:GetTarget()
    if target ~= nil then
      if isentity(target) then target = target:WorldSpaceCenter() end
      local normal = (target - self:GetPos()):GetNormalized()
      self:SetAngles(normal:Angle() + self.AngleOffset)
    end
    self:SetVelocity(self:GetForward()*self:GetSpeed())
  end

  -- Stats --

  function ENT:SetSpeed(speed)
    self:SetDrGVar("DrGBaseSpeed", speed)
  end

  function ENT:SetTurnRate(rate)
    self:SetDrGVar("DrGBaseTurnRate", rate)
  end

  -- Turn on/off --

  function ENT:TurnOn()
    if self._DrGBaseActivationLocked then return end
    self:SetDrGVar("DrGBaseActivated", true)
  end
  function ENT:TurnOff()
    if self._DrGBaseActivationLocked then return end
    self:SetDrGVar("DrGBaseActivated", false)
  end
  function ENT:Toggle()
    if self._DrGBaseActivationLocked then return end
    self:SetDrGVar("DrGBaseActivated", not self:IsActivated())
  end
  function ENT:LockActivation()
    self._DrGBaseActivationLocked = true
  end

  -- Targetting --

  function ENT:RemoveTarget()
    self:SetDrGVar("DrGBaseTarget", nil)
  end
  function ENT:TargetPos(pos)
    self:SetDrGVar("DrGBaseTarget", pos)
  end
  function ENT:TargetEntity(ent)
    self:SetDrGVar("DrGBaseTarget", ent)
  end

else



end
