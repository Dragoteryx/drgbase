
if SERVER then

  -- Damage --

  function ENT:OnTakeDamage(dmg)
    self:SpotEntity(dmg:GetAttacker())
  end
  --function ENT:AfterTakeDamage() end

  function ENT:OnFatalDamage() end
  --function ENT:OnDeath() end
  function ENT:OnDowned() end

  function ENT:OnDealtDamage() end

  local function NextbotDeath(self, dmg)
    hook.Run("OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor())
    if self:HasWeapon() and self.DropWeaponOnDeath then
      self:DropWeapon()
    end
    if self.RagdollOnDeath then
      return self:BecomeRagdoll(dmg)
    else self:Remove() end
  end

  function ENT:OnInjured() end
  function ENT:OnKilled()
    DrGBase.Error("OnKilled has been called. This should never happen!")
  end

  hook.Add("EntityTakeDamage", "DrGBaseNextbotHandleDamage", function(self, dmg)
    local attacker = dmg:GetAttacker()
    if IsValid(attacker) and attacker.IsDrGNextbot then
      if attacker:OnDealtDamage(self, dmg) then return true end
    end
    if not self.IsDrGNextbot then return end
    if self:IsDown() or self:IsDead() then return true end
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
    if res ~= true then
      if isnumber(res) then dmg:ScaleDamage(res) end
      local data = util.DrG_SaveDmg(dmg)
      if dmg:GetDamage() >= self:Health() then
        self:SetHealth(0)
        if #self.OnDeathSounds > 0 then
          self:EmitSound(self.OnDeathSounds[math.random(#self.OnDeathSounds)])
        end
        if not self:OnFatalDamage(dmg) then
          if isfunction(self.OnDeath) then
            self:SetNW2Bool("DrGBaseDying", true)
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
            NextbotDeath(self, dmg)
          end
        else
          self:SetNW2Bool("DrGBaseDown", true)
          self:CallInCoroutine(function(self, delay)
            self:OnDowned(util.DrG_LoadDmg(data), delay)
            if self:Health() <= 0 then self:SetHealth(1) end
            self:SetNW2Bool("DrGBaseDown", false)
          end)
        end
        return true
      else
        if #self.OnDamageSounds > 0 then
          self:EmitSlotSound("DrGBaseDamageSounds", self.DamageSoundDelay, self.OnDamageSounds[math.random(#self.OnDamageSounds)])
        end
        if isfunction(self.AfterTakeDamage) then
          self:CallInCoroutine(function(self, delay)
            dmg = util.DrG_LoadDmg(data)
            self:AfterTakeDamage(dmg, delay)
          end)
        end
      end
    else return true end
  end)

  -- Misc --

  hook.Add("vFireEntityStartedBurning", "DrGBaseNextbotOnIgniteVFire", function(ent)
    if ent.IsDrGNextbot then ent:OnIgnite() end
  end)

end
