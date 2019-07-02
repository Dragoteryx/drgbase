
if SERVER then

  -- Damage --

  function ENT:OnTakeDamage(dmg)
    self:SpotEntity(dmg:GetAttacker())
  end

  function ENT:OnFatalDamage() end
  function ENT:OnDowned() end

  function ENT:OnInjured() end
  function ENT:OnKilled() end

  function ENT:OnDealtDamage() end

  local function NextbotDeath(self, dmg)
    if self:HasWeapon() and self.DropWeaponOnDeath then
      self:DropWeapon()
    end
    if self.RagdollOnDeath then
      return self:BecomeRagdoll(dmg)
    else self:Remove() end
  end

  local function NextbotFatalDamage(self, dmg)
    if self:IsDown() or self:IsDead() then return end
    self._DrGBaseDisableKill = true
    self:SetHealth(0)
    if #self.OnDeathSounds > 0 then
      self:EmitSound(self.OnDeathSounds[math.random(#self.OnDeathSounds)])
    end
    local data = util.DrG_SaveDmg(dmg)    
    if not self:OnFatalDamage(dmg) then
      if self:IsDead() then return end
      if isfunction(self.OnDeath) then
        self:SetNW2Bool("DrGBaseDying", true)
        hook.Run("OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor())
        self:CallInCoroutine(function(self, delay)
          self:SetNW2Bool("DrGBaseDying", false)
          self:SetNW2Bool("DrGBaseDead", true)
          local now = CurTime()
          dmg = self:OnDeath(util.DrG_LoadDmg(data), delay)
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
        hook.Run("OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor())
        NextbotDeath(self, dmg)
      end
    elseif not self:IsDown() then
      self:SetNW2Bool("DrGBaseDown", true)
      self:CallInCoroutine(function(self, delay)
        self:OnDowned(util.DrG_LoadDmg(data), delay)
        if self:Health() <= 0 then self:SetHealth(1) end
        self:SetNW2Bool("DrGBaseDown", false)
      end)
    end
    self._DrGBaseDisableKill = false
  end

  hook.Add("EntityTakeDamage", "DrGBaseNextbotHandleDamage", function(self, dmg)
    local attacker = dmg:GetAttacker()
    if IsValid(attacker) and attacker.IsDrGNextbot then
      local res = attacker:OnDealtDamage(self, dmg)
      if res == true then return true
      elseif isnumber(res) then dmg:ScaleDamage(res) end
    end
    if not self.IsDrGNextbot then return end
    for type, mult in pairs(self._DrGBaseDamageMultipliers) do
      if type == DMG_DIRECT then continue end
      if dmg:IsDamageType(type) then dmg:ScaleDamage(mult) end
    end
    local res = self:OnTakeDamage(dmg)
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
    if self:IsDown() or self:IsDead() then return true end
    if res ~= true then
      if isnumber(res) then dmg:ScaleDamage(res) end
      if dmg:GetDamage() >= self:Health() then
        NextbotFatalDamage(self, dmg)
        return true
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
    else return true end
  end)

  function ENT:Kill(attacker, inflictor, type)
    if self._DrGBaseDisableKill then return end
    local dmg = DamageInfo()
    dmg:SetDamage(math.huge)
    dmg:SetDamageType(type or DMG_DIRECT)
    dmg:SetDamageForce(Vector(0, 0, 1))
    dmg:SetAttacker(attacker or game.GetWorld())
    dmg:SetInflictor(inflictor or attacker or game.GetWorld())
    NextbotFatalDamage(self, dmg)
  end
  function ENT:Suicide(type)
    self:Kill(self, self, type)
  end

  -- Misc --

  hook.Add("vFireEntityStartedBurning", "DrGBaseNextbotOnIgniteVFire", function(ent)
    if ent.IsDrGNextbot then ent:OnIgnite() end
  end)

end
