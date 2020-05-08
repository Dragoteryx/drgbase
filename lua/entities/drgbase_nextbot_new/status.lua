-- Getters --

function ENT:GetHealthRegen()
  return self:GetNW2Float("DrGBaseHealthRegen", 0)
end

function ENT:GetGodMode()
  return self:GetNW2Bool("DrGBaseGodMode")
end

-- Alive? --

function ENT:IsDown()
  return self:GetNW2Bool("DrGBaseDown")
end
function ENT:IsDowned()
  return self:IsDown()
end
function ENT:IsDying()
  return self:GetNW2Bool("DrGBaseDying")
end
function ENT:IsDead()
  return self:GetNW2Bool("DrGBaseDead") or self:IsDying()
end

function ENT:IsAlive()
  return not self:IsDead()
end
function ENT:Alive()
  return self:IsAlive()
end

function ENT:GetDowned()
  return self:GetNW2Int("DrGBaseDowned")
end

if SERVER then

  -- Setters --

  function ENT:SetHealthRegen(regen)
    self:SetNW2Float("DrGBaseHealthRegen", regen)
  end

  function ENT:ScaleModel(mult, delta)
    self:SetModelScale(self:GetModelScale()*mult, delta)
  end

  function ENT:SetGodMode(god)
    return self:SetNW2Bool("DrGBaseGodMode", tobool(god))
  end
  function ENT:EnableGodMode()
    self:SetGodMode(true)
  end
  function ENT:DisableGodMode()
    self:SetGodMode(false)
  end

  -- Health --

  function ENT:ScaleHealth(scale)
    scale = math.Clamp(scale, 0, math.huge)
    self:SetHealth(self:Health()*scale)
    self:SetMaxHealth(self:GetMaxHealth()*scale)
  end

  function ENT:_DrGBaseThink_HealthRegen()
    self:SetHealth(math.Clamp(self:Health() + self:GetHealthRegen(), 0, self:GetMaxHealth()))
    return 1
  end

  -- Take damage hooks --

  function ENT:_DrGBaseOnTraceAttack(dmg, dir, tr)
    self:SetNW2Int("DrGBaseLastHitGroup", tr.HitGroup)
    self._DrGBaseHitGroupToHandle = true
  end
  function ENT:_DrGBaseOnInjured(dmg)

  end
  function ENT:_DrGBaseOnKilled(dmg)

  end

  function ENT:OnTakeDamage() end
  function ENT:OnTookDamage() end
  function ENT:OnFatalDamage() end
  function ENT:OnDowned() end
  function ENT:OnDeath() end

end