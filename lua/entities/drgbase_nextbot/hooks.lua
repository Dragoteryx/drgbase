
if SERVER then
  util.AddNetworkString("DrGBaseNextbotOnHealthChange")

  function ENT:OnContact(ent)
    if CurTime() < self._DrGBaseOnContactDelay then return end
    self._DrGBaseOnContactDelay = CurTime() + 0.2
    self:_Debug("contact with '"..ent:GetClass().."' ("..ent:EntIndex()..").")
    if IsValid(ent) then self:SpotEntity(ent) end
    if ent:GetClass() == "prop_combine_ball" then
      local reaction = self:CombineBall()
      if reaction == "dissolve" then
        local dmg = DamageInfo()
        dmg:SetAttacker(ent:GetOwner())
        dmg:SetInflictor(ent)
        dmg:SetDamage(self:Health())
        dmg:SetDamageType(DMG_DISSOLVE)
        self:TakeDamageInfo(dmg)
      elseif reaction == "bounce" then
        DrGBase.Error("combine ball bouncing doesn't work.")
      elseif reaction == "explode" then
        ent:Fire("explode", 0)
      end
    elseif ent:GetClass() == "replicator_melon" and GetConVar("repmelon_target_npc"):GetInt() == 1 then
      ent:Replicate(self)
      self:Remove()
    else
      if self._DrGBaseCharging then
        self._DrGBaseChargingEnt = ent
      end
      if ent:IsPlayer() then self:OnPlayerContact(ent)
      elseif ent:IsNPC() then self:OnNPCContact(ent)
      elseif ent.Type == "nextbot" then self:OnNextbotContact(ent)
      elseif ent:GetClass() == "prop_physics" then
        self:OnPropContact(ent)
      elseif ent:GetClass() == "prop_dynamic" or
      ent:GetClass() == "func_door" or
      ent:GetClass() == "prop_door_rotating" then
        for _, door in pairs(ents.FindInSphere(ent:GetPos(), 20)) do
          if (door:GetClass() == "func_door" or
          door:GetClass() == "prop_door_rotating") then
            local res, delay, close = self:OnDoorContact(door)
            if res ~= "open" and res ~= "break" then continue end
            self:Timer(delay or 0, function()
              if not IsValid(door) then return end
              if res == "open" then
                door:Fire("open")
                if close ~= nil and close > 0 then
                  self:Timer(close, function()
                    if not IsValid(door) then return end
                    door:Fire("close")
                  end)
                end
              else
                if close ~= nil and close >= 0 then
                  local prop = ents.Create("prop_physics")
                  prop:SetModel(door:GetModel())
                  if door:GetSkin() then prop:SetSkin(door:GetSkin()) end
                  if door:GetModelScale() then prop:SetModelScale(door:GetModelScale()) end
                  prop:SetPos(door:GetPos())
                  prop:SetAngles(door:GetAngles())
                  door:Remove()
                  prop:Spawn()
                  prop:Activate()
                  prop:GetPhysicsObject():SetVelocity(self:GetForward()*close)
                else door:Remove() end
              end
            end)
          end
        end
      elseif ent:IsWorld() then self:OnWorldContact(ent)
      else self:OnOtherContact(ent) end
      self:OnContactAny(ent)
    end
  end
  function ENT:OnPlayerContact() end
  function ENT:OnNPCContact() end
  function ENT:OnNextbotContact() end
  function ENT:OnWeaponContact() end
  function ENT:OnPropContact() end
  function ENT:OnDoorContact() end
  function ENT:OnWorldContact() end
  function ENT:OnOtherContact() end
  function ENT:OnContactAny() end

  hook.Add("EntityTakeDamage", "DrGBaseNextbotDamage", function(ent, dmg)
    if not ent.IsDrGNextbot then return end
    if dmg:GetDamage() <= 0 then return true end
    local hitgroups, bone = ent:FetchHitGroups(dmg)
    local res = ent:OnTakeDamage(dmg, hitgroups, bone)
    if isnumber(res) then
      dmg:ScaleDamage(res)
    end
    if res ~= true then
      local data = DrGBase.Utils.ConvertDamage(dmg)
      ent:CallInCoroutine(function(delay)
        dmg = DrGBase.Utils.RecreateDamage(data)
        ent:AfterTakeDamage(dmg, hitgroups, bone, delay)
      end)
      ent:_Debug("take damage => "..dmg:GetDamage()..".")
    else return true end
  end)
  function ENT:OnTakeDamage() end
  function ENT:AfterTakeDamage() end

  local function NextbotDeath(self, dmg)
    if self:IsPossessed() and not self.PossessionRemote then
      self:GetPossessor():TakeDamageInfo(dmg)
    else hook.Run("OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor()) end
    if self.DropWeaponOnDeath then
      self:DropWeapon()
    end
    if self.RagdollOnDeath then
      self:BecomeRagdoll(dmg)
    else self:Remove() end
  end

  function ENT:OnKilled(dmg)
    local hitgroups, bone = self:FetchHitGroups(dmg)
    if self:OnDeath(dmg, hitgroups, bone) then
      self._DrGBaseCoroutineCallbacks = {}
      local data = DrGBase.Utils.ConvertDamage(dmg)
      self:CallInCoroutine(function(delay)
        dmg = DrGBase.Utils.RecreateDamage(data)
        self:SetDrGVar("DrGBaseDying", false)
        self:SetDrGVar("DrGBaseDead", true)
        self:DoOnDeath(dmg, hitgroups, bone, delay)
        NextbotDeath(self, dmg)
      end)
      self:SetDrGVar("DrGBaseDying", true)
    else
      self:SetDrGVar("DrGBaseDead", true)
      NextbotDeath(self, dmg)
    end
  end
  function ENT:OnDeath() end
  function ENT:DoOnDeath() end

  function ENT:OnStuck()
    if self:IsPossessed() then return end
    self:_Debug("stuck.")
  end

  function ENT:OnUnStuck()
    if self:IsPossessed() then return end
    self:_Debug("unstuck.")
  end

  function ENT:HandleStuck()
    if self:IsPossessed() then return end
    local pos = self:RandomPos(100)
    if pos ~= nil then self:SetPos(pos) end
    self:SetDestination(nil)
    self.loco:ClearStuck()
  end

  -- Handlers --
  function ENT:_HandleCustomHooks()
    -- OnExtinguish
    if not self:IsOnFire() and self._DrGBaseOnFire then
      self:OnExtinguish()
    end
    self._DrGBaseOnFire = self:IsOnFire()
    -- CustomOnLandOnGround
    if self:IsOnGround() and not self._DrGBaseOnGround then
      -- touch ground
      self:_Debug("touch ground.")
      self:_Debug("downwards velocity: "..self._DrGBaseDownwardsVelocity..".")
      self:InvalidatePath()
      if self._DrGBaseDownwardsVelocity > 0 and not self:IsFlying() and self.FallDamage then
        local val = self:OnFallDamage(self._DrGBaseDownwardsVelocity/self:GetScale(), self:WaterLevel()) or 0
        if val > 0 then
          local dmg = DamageInfo()
          dmg:SetDamage(val)
          dmg:SetDamageType(DMG_FALL)
          dmg:SetAttacker(self)
          self:TakeDamageInfo(dmg)
        end
      end
    elseif not self:IsOnGround() and self._DrGBaseOnGround then
      -- leave ground
      self:_Debug("leave ground.")
    end
    self._DrGBaseOnGround = self:IsOnGround()
    self._DrGBaseDownwardsVelocity = -self:GetVelocity().z
    -- OnHealthChange
    if self:Health() ~= self._DrGBaseHealth then
      self:_Debug("health change from "..self._DrGBaseHealth.." to "..self:Health()..".")
      self:OnHealthChange(self._DrGBaseHealth, self:Health())
      self:SetDrGVar("DrGBaseHealth", self:Health())
    end
    if self:GetMaxHealth() ~= self._DrGBaseMaxHealth then
      self:SetDrGVar("DrGBaseMaxHealth", self:GetMaxHealth())
    end
    self._DrGBaseHealth = self:Health()
  end
  function ENT:OnExtinguish() end
  function ENT:OnFallDamage(zvelocity, waterlevel)
    if waterlevel == 3 then return end
    if zvelocity > 700 then return zvelocity/20/(waterlevel+1) end
  end
  function ENT:OnHealthChange() end

else

  function ENT:OnHealthChange() end
  net.Receive("DrGBaseNextbotOnHealthChange", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    local oldhealth = net.ReadFloat()
    local newhealth = net.ReadFloat()
    ent:SetHealth(newhealth)
    if ent.OnHealthChange ~= nil then ent:OnHealthChange(oldhealth, newhealth) end
  end)

end
