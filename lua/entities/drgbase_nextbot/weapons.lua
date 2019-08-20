
-- Getters/setters --

function ENT:GetActiveWeapon()
  return self:GetNW2Entity("DrGBaseWeapon")
end
function ENT:GetWeapon(class)
  if isstring(class) then
    return self._DrGBaseWeapons[class] or NULL
  else return self:GetActiveWeapon() end
end
function ENT:HasWeapon(class)
  return IsValid(self:GetWeapon(class))
end
function ENT:HaveWeapon(class)
  return self:HasWeapon(class)
end

function ENT:GetWeapons()
  return table.DrG_Copy(self._DrGBaseWeapons)
end
function ENT:GetWeaponCount()
  local count = 0
  for class, weapon in pairs(self._DrGBaseWeapons) do
    if IsValid(weapon) then count = count+1 end
  end
  return count
end

function ENT:IsReloadingWeapon()
  if not self:HasWeapon() then return false end
  return self:GetNW2Bool("DrGBaseReloadWeapon")
end

function ENT:GetShootPos(class)
  if self:HasWeapon(class) then
    local weapon = self:GetWeapon(class)
    for boneId = 0, (weapon:GetBoneCount()-1) do
      local boneName = weapon:GetBoneName(boneId)
      local lookedUp = self:LookupBone(boneName)
      if lookedUp then
        local bonepos = self:GetBonePosition(lookedUp)
        return bonepos
      end
    end
  else return self:GetPos() end
end
function ENT:GetAimVector(class)
  if self:IsPossessed() then
    local lockedOn = self:PossessionGetLockedOn()
    if IsValid(lockedOn) then
      local aimAt = self:OnAimAtEntity(lockedOn) or lockedOn:WorldSpaceCenter()
      return self:GetShootPos(class):DrG_Direction(aimAt):GetNormalized()
    else return self:GetShootPos(class):DrG_Direction(self:PossessorTrace().HitPos):GetNormalized() end
  elseif self:HasEnemy() then
    local enemy = self:GetEnemy()
    local aimAt = self:OnAimAtEntity(enemy) or enemy:WorldSpaceCenter()
    return self:GetShootPos(class):DrG_Direction(aimAt):GetNormalized()
  else return self:EyeAngles():Forward() end
end

-- Functions --

-- Hooks --

function ENT:OnWeaponChange() end
function ENT:OnPickupWeapon() end
function ENT:OnDropWeapon() end
function ENT:OnAimAtEntity() end

-- Handlers --

function ENT:_InitWeapons()
  self._DrGBaseWeapons = {}
  self:SetNW2VarProxy("DrGBaseWeapon", function(self, name, old, new)
    self:OnWeaponChange(old, new)
  end)
  if CLIENT then return end
  if self.UseWeapons then
    for i, class in ipairs(self.Weapons) do
      self:GiveWeapon(class)
    end
    self:RandomWeapon()
  end
end

if SERVER then

  -- Misc --

  local function IsWeapon(ent)
    return isentity(ent) and IsValid(ent) and ent:IsWeapon()
  end

  -- Getters/setters --

  function ENT:SetActiveWeapon(weapon)
    if not IsWeapon(weapon) then return false end
    if self._DrGBaseWeapons[weapon:GetClass()] ~= weapon then return false end
    local active = self:GetActiveWeapon()
    if IsValid(active) then active:SetNoDraw(true) end
    weapon:SetNoDraw(false)
    self:SetNW2Entity("DrGBaseWeapon", weapon)
    return true
  end

  function ENT:GetWeaponPrimaryAmmo(class)
    if not self:HasWeapon(class) then return 0 end
    local wep = self:GetWeapon(class)
    if wep:GetMaxClip1() > 0 then return wep:Clip1()
    elseif wep:GetPrimaryAmmoType() > -1 then
      return -1
    else return math.huge end
  end
  function ENT:GetWeaponSecondaryAmmo(class)
    if not self:HasWeapon(class) then return 0 end
    local wep = self:GetWeapon(class)
    if wep:GetMaxClip2() > 0 then return wep:Clip2()
    elseif wep:GetSecondaryAmmoType() > -1 then
      return -1
    else return math.huge end
  end

  function ENT:IsWeaponPrimaryFull(class)
    if not self:HasWeapon(class) then return false end
    local ammo = self:GetWeaponPrimaryAmmo(class)
    if ammo == math.huge or ammo == -1 then return true end
    return ammo >= self:GetWeapon(class):GetMaxClip1()
  end
  function ENT:IsWeaponPrimaryEmpty(class)
    if not self:HasWeapon(class) then return true end
    local ammo = self:GetWeaponPrimaryAmmo(class)
    if ammo == -1 then return false end
    return ammo <= 0
  end

  function ENT:IsWeaponSecondaryFull(class)
    if not self:HasWeapon(class) then return false end
    local ammo = self:GetWeaponSecondaryAmmo(class)
    if ammo == math.huge or ammo == -1 then return true end
    return ammo >= self:GetWeapon(class):GetMaxClip2()
  end
  function ENT:IsWeaponSecondaryEmpty(class)
    if not self:HasWeapon(class) then return true end
    local ammo = self:GetWeaponSecondaryAmmo(class)
    if ammo == -1 then return false end
    return ammo <= 0
  end

  function ENT:IsWeaponFull(class)
    return self:IsWeaponPrimaryFull(class) and self:IsWeaponSecondaryFull(class)
  end
  function ENT:IsWeaponEmpty(class)
    return self:IsWeaponPrimaryEmpty(class) and self:IsWeaponSecondaryEmpty(class)
  end

  -- Functions --

  function ENT:GiveWeapon(class)
    if not self:HasWeapon(class) then
      local weapon = ents.Create(class)
      if not IsValid(weapon) then return NULL end
      if IsWeapon(weapon) then
        weapon:Spawn()
        if not self:PickupWeapon(weapon) then
          weapon:Remove()
          return NULL
        else return weapon end
      else
        weapon:Remove()
        return NULL
      end
    else return self:GetWeapon(class) end
  end
  function ENT:PickupWeapon(weapon)
    if not IsWeapon(weapon) then return false end
    if self:HasWeapon(weapon:GetClass()) then return false end
    weapon:SetMoveType(MOVETYPE_NONE)
    weapon:SetOwner(self)
  	weapon:SetParent(self)
  	weapon:AddEffects(EF_BONEMERGE)
    self._DrGBaseWeapons[weapon:GetClass()] = weapon
    self:OnPickupWeapon(weapon, weapon:GetClass())
    self:NetMessage("DrGBasePickupWeapon", weapon)
    if IsValid(self:GetActiveWeapon()) then
      weapon:SetNoDraw(true)
    else self:SetActiveWeapon(weapon) end
    return true
  end

  function ENT:RemoveWeapon(weapon)
    weapon = self:DropWeapon(weapon or self:GetActiveWeapon())
    if IsValid(weapon) then
      weapon:Remove()
      return weapon
    else return NULL end
  end
  function ENT:DropWeapon(weapon)
    if weapon == nil then weapon = self:GetActiveWeapon() end
    if isstring(weapon) then weapon = self:GetWeapon(weapon) end
    if not IsWeapon(weapon) then return NULL end
    if self._DrGBaseWeapons[weapon:GetClass()] ~= weapon then return NULL end
    local active = self:GetActiveWeapon()
    weapon:SetOwner(NULL)
    weapon:SetParent(NULL)
    weapon:RemoveEffects(EF_BONEMERGE)
    weapon:SetMoveType(MOVETYPE_VPHYSICS)
    weapon:SetPos(self:WorldSpaceCenter())
    self._DrGBaseWeapons[weapon:GetClass()] = nil
    self:OnDropWeapon(weapon, weapon:GetClass())
    self:NetMessage("DrGBaseDropWeapon", weapon:GetClass())
    if active == weapon then self:SwitchWeapon() end
    weapon:SetNoDraw(false)
    return weapon
  end

  function ENT:SelectWeapon(class)
    local weapon = self:GetWeapon(class)
    if not IsValid(weapon) then return NULL end
    self:SetActiveWeapon(weapon)
    return weapon
  end
  function ENT:SwitchWeapon()
    local weapon = table.DrG_Fetch(self._DrGBaseWeapons, function(weap1, weap2)
      if not IsValid(weap1) then return false end
      if not IsValid(weap2) then return true end
      local res = self:OnSwitchWeapon(weap1, weap2)
      if isbool(res) then return res end
      return weap1:GetWeight() > weap2:GetWeight()
    end)
    if not IsValid(weapon) then return NULL end
    self:SetActiveWeapon(weapon)
    return weapon
  end
  function ENT:RandomWeapon()
    local weapons = {}
    for class, weapon in pairs(self._DrGBaseWeapons) do
      if IsValid(weapon) then table.insert(weapons, weapon) end
    end
    if #weapons > 0 then
      local weapon = weapons[math.random(#weapons)]
      self:SetActiveWeapon(weapon)
      return weapon
    else return NULL end
  end

  -- Shoot/reload
  local SUPPORTED_GUNS = {
    ["weapon_ar2"] = {
      Bullet = {Damage = 8, TracerName = "AR2Tracer", Spread = Vector(0.020, 0.020, 0)},
      Sound = "Weapon_AR2.Single", Empty = "Weapon_AR2.Empty",
      Delay = 0.1, Cost = 1
    },
    ["weapon_smg1"] = {
      Bullet = {Damage = 4, Spread = Vector(0.035, 0.035, 0)},
      Sound = "Weapon_SMG1.Single", Empty = "Weapon_SMG1.Empty",
      Delay = 0.065, Cost = 1
    }
  }
  local function UseToolgun(self, weapon, tr)
    if IsValid(tr.Entity) then
      local ent = tr.Entity
      local res = self:OnUseToolgun(ent, tr)
      if not isbool(res) then
        local rand = math.random(6)
        if rand == 1 then
          ent:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
        elseif rand == 2 then
          local materials = list.Get("OverrideMaterials")
          ent:SetMaterial(materials[math.random(#materials)])
        elseif rand == 3 then
          local fx = EffectData()
          fx:SetOrigin(ent:GetPos())
          fx:SetEntity(ent)
          util.Effect("entity_remove", fx, true, true)
          if ent:IsPlayer() then ent:KillSilent()
          else SafeRemoveEntity(ent) end
        elseif rand == 4 then
          local dmg = DamageInfo()
          dmg:SetDamage(math.random(1, ent:Health()))
          dmg:SetAttacker(self)
          dmg:SetInflictor(weapon)
          ent:DispatchTraceAttack(dmg, tr)
        elseif rand == 5 then
          ent:SetHealth(math.min(ent:Health() + math.random(1, ent:GetMaxHealth()), ent:GetMaxHealth()))
        elseif rand == 6 then
          local scale = math.Rand(0.1, 2)
          if ent.IsDrGNextbot then ent:Scale(scale, 0.1)
          else ent:SetModelScale(ent:GetModelScale()*scale, 0.1) end
        elseif rand == 7 then

        end
        return true
      else return res end
    else return false end
  end
  function ENT:WeaponPrimaryFire(anim)
    if not self:HasWeapon() then return false end
    if self:IsReloadingWeapon() then return false end
    local weapon = self:GetWeapon()
    if weapon:GetClass() == "gmod_tool" then
      if not weapon._DrGBaseLastShoot or CurTime() > weapon._DrGBaseLastShoot + 1.25 then
        weapon._DrGBaseLastShoot = CurTime()
        local shootPos = self:GetShootPos()
        local tr = util.DrG_TraceLine({
          start = shootPos, endpos = shootPos+self:GetAimVector()*99999,
          filter = {self, weapon, self:GetPossessor()}
        })
        if UseToolgun(self, weapon, tr) then
          weapon:DoShootEffect(tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, true)
          self:PlayAnimation(anim)
        end
        return true
      else return false end
    elseif SUPPORTED_GUNS[weapon:GetClass()] then
      if weapon:Clip1() > weapon:GetMaxClip1() then weapon:SetClip1(weapon:GetMaxClip1()) end
      local data = SUPPORTED_GUNS[weapon:GetClass()]
      if not weapon._DrGBaseLastShoot or CurTime() > weapon._DrGBaseLastShoot + data.Delay then
        weapon._DrGBaseLastShoot = CurTime()
        if weapon:Clip1() > 0 then
          self:PlayAnimation(anim)
          weapon:EmitSound(data.Sound)
          data.Bullet.Src = self:GetShootPos()
          data.Bullet.Dir = self:GetAimVector()
          data.Bullet.Filter = {self, weapon, self:GetPossessor()}
          self:FireBullets(data.Bullet)
          weapon:SetClip1(weapon:Clip1() - data.Cost)
        else
          weapon:EmitSound(data.Empty)
          return false
        end
      else return false end
    elseif weapon:IsScripted() and not self:IsWeaponPrimaryEmpty() then
      if CurTime() < weapon:GetNextPrimaryFire() then return false end
      self:PlayAnimation(anim)
      weapon:PrimaryAttack()
    else return false end
    return true
  end
  function ENT:WeaponSecondaryFire(anim)
    if not self:HasWeapon() then return false end
    if self:IsReloadingWeapon() then return false end
    local weapon = self:GetWeapon()
    if wep:GetClass() == "weapon_ar2" then
      return true
    elseif wep:IsScripted() and not self:IsWeaponSecondaryEmpty() then
      if CurTime() < weapon:GetNextSecondaryFire() then return false end
      self:PlayAnimation(anim)
      weapon:SecondaryAttack()
    else return false end
    return true
  end
  function ENT:WeaponReload(anim)
    if not self:HasWeapon() then return false end
    if self:IsReloadingWeapon() then return false end
    local weapon = self:GetWeapon()
    self:SetNW2Bool("DrGBaseReloadWeapon", true)
    self:Timer(self:PlayAnimation(anim) or 0, function()
      self:SetNW2Bool("DrGBaseReloadWeapon", false)
      if not self:HasWeapon() then return end
      weapon = self:GetWeapon()
      if not self:IsWeaponPrimaryFull() then
        weapon:SetClip1(weapon:GetMaxClip1())
      end
      if not self:IsWeaponSecondaryFull() then
        weapon:SetClip2(weapon:GetMaxClip2())
      end
    end)
    return true
  end

  -- Hooks --

  function ENT:OnSwitchWeapon() end
  function ENT:OnUseToolgun() end

  -- Handlers --

  hook.Add("PlayerCanPickupWeapon", "DrGBaseNextbotWeaponDisablePickup", function(ply, weapon)
    local owner = weapon:GetOwner()
    if IsValid(owner) and owner.IsDrGNextbot then return false end
  end)

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
