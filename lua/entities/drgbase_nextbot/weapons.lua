
-- Getters/setters --

function ENT:GetWeapon()
  return self:GetNW2Entity("DrGBaseWeapon")
end
function ENT:HasWeapon()
  return IsValid(self:GetWeapon())
end
function ENT:HaveWeapon()
  return self:HasWeapon()
end
function ENT:IsWeaponHolstered()
  if not self:HasWeapon() then return false end
  return self:GetNW2Bool("DrGBaseWeaponHolstered")
end

-- Functions --

function ENT:GetShootPos()
  if not self:HasWeapon() then return self:GetPos()
  else
    local wep = self:GetWeapon()
    local attach = wep:LookupAttachment("muzzle")
    if attach <= 0 then return wep:GetPos()
    else return wep:GetAttachment(attach).Pos end
  end
end
function ENT:GetAimVector()
  local normal
  if self:IsPossessed() then
    return self:GetShootPos():DrG_Direction(self:PossessorTrace().HitPos)
  elseif self:HasEnemy() then
    return self:GetShootPos():DrG_Direction(self:GetEnemy():WorldSpaceCenter())
  else normal = self:GetForward() end
  local cap = 10
  local acc = math.Clamp((1 - self.WeaponAccuracy)*cap, 0, cap)
  normal:Rotate(Angle(math.random(-acc, acc), math.random(-acc, acc), 0))
  return normal
end

-- Hooks --

-- Handlers --

