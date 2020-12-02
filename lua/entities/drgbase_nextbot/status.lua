-- ConVars --

local RemoveRagdolls = DrGBase.ConVar("drgbase_ragdolls_remove", "-1")
local RagdollFadeOut = DrGBase.ConVar("drgbase_ragdolls_fadeout", "3")
local DisableRagCollisions = DrGBase.ConVar("drgbase_ragdolls_collisions_disabled", "0")

-- Getters --

function ENT:GetHealthRegen()
  return self:GetNW2Float("DrG/HealthRegen", self.HealthRegen)
end

-- Alive? --

function ENT:IsDown()
  return self:GetNW2Bool("DrG/Down")
end
function ENT:IsDowned()
  return self:IsDown()
end
function ENT:IsDying()
  return self:GetNW2Bool("DrG/Dying")
end
function ENT:IsDead()
  return self:GetNW2Bool("DrG/Dead") or self:IsDying()
end

function ENT:IsAlive()
  return not self:IsDead()
end
function ENT:Alive()
  return self:IsAlive()
end

function ENT:GetDowned()
  return self:GetNW2Int("DrG/Downed")
end

if SERVER then

  -- Setters --

  function ENT:SetHealthRegen(regen)
    self:SetNW2Float("DrG/HealthRegen", regen)
  end

  function ENT:ScaleModel(mult, delta)
    self:SetModelScale(self:GetModelScale()*mult, delta)
  end

  function ENT:HasGodMode()
    return self:IsFlagSet(FL_GODMODE)
  end
  function ENT:SetGodMode(god)
    if tobool(god) then self:AddFlags(FL_GODMODE)
    else self:RemoveFlags(FL_GODMODE) end
  end
  function ENT:EnableGodMode()
    self:SetGodMode(true)
  end
  function ENT:DisableGodMode()
    self:SetGodMode(false)
  end

  function ENT:LastHitGroup()
    return this.DrG_LastHitGroup or DMG_GENERIC
  end
  function ENT:LastTimeHit()

  end
  function ENT:LastDamageInfo()

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

  function ENT:Kill(attacker, inflictor)
    local dmg = DamageInfo()
    dmg:SetAttacker(attacker or self)
    dmg:SetInflictor(inflictor)
    self:OnKilled(dmg)
  end

  function ENT:DrG_OnTraceAttack(_, _, tr)
    self.DrG_LastHitGroup = tr.HitGroup
    self.DrG_HitGroupToHandle = true
  end
  function ENT:OnTraceAttack() end

  local OnTookDamageDeprecation = DrGBase.Deprecation("ENT:OnTookDamage(dmginfo, hitgroup)", "ENT:DoTakeDamage(dmginfo, hitgroup)")
  local AfterTakeDamageDeprecation = DrGBase.Deprecation("ENT:AfterTakeDamage(dmginfo, delay, hitgroup)", "ENT:DoTakeDamage(dmginfo, hitgroup)")
  local OnDownedDeprecation = DrGBase.Deprecation("ENT:OnDowned(dmginfo, hitgroup)", "ENT:DoDowned(dmginfo, hitgroup)")
  function ENT:OnInjured() end
  function ENT:DrG_OnInjured(dmg)
    if self:HasGodMode() then dmg:ScaleDamage(0) end
    self:Timer(0, function() self:SetNW2Int("DrG/Health", self:Health()) end)
    local hitgroup = self.DrG_HitGroupToHandle and self.DrG_LastHitGroup or HITGROUP_GENERIC
    local res = self:OnTakeDamage(dmg, hitgroup)
    --local attacker = dmg:GetAttacker()
    -- todo => change relationships
    if self:IsDown() or self:IsDead() then
      self.DrG_HitGroupToHandle = false
      dmg:ScaleDamage(0)
    else
      if res == true then dmg:ScaleDamage(0) end
      if isnumber(res) then dmg:ScaleDamage(res) end
      if dmg:GetDamage() >= self:Health() then
        if self:OnFatalDamage(dmg, hitgroup) then
          self.DrG_HitGroupToHandle = false
          self:SetNW2Bool("DrG/Down", true)
          self:SetNW2Int("DrG/Downed", self:GetNW2Int("DrG/Downed")+1)
          self:SetHealth(1)
          --[[if #self.OnDownedSounds > 0 then
            self:EmitSound(self.OnDownedSounds[math.random(#self.OnDownedSounds)])
          end]]
          local noTarget = self:GetNoTarget()
          self:SetNoTarget(true)
          local data = dmg:DrG_Get()
          self:CallInThread(function(self)
            if isfunction(self.OnDowned) then
              OnDownedDeprecation()
              self:OnDowned(dmg:DrG_Set(data), hitgroup)
            else self:DoDowned(dmg:DrG_Set(data), hitgroup) end
            if self:Health() <= 0 then self:SetHealth(1) end
            self:SetNoTarget(noTarget)
            self:SetNW2Bool("DrG/Down", false)
          end)
        else self:SetHealth(0) end
        return dmg:ScaleDamage(0)
      else
        self.DrG_HitGroupToHandle = false
        --[[if #self.OnDamageSounds > 0 then
          self:EmitSlotSound("DrGBaseDamageSounds", self.DamageSoundDelay, self.OnDamageSounds[math.random(#self.OnDamageSounds)])
        end]]
        if isfunction(self.AfterTakeDamage) then -- backwards compatibility #2
          AfterTakeDamageDeprecation()
          local data = dmg:DrG_Get()
          self:ReactInThread(function(self)
            if self:IsDown() or self:IsDead() then return end
            self:AfterTakeDamage(dmg:DrG_Set(data), 0, hitgroup)
          end)
        elseif isfunction(self.OnTookDamage) then -- backwards compatibility
          OnTookDamageDeprecation()
          local data = dmg:DrG_Get()
          self:ReactInThread(function(self)
            if self:IsDown() or self:IsDead() then return end
            self:OnTookDamage(dmg:DrG_Set(data), hitgroup)
          end)
        elseif isfunction(self.DoTakeDamage) then
          local data = dmg:DrG_Get()
          self:ReactInThread(function(self)
            if self:IsDown() or self:IsDead() then return end
            self:DoTakeDamage(dmg:DrG_Set(data), hitgroup)
          end)
        end
      end
    end
  end

  local function NextbotDeath(self, dmg)
    if not IsValid(self) then return end
    if self:HasWeapon() and self:ShouldDropWeapon() then self:DropWeapon() end
    if self.RagdollOnDeath then
      local ragdoll = self:BecomeRagdoll(dmg)
      if IsValid(ragdoll) then
        if DisableRagCollisions:GetBool() or not GetConVar("ai_serverragdolls"):GetBool() then
          ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        end
        if not self.DrG_OnRagdollRes and RemoveRagdolls:GetFloat() >= 0 then
          ragdoll:Fire("fadeandremove", math.Clamp(RagdollFadeOut:GetFloat(), 0, math.huge), RemoveRagdolls:GetFloat())
        end
      end
    else self:Remove() end
  end

  local OnDeathDeprecation = DrGBase.Deprecation("ENT:OnDeath(dmginfo, hitgroup)", "ENT:DoDeath(dmginfo, hitgroup)")
  function ENT:OnKilled() end
  function ENT:DrG_OnKilled(dmg)
    local hitgroup = self.DrG_HitGroupToHandle and self.DrG_LastHitGroup or HITGROUP_GENERIC
    self.DrG_HitGroupToHandle = false
    if self:IsDead() then return end
    self:SetHealth(0)
    self:SetNW2Bool("DrG/Dying", true)
    self:DrG_DeathNotice(dmg:GetAttacker(), dmg:GetInflictor())
    --[[if #self.OnDeathSounds > 0 then
      self:EmitSound(self.OnDeathSounds[math.random(#self.OnDeathSounds)])
    end]]
    if dmg:IsDamageType(DMG_DISSOLVE) then self:DrG_Dissolve() end
    if isfunction(self.DoDeath) or isfunction(self.OnDeath) then -- backwards compatibility
      local data = dmg:DrG_Get()
      self:CallInThread(function(self)
        self:SetNW2Bool("DrG/Dying", false)
        self:SetNW2Bool("DrG/Dead", true)
        local now = CurTime()
        dmg:DrG_Set(data)
        if isfunction(self.OnDeath) then
          OnDeathDeprecation()
          dmg = self:OnDeath(dmg, hitgroup)
        else dmg = self:DoDeath(dmg, hitgroup) end
        if dmg == nil then
          dmg = DamageInfo(data)
          if CurTime() > now then
            dmg:SetDamageForce(Vector(0, 0, 1))
          end
        end
        NextbotDeath(self, dmg)
      end)
    else
      self:SetNW2Bool("DrG/Dying", false)
      self:SetNW2Bool("DrG/Dead", true)
      NextbotDeath(self, dmg)
    end
  end

  function ENT:OnTakeDamage() end
  function ENT:OnFatalDamage() end
  function ENT:DoDowned() end

  -- Meta --

  local entMETA = FindMetaTable("Entity")

  local old_SetHealth = entMETA.SetHealth
  function entMETA:SetHealth(health, ...)
    if self.IsDrGNextbot then
      if self:IsDead() then health = 0 end
      self:SetNW2Int("DrG/Health", health)
    end
    return old_SetHealth(self, health, ...)
  end

  local old_SetMaxHealth = entMETA.SetMaxHealth
  function entMETA:SetMaxHealth(health, ...)
    if self.IsDrGNextbot then self:SetNW2Int("DrG/MaxHealth", health) end
    return old_SetMaxHealth(self, health, ...)
  end

else

  -- Meta --

  local entMETA = FindMetaTable("Entity")

  local old_Health = entMETA.Health
  function entMETA:Health(...)
    if self.IsDrGNextbot then
      return self:GetNW2Int("DrG/Health", self.SpawnHealth)
    else return old_Health(self, ...) end
  end

  local old_GetMaxHealth = entMETA.GetMaxHealth
  function entMETA:GetMaxHealth(...)
    if self.IsDrGNextbot then
      return self:GetNW2Int("DrG/MaxHealth", self.SpawnHealth)
    else return old_GetMaxHealth(self, ...) end
  end

end