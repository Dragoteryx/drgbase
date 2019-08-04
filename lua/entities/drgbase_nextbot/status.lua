
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

function ENT:IsAlive()
  return not self:IsDead()
end
function ENT:Alive()
  return self:IsAlive()
end

function ENT:GetDowned()
  return self:GetNW2Int("DrGBaseDowned")
end

-- Functions --

-- Hooks --

-- Handlers --

function ENT:_InitStatus()
  if CLIENT then return end
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

  -- Functions --

  function ENT:RegenHealth(health, duration, callback)
    if self:Health() >= health then return end
    if duration > 0 then
      local regen = (health - self:Health())/duration
      local oldRegen = self:GetHealthRegen()
      self:SetHealthRegen(regen)
      while math.Round(self:Health()) < math.Round(health) do
        if isfunction(callback) and callback(self, self:Health()) then break end
        self:YieldCoroutine(false)
      end
      self:SetHealthRegen(oldRegen)
    else self:SetHealth(health) end
  end

  function ENT:AddHealth(health)
    self:SetHealth(self:Health()+health, true)
  end
  function ENT:RemoveHealth(health)
    self:SetHealth(self:Health()-health, true)
  end

  function ENT:ScaleHealth(scale)
    scale = math.Clamp(scale, 0, math.huge)
    self:SetHealth(self:Health()*scale)
    self:SetMaxHealth(self:GetMaxHealth()*scale)
  end

  -- Hooks --

  -- Handlers --

  function ENT:_RegenHealth()
    if self:IsDead() then return end
    local regen = self:GetHealthRegen()
    if regen > 0 then
      self:AddHealth(regen)
    elseif regen < 0 then
      local dmg = DamageInfo()
      dmg:SetDamage(regen)
      dmg:SetAttacker(self)
      dmg:SetInflictor(self)
      dmg:SetDamageType(DMG_DIRECT)
      self:TakeDamageInfo(dmg)
    end
  end

  -- Meta --

  local entMETA = FindMetaTable("Entity")

  local old_SetHealth = entMETA.SetHealth
  function entMETA:SetHealth(health, clamp)
    if self.IsDrGNextbot then
      if self:IsDead() then return end
      if clamp then
        return old_SetHealth(self, math.Clamp(health, 0, self:GetMaxHealth()))
      else return old_SetHealth(self, health) end
    else return old_SetHealth(self, health) end
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