function ENT:_InitWeapons()
  if CLIENT then return end
  self._DrGBaseWeaponDropClass = ""
  if self.UseWeapons then
    --[[local convarName = "gmod_npcweapon"
    if ConVarExists(convarName) then
      local weapon = GetConVar(convarName):GetString()
      if weapon ~= "none" and weapon ~= "" and weapon == self.Equipment then
        self:GiveWeapon(weapon)
      elseif weapon == "" and #self.Weapons > 0 then
        self:GiveWeapon(self.Weapons[math.random(#self.Weapons)])
      end]]
    if isstring(self.Equipment) then
      self:GiveWeapon(self.Equipment)
    elseif #self.Weapons > 0 then
      self:GiveWeapon(self.Weapons[math.random(#self.Weapons)])
    end
  end
end

-- Compatibility --

function ENT:ViewPunch() end

if SERVER then

  local REPLACE_WEAPONS = {
    ["weapon_ar2"] = "weapon_drg_ar2"
  }

  -- Getters/setters --

  function ENT:IsReloading()
    return self._DrGBaseReloadingWeapon or false
  end

  function ENT:GetWeaponPrimaryAmmo()
    if not self:HasWeapon() then return 0 end
    local wep = self:GetWeapon()
    if wep:GetMaxClip1() > 0 then return wep:Clip1()
    elseif wep:GetPrimaryAmmoType() > -1 then
      return -1
    else return math.huge end
  end
  function ENT:GetWeaponSecondaryAmmo()
    if not self:HasWeapon() then return 0 end
    local wep = self:GetWeapon()
    if wep:GetMaxClip2() > 0 then return wep:Clip2()
    elseif wep:GetSecondaryAmmoType() > -1 then
      return -1
    else return math.huge end
  end

  function ENT:IsWeaponPrimaryFull()
    if not self:HasWeapon() then return false end
    local ammo = self:GetWeaponPrimaryAmmo()
    if ammo == math.huge or ammo == -1 then return true end
    return ammo >= self:GetWeapon():GetMaxClip1()
  end
  function ENT:IsWeaponPrimaryEmpty()
    if not self:HasWeapon() then return true end
    local ammo = self:GetWeaponPrimaryAmmo()
    if ammo == -1 then return false end
    return ammo <= 0
  end

  function ENT:IsWeaponSecondaryFull()
    if not self:HasWeapon() then return false end
    local ammo = self:GetWeaponSecondaryAmmo()
    if ammo == math.huge or ammo == -1 then return true end
    return ammo >= self:GetWeapon():GetMaxClip2()
  end
  function ENT:IsWeaponSecondaryEmpty()
    if not self:HasWeapon() then return true end
    local ammo = self:GetWeaponSecondaryAmmo()
    if ammo == -1 then return false end
    return ammo <= 0
  end

  -- Functions --

  function ENT:HolsterWeapon()
    if not self:HasWeapon() then return end
    self:SetNW2Bool("DrGBaseWeaponHolstered", true)
    self:OnHolsterWeapon(self:GetWeapon())
  end
  function ENT:UnholsterWeapon()
    if not self:HasWeapon() then return end
    self:SetNW2Bool("DrGBaseWeaponHolstered", false)
    self:OnUnholsterWeapon(self:GetWeapon())
  end
  function ENT:ToggleWeaponHolstered()
    if not self:HasWeapon() then return end
    if self:IsWeaponHolstered() then
      self:UnholsterWeapon()
    else self:HolsterWeapon() end
  end

  -- Pickup/drop weapon
  function ENT:GiveWeapon(class)
    if self:HasWeapon() then return false end
    local wep = ents.Create(REPLACE_WEAPONS[class] or class)
    if not IsValid(wep) then return false end
    wep:Spawn()
    if not self:PickupWeapon(wep, class) then
      wep:Remove()
      return false
    else return true, wep end
  end
  function ENT:PickupWeapon(wep, class)
    if self:HasWeapon() then return false end
    if not REPLACE_WEAPONS[wep:GetClass()] then
      if not IsValid(wep) or not wep:IsWeapon() then return false end
      if not self:CanPickupWeapon(wep) then return false end
      local attach = self:GetAttachment(self:LookupAttachment(self.WeaponAttachment))
      if attach == nil then return end
      self._DrGBaseWeaponDropClass = class or wep:GetClass()
      wep:SetPos(attach.Pos)
      wep:SetMoveType(MOVETYPE_NONE)
      wep:SetOwner(self)
    	wep:SetParent(self, self.WeaponAttachmentRH)
    	wep:AddEffects(EF_BONEMERGE)
      wep:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
      wep:SetClip1(wep:GetMaxClip1())
      wep:SetClip2(wep:GetMaxClip2())
      self:SetNW2Entity("DrGBaseWeapon", wep)
      self:UnholsterWeapon()
      self:OnPickupWeapon(wep)
      return true, wep
    else
      wep:Remove()
      return self:GiveWeapon(REPLACE_WEAPONS[wep:GetClass()])
    end
  end
  function ENT:DropWeapon()
    if not self:HasWeapon() then return false end
    if not self:CanDropWeapon(self:GetWeapon()) then return false end
    self:RemoveWeapon()
    local wep = ents.Create(self._DrGBaseWeaponDropClass)
    if not IsValid(wep) then return true, NULL end
    wep:SetPos(self:WorldSpaceCenter())
    self:OnDropWeapon(wep)
    return true, wep
  end
  function ENT:RemoveWeapon()
    if not self:HasWeapon() then return false end
    self:GetWeapon():Remove()
    self:SetNW2Entity("DrGBaseWeapon", nil)
    return true
  end

  -- Shoot/reload
  function ENT:WeaponPrimaryFire(anim)
    if not self:HasWeapon() then return false end
    if self:IsWeaponHolstered() then return false end
    if self:IsReloading() then return false end
    local wep = self:GetWeapon()
    if not isfunction(wep.PrimaryAttack) then return false end
    if CurTime() < wep:GetNextPrimaryFire() then return false end
    self:PlayAnimation(anim)
    wep:PrimaryAttack()
    return true
  end
  function ENT:WeaponSecondaryFire(anim)
    if not self:HasWeapon() then return false end
    if self:IsWeaponHolstered() then return false end
    if self:IsReloading() then return false end
    local wep = self:GetWeapon()
    if not isfunction(wep.SecondaryAttack) then return false end
    if CurTime() < wep:GetNextSecondaryFire() then return false end
    self:PlayAnimation(anim)
    wep:SecondaryAttack()
    return true
  end
  function ENT:WeaponReload(anim)
    if not self:HasWeapon() then return false end
    if self:IsReloading() then return false end
    local wep = self:GetWeapon()
    if not isfunction(wep.Reload) then return false end
    self._DrGBaseReloadingWeapon = true
    self:Timer(self:PlayAnimation(anim) or 0, function()
      self._DrGBaseReloadingWeapon = false
      if not self:HasWeapon() then return end
      wep = self:GetWeapon()
      wep:SetClip1(wep:GetMaxClip1())
      wep:SetClip2(wep:GetMaxClip2())
    end)
    return true
  end

  -- Hooks --

  function ENT:CanPickupWeapon() return true end
  function ENT:CanDropWeapon() return true end
  function ENT:OnPickupWeapon() end
  function ENT:OnDropWeapon() end
  function ENT:OnHolsterWeapon() end
  function ENT:OnUnholsterWeapon() end

  -- Handlers --

  hook.Add("PlayerCanPickupWeapon", "DrGBaseWeaponsPlayerPickup", function(ply, wep)
    if IsValid(wep:GetOwner()) and wep:GetOwner().IsDrGNextbot then return false end
  end)

  -- Compatibility --

  function ENT:LagCompensation() end

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

  -- Compatibility --

end
