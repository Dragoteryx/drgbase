
-- Getters/setters --

function ENT:GetHealthRegen()
  return self:GetNW2Float("DrGBaseHealthRegen", 0)
end

function ENT:GetScale()
  return self:GetNW2Float("DrGBaseScale", 1)
end

function ENT:IsDown()
  return self:GetNW2Bool("DrGBaseDown")
end
function ENT:IsDying()
  return self:GetNW2Bool("DrGBaseDying")
end
function ENT:IsDead()
  return self:GetNW2Bool("DrGBaseDead") or self:IsDying()
end

function ENT:IsDissolving()
  return self:GetNW2Bool("DrGBaseDissolving")
end

-- Functions --

-- Hooks --

-- Handlers --

function ENT:_InitStatus()
  if CLIENT then return end
  self._DrGBaseDamageMultipliers = {}
  for type, mult in pairs(self.DamageMultipliers) do
    if not isnumber(type) then continue end
    self:SetDamageMultiplier(type, mult)
  end
  self:LoopTimer(1, self._RegenHealth)
end

if SERVER then

  -- Getters/setters --

  function ENT:SetHealthRegen(regen)
    self:SetNW2Float("DrGBaseHealthRegen", regen)
  end

  function ENT:SetScale(scale, delta)
    self:SetNW2Float("DrGBaseScale", scale)
    self:SetModelScale(self.ModelScale*scale, delta)
    self:UpdateSpeed()
  end
  function ENT:Scale(mult, delta)
    self:SetScale(self:GetScale()*mult, delta)
  end

  function ENT:GetDamageMultiplier(type)
    return self._DrGBaseDamageMultipliers[type] or 1
  end
  function ENT:SetDamageMultiplier(type, mult)
    if mult == 1 then self._DrGBaseDamageMultipliers[type] = nil
    else self._DrGBaseDamageMultipliers[type] = mult end
  end

  -- Functions --

  -- Hooks --

  -- Handlers --

  function ENT:_RegenHealth()
    if self:IsDead() then return end
    local regen = self:GetHealthRegen()
    if regen > 0 then
      local health = self:Health() + regen
      if health > self:GetMaxHealth() then
        self:SetHealth(self:GetMaxHealth())
      else self:SetHealth(health) end
    elseif regen < 0 then
      local dmg = DamageInfo()
      dmg:SetDamage(regen)
      dmg:SetAttacker(self)
      dmg:SetInflictor(self)
      dmg:SetDamageType(DMG_DIRECT)
      self:TakeDamageInfo(dmg)
    end
  end

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

  -- Meta --

  local entMETA = FindMetaTable("Entity")

  local old_Health = entMETA.Health
  function entMETA:Health()
    if self.IsDrGNextbot then
      return self:GetNW2Int("DrGBaseHealth", old_Health(self))
    else return old_Health(self) end
  end

  local old_GetMaxHealth = entMETA.GetMaxHealth
  function entMETA:GetMaxHealth()
    if self.IsDrGNextbot then
      return self:GetNW2Int("DrGBaseMaxHealth", old_GetMaxHealth(self))
    else return old_GetMaxHealth(self) end
  end

  local old_OnGround = entMETA.OnGround
  function entMETA:OnGround()
    if self.IsDrGNextbot then
      return self:GetNW2Bool("DrGBaseOnGround")
    else return old_OnGround(self) end
  end

  local old_IsOnGround = entMETA.IsOnGround
  function entMETA:IsOnGround()
    if self.IsDrGNextbot then
      return self:OnGround()
    else return old_IsOnGround(self) end
  end

end
