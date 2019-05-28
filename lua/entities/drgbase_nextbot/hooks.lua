
if SERVER then

  -- Hooks --

  function ENT:OnTakeDamage(dmg)
    --self:SpotEntity(dmg:GetAttacker())
  end
  function ENT:AfterTakeDamage() end
  function ENT:OnDeath() end
  function ENT:DoOnDeath() end

  function ENT:OnDamagedByAlly() end
  function ENT:OnDamagedByEnemy() end
  function ENT:OnDamagedByAfraidOf() end
  function ENT:OnDamagedByNeutral() end

  function ENT:OnCombineBall() end
  function ENT:OnContactAny(ent)
    self:SpotEntity(ent)
  end
  function ENT:OnPhysContact() end
  function ENT:OnAllyContact() end
  function ENT:OnEnemyContact() end
  function ENT:OnAfraidOfContact() end
  function ENT:OnNeutralContact() end
  function ENT:OnPlayerContact() end
  function ENT:OnNPCContact() end
  function ENT:OnNextbotContact() end
  function ENT:OnVehicleContact() end
  function ENT:OnWeaponContact() end
  function ENT:OnPropContact() end
  function ENT:OnRagdollContact() end
  function ENT:OnWorldContact() end
  function ENT:OnOtherContact() end

  -- Handlers --

  function ENT:OnInjured(dmg)
    for type, mult in pairs(self._DrGBaseDamageMultipliers) do
      if type == DMG_DIRECT then continue end
      if dmg:IsDamageType(type) then dmg:ScaleDamage(mult) end
    end
    if dmg:GetDamage() <= 0 then return end
    if #self.OnDamageSounds > 0 then
      self:EmitSlotSound("DrGBaseOnDamage", self.DamageSoundDelay, self.OnDamageSounds[math.random(#self.OnDamageSounds)])
    end
    local res = self:OnTakeDamage(dmg)
    local attacker = dmg:GetAttacker()
    if self:IsAlly(attacker) then
      if not self:OnDamagedByAlly(attacker, dmg) then
        local crea = attacker:GetCreationID()
        self._DrGBaseAllyDamageTolerance[crea] = self._DrGBaseAllyDamageTolerance[crea] or 0
        self._DrGBaseAllyDamageTolerance[crea] = self._DrGBaseAllyDamageTolerance[crea] + self.AllyDamageTolerance
        self:AddEntityRelationship(attacker, D_HT, self._DrGBaseAllyDamageTolerance[crea])
      end
    elseif self:IsEnemy(attacker) then
      self:OnDamagedByEnemy(attacker, dmg)
    elseif self:IsAfraidOf(attacker) then
      self:OnDamagedByAfraidOf(attacker, dmg)
    else self:OnDamagedByNeutral(attacker, dmg) end
    if res ~= true then
      if isnumber(res) then dmg:ScaleDamage(res) end
      local data = util.DrG_SaveDmg(dmg)
      self:CallInCoroutine(function(self, delay)
        dmg = util.DrG_LoadDmg(data)
        self:AfterTakeDamage(dmg, delay)
      end)
    else dmg:SetDamage(0) end
  end

  local function NextbotDeath(self, dmg)
    hook.Run("OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor())
    if self:HasWeapon() and self.DropWeaponOnDeath then
      self:DropWeapon()
    end
    if self.RagdollOnDeath then
      return self:BecomeRagdoll(dmg)
    else self:Remove() end
  end
  function ENT:OnKilled(dmg)
    if #self.OnDeathSounds > 0 then
      self:EmitSound(self.OnDeathSounds[math.random(#self.OnDeathSounds)])
    end
    if self:OnDeath(dmg) then
      self._DrGBaseCoroutineCalls = {}
      local data = util.DrG_SaveDmg(dmg)
      self:CallInCoroutine(function(self, delay)
        self:SetNW2Bool("DrGBaseDying", false)
        self:SetNW2Bool("DrGBaseDead", true)
        dmg = self:DoOnDeath(util.DrG_LoadDmg(data), delay)
        if dmg == nil then dmg = util.DrG_LoadDmg(data) end
        NextbotDeath(self, dmg)
      end)
      self:SetNW2Bool("DrGBaseDying", true)
      self:UpdateBehaviourTree()
    else
      self:SetNW2Bool("DrGBaseDead", true)
      NextbotDeath(self, dmg)
    end
  end

  function ENT:OnContact(ent)
    self:SetNW2Entity("DrGBaseLastTouchedEntity", ent)
    if CurTime() < self._DrGBaseOnContactDelay then return end
    self._DrGBaseOnContactDelay = CurTime() + 0.2
    if ent:GetClass() == "prop_combine_ball" then
      if not self:OnCombineBall(ent) then
        local dmg = DamageInfo()
        dmg:SetAttacker(ent:GetOwner())
        dmg:SetInflictor(ent)
        dmg:SetDamage(self:Health())
        dmg:SetDamageType(DMG_DISSOLVE)
        self:TakeDamageInfo(dmg)
      end
    elseif ent:GetClass() == "replicator_melon" and
    GetConVar("repmelon_target_npc"):GetInt() == 1 then
      ent:Replicate(self)
      self:Remove()
    else
      self:OnContactAny(ent)
      if not ent:IsWorld() and IsValid(ent:GetPhysicsObject()) then
        self:OnPhysContact(ent, ent:GetPhysicsObject())
      end
      local disp = self:GetRelationship(ent)
      if disp == D_LI then self:OnAllyContact(ent)
      elseif disp == D_HT then self:OnEnemyContact(ent)
      elseif disp == D_FR then self:OnAfraidOfContact(ent)
      elseif disp == D_NU then self:OnNeutralContact(ent)
      end
      if ent:IsPlayer() then self:OnPlayerContact(ent)
      elseif ent:IsNPC() then self:OnNPCContact(ent)
      elseif ent.Type == "nextbot" then self:OnNextbotContact(ent)
      elseif ent:IsWeapon() then self:OnWeaponContact(ent)
      elseif ent:IsVehicle() then self:OnVehicleContact(ent)
      elseif ent:GetClass() == "prop_physics" then self:OnPropContact(ent)
      elseif ent:IsRagdoll() then self:OnRagdollContact(ent)
      elseif ent:IsWorld() then self:OnWorldContact(ent)
      else self:OnOtherContact(ent) end
    end
  end

  hook.Add("vFireEntityStartedBurning", "DrGBaseOnIgniteVFire", function(ent)
    if ent.IsDrGNextbot then ent:OnIgnite() end
  end)

end
