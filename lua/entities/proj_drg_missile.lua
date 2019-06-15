if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "proj_drg_default"
ENT.IsDrGMissile = true

-- Misc --
ENT.PrintName = "Missile"
ENT.Category = "DrGBase"

-- Stats --
ENT.AngleOffset = Angle(0, 0, 0)
ENT.Speed = 1000
ENT.TurnRate = 1

function ENT:IsActivated()
  return self:GetNW2Bool("DrGBaseActivated")
end

function ENT:GetTarget()
  local ent = self:GetNW2Entity("DrGBaseTargetEntity")
  if IsValid(ent) then return ent end
  local pos = self:GetNW2Entity("DrGBaseTargetPos", false)
  if not pos then return nil else return pos end
end

function ENT:GetSpeed()
  return self:GetNW2Float("DrGBaseSpeed")
end
function ENT:GetTurnRate()
  return self:GetNW2Float("DrGBaseTurnRate")
end

if SERVER then

  function ENT:CustomInitialize()
    self:SetSpeed(self.Speed)
    self:SetTurnRate(self.TurnRate)
  end

  function ENT:CustomThink()
    if not self:IsActivated() then return end
    local target = self:GetTarget()
    if target == nil then return end
    if isentity(target) then target = target:WorldSpaceCenter() end
    local normal = (target - self:GetPos()):GetNormalized()
    self:SetAngles(normal:Angle() + self.AngleOffset)
    self:SetVelocity(self:GetForward()*self:GetSpeed())
  end

  -- Stats --

  function ENT:SetSpeed(speed)
    self:SetNW2Float("DrGBaseSpeed", speed)
  end

  function ENT:SetTurnRate(rate)
    self:SetNW2Float("DrGBaseTurnRate", rate)
  end

  -- Turn on/off --

  function ENT:TurnOn()
    if self._DrGBaseActivationLocked then return end
    self:SetNW2Bool("DrGBaseActivated", true)
  end
  function ENT:TurnOff()
    if self._DrGBaseActivationLocked then return end
    self:SetNW2Bool("DrGBaseActivated", false)
  end
  function ENT:Toggle()
    if self._DrGBaseActivationLocked then return end
    self:SetNW2Bool("DrGBaseActivated", not self:IsActivated())
  end
  function ENT:LockActivation()
    self._DrGBaseActivationLocked = true
  end

  -- Targetting --

  function ENT:RemoveTarget()
    self:SetDrGVar("DrGBaseTargetEntity", nil)
    self:SetDrGVar("DrGBaseTargetPos", nil)
  end
  function ENT:TargetPos(pos)
    self:SetDrGVar("DrGBaseTargetEntity", nil)
    self:SetDrGVar("DrGBaseTargetPos", pos)
  end
  function ENT:TargetEntity(ent)
    self:SetDrGVar("DrGBaseTargetEntity", ent)
    self:SetDrGVar("DrGBaseTargetPos", nil)
  end

else



end
