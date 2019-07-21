
-- Convars --

local MultDamagePlayer = CreateConVar("drgbase_multiplier_damage_players", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local MultDamageNPC = CreateConVar("drgbase_multiplier_damage_npc", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- Handlers --

function ENT:_InitHooks()
  if CLIENT then return end
  self:DrG_AddListener("OnContact", self._HandleContact)
end

if SERVER then

  -- Damage --

  function ENT:OnTakeDamage(dmg)
    self:SpotEntity(dmg:GetAttacker())
  end
  --function ENT:AfterTakeDamage() end

  function ENT:OnFatalDamage() end
  function ENT:OnDowned() end
  --function ENT:OnDeath() end

  function ENT:OnDealtDamage() end

  local function NextbotDeath(self, dmg)
    if self:HasWeapon() and self.DropWeaponOnDeath then
      self:DropWeapon()
    end
    if self.RagdollOnDeath then
      return self:BecomeRagdoll(dmg)
    else self:Remove() end
  end

  function ENT:OnInjured(dmg)
    for type, mult in pairs(self._DrGBaseDamageMultipliers) do
      if type == DMG_DIRECT then continue end
      if dmg:IsDamageType(type) then dmg:ScaleDamage(mult) end
    end
    if dmg:GetDamage() <= 0 then return end
    local res = self:OnTakeDamage(dmg)
    local attacker = dmg:GetAttacker()
    if IsValid(attacker) and DrGBase.IsTarget(attacker) then
      if self:IsAlly(attacker) then
        self._DrGBaseAllyDamageTolerance[attacker] = self._DrGBaseAllyDamageTolerance[attacker] or 0
        self._DrGBaseAllyDamageTolerance[attacker] = self._DrGBaseAllyDamageTolerance[attacker] + self.AllyDamageTolerance
        self:AddEntityRelationship(attacker, D_HT, self._DrGBaseAllyDamageTolerance[attacker])
      elseif self:IsAfraidOf(attacker) then
        self._DrGBaseAfraidOfDamageTolerance[attacker] = self._DrGBaseAfraidOfDamageTolerance[attacker] or 0
        self._DrGBaseAfraidOfDamageTolerance[attacker] = self._DrGBaseAfraidOfDamageTolerance[attacker] + self.AfraidOfDamageTolerance
        self:AddEntityRelationship(attacker, D_HT, self._DrGBaseAfraidOfDamageTolerance[attacker])
      elseif self:IsNeutral(attacker) then
        self._DrGBaseNeutralDamageTolerance[attacker] = self._DrGBaseNeutralDamageTolerance[attacker] or 0
        self._DrGBaseNeutralDamageTolerance[attacker] = self._DrGBaseNeutralDamageTolerance[attacker] + self.NeutralDamageTolerance
        self:AddEntityRelationship(attacker, D_HT, self._DrGBaseNeutralDamageTolerance[attacker])
      end
    end
    if res == true or self:IsDown() or self:IsDead() then
      return dmg:ScaleDamage(0)
    else
      if isnumber(res) then dmg:ScaleDamage(res) end
      if dmg:GetDamage() >= self:Health() then
        if #self.OnDeathSounds > 0 then
          self:EmitSound(self.OnDeathSounds[math.random(#self.OnDeathSounds)])
        end
        if self:OnFatalDamage(dmg) then
          self:SetNW2Bool("DrGBaseDown", true)
          self:SetNW2Int("DrGBaseDowned", self:GetNW2Int("DrGBaseDowned")+1)
          self:SetHealth(1)
          local noTarget = self:GetNoTarget()
          self:SetNoTarget(true)
          local data = util.DrG_SaveDmg(dmg)
          self:CallInCoroutine(function(self, delay)
            self:OnDowned(util.DrG_LoadDmg(data), delay)
            if self:Health() <= 0 then self:SetHealth(1) end
            self:SetNoTarget(noTarget)
            self:SetNW2Bool("DrGBaseDown", false)
          end)
          return dmg:ScaleDamage(0)
        end
      else
        if #self.OnDamageSounds > 0 then
          self:EmitSlotSound("DrGBaseDamageSounds", self.DamageSoundDelay, self.OnDamageSounds[math.random(#self.OnDamageSounds)])
        end
        if isfunction(self.AfterTakeDamage) then
          local data = util.DrG_SaveDmg(dmg)
          self:CallInCoroutine(function(self, delay)
            dmg = util.DrG_LoadDmg(data)
            self:AfterTakeDamage(dmg, delay)
          end)
        end
      end
    end
  end
  function ENT:OnKilled(dmg)
    if self:IsDead() then return end
    self:SetHealth(0)
    hook.Run("OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor())
    if isfunction(self.OnDeath) then
      local data = util.DrG_SaveDmg(dmg)
      self:SetNW2Bool("DrGBaseDying", true)
      self:CallInCoroutine(function(self, delay)
        self:SetNW2Bool("DrGBaseDying", false)
        self:SetHealth(0)
        self:SetNW2Bool("DrGBaseDead", true)
        local now = CurTime()
        dmg = util.DrG_LoadDmg(data)
        if dmg:IsDamageType(DMG_DISSOLVE) then self:DrG_Dissolve() end
        dmg = self:OnDeath(dmg, delay)
        if dmg == nil then
          dmg = util.DrG_LoadDmg(data)
          if CurTime() > now then
            dmg:SetDamageForce(Vector(0, 0, 1))
          end
        end
        NextbotDeath(self, dmg)
      end, true)
    else
      self:SetNW2Bool("DrGBaseDead", true)
      NextbotDeath(self, dmg)
    end
  end

  hook.Add("EntityTakeDamage", "DrGBaseNextbotDealtDamage", function(ent, dmg)
    local attacker = dmg:GetAttacker()
    if IsValid(attacker) and attacker.IsDrGNextbot then
      if ent:IsPlayer() then dmg:ScaleDamage(MultDamagePlayer:GetFloat())
      else dmg:ScaleDamage(MultDamageNPC:GetFloat()) end
      local res = attacker:OnDealtDamage(ent, dmg)
      if isnumber(res) then dmg:ScaleDamage(res)
      elseif res == true then return true end
    end
  end)

  -- Collisions --

  function ENT:OnCombineBall() end
  --function ENT:AfterCombineBall() end

  function ENT:_HandleContact(ent)
    local class = ent:GetClass()
    if class == "prop_combine_ball" then
      if self:IsFlagSet(FL_DISSOLVING) then return end
      if not self:OnCombineBall(ent) then
        if not self:IsDead() then
          local dmg = DamageInfo()
          local owner = ent:GetOwner()
          dmg:SetAttacker(IsValid(owner) and owner or ent)
          dmg:SetInflictor(ent)
          dmg:SetDamage(self:Health())
          dmg:SetDamageType(DMG_DISSOLVE)
          dmg:SetDamageForce(ent:GetVelocity())
          self:TakeDamageInfo(dmg)
        else self:DrG_Dissolve() end
        ent:EmitSound("NPC_CombineBall.KillImpact")
      elseif isfunction(self.AfterCombineBall) then
        self:CallInCoroutine(function(self, delay)
          self:AfterCombineBall(ent, delay)
        end)
      end
    elseif class == "replicator_melon" then
      ent:Replicate(self)
      self:Remove()
    elseif ent.IsDrGProjectile then
      ent:Contact(self)
    end
  end

  -- Misc --

  hook.Add("vFireEntityStartedBurning", "DrGBaseNextbotOnIgniteVFire", function(ent)
    if ent.IsDrGNextbot then ent:OnIgnite() end
  end)

end
