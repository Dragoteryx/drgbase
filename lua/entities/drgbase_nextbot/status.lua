-- Getters --

function ENT:GetHealthRegen()
  return self:GetNW2Float("DrGBaseHealthRegen", self.HealthRegen)
end

function ENT:GetGodMode()
  return self:GetNW2Bool("DrGBaseGodMode")
end

function ENT:LastHitGroup()
  return self:GetNW2Int("DrGBaseLastHitGroup")
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

  --[[function ENT:_DrGBaseThink_HealthRegen()
    self:SetHealth(math.Clamp(self:Health() + self:GetHealthRegen(), 0, self:GetMaxHealth()))
    return 1
  end]]

  -- Take damage hooks --

  function ENT:_DrGBaseOnTraceAttack(_, _, tr)
    self:SetNW2Int("DrGBaseLastHitGroup", tr.HitGroup)
    self._DrGBaseHitGroupToHandle = true
  end
  function ENT:OnTraceAttack() end

  function ENT:_DrGBaseOnInjured(dmg)
    local hitgroup = self._DrGBaseHitGroupToHandle and self:LastHitGroup() or nil

  end
  function ENT:OnInjured() end

  function ENT:_DrGBaseOnKilled(dmg)
    local hitgroup = self._DrGBaseHitGroupToHandle and self:LastHitGroup() or nil

  end
  function ENT:OnKilled() end

  function ENT:OnTakeDamage() end

  function ENT:DoOnTakeDamage(...) return self:OnTookDamage(...) end
  function ENT:OnTookDamage() end

  function ENT:OnFatalDamage() end

  function ENT:DoOnDowned(...) return self:OnDowned(...) end
  function ENT:OnDowned() end

  function ENT:DoOnDeath(...) return self:OnDeath(...) end
  function ENT:OnDeath() end

  -- Meta --

  local entMETA = FindMetaTable("Entity")

  local old_SetHealth = entMETA.SetHealth
  function entMETA:SetHealth(health, ...)
    if self.IsDrGNextbot then self:SetNW2Int("DrGBaseHealth", health) end
    return old_SetHealth(self, health, ...)
  end

  local old_SetMaxHealth = entMETA.SetMaxHealth
  function entMETA:SetMaxHealth(health, ...)
    if self.IsDrGNextbot then self:SetNW2Int("DrGBaseMaxHealth", health) end
    return old_SetMaxHealth(self, health, ...)
  end

else

  -- Meta --

  local entMETA = FindMetaTable("Entity")

  local old_Health = entMETA.Health
  function entMETA:Health(...)
    if self.IsDrGNextbot then return self:GetNW2Int("DrGBaseHealth", self.SpawnHealth)
    else return old_Health(self, ...) end
  end

  local old_GetMaxHealth = entMETA.GetMaxHealth
  function entMETA:GetMaxHealth(...)
    if self.IsDrGNextbot then return self:GetNW2Int("DrGBaseMaxHealth", self.SpawnHealth)
    else return old_GetMaxHealth(self, ...) end
  end

end