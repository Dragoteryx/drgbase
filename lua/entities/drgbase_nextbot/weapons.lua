
DRGBASE_WEAPON_AR2 = "drgbase_ar2"

function ENT:HasWeapon()
  return IsValid(self:GetWeapon())
end

function ENT:GetWeapon()
  return self:GetDrGVar("DrGBaseWeapon")
end

-- Used for shooting --

function ENT:GetShootPos()
  if not self:HasWeapon() then return self:GetPos()
  else return self:GetWeapon():GetPos() end
end
function ENT:GetAimVector()
  if self:IsPossessed() then
    return util.TraceLine({
      start = self:GetShootPos(),
      endpos = self:PossessorTrace().HitPos,
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    }).Normal
  elseif self:HaveEnemy() then
    return util.TraceLine({
      start = self:GetShootPos(),
      endpos = self:GetEnemy():WorldSpaceCenter(),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    }).Normal
  else return self:GetForward() end
end

-- Ammo --

function ENT:GetAmmoCount()
  return math.huge
end
function ENT:GiveAmmo() end
function ENT:RemoveAllAmmo() end
function ENT:RemoveAmmo() end
function ENT:SetAmmo() end
function ENT:StripAmmo() end

-- Aliases --

function ENT:GetActiveWeapon()
  return self:GetWeapon()
end

if SERVER then

  function ENT:PickupWeapon(wep)
    wep:SetPos(self:GetAttachment(self:LookupAttachment(self.WeaponAttachmentRH)).Pos)
    wep:SetMoveType(MOVETYPE_NONE)
    wep:SetOwner(self)
  	wep:SetParent(self, self.WeaponAttachmentRH)
  	wep:AddEffects(EF_BONEMERGE)
    wep:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    self:SetDrGVar("DrGBaseWeapon", wep)
  end

  function ENT:GiveWeapon(name)
    if not self.UseWeapons then return end
    if IsValid(self:GetActiveWeapon()) then return end
    local wep = ents.Create(name)
    if not IsValid(wep) then return end
    wep:Spawn()
    self:PickupWeapon(wep)
    return wep
  end

  function ENT:DropWeapon()
    if not self:HasWeapon() then return end
    local class = self:GetWeapon():GetClass()
    local pos = self:GetWeapon():GetPos()
    self:RemoveWeapon()
    local wep = ents.Create(class)
    if not IsValid(wep) then return end
    wep:SetPos(pos)
    wep:Spawn()
  end

  function ENT:RemoveWeapon()
    if not self:HasWeapon() then return end
    self:GetWeapon():Remove()
    self:SetDrGVar("DrGBaseWeapon", nil)
  end

  function ENT:WeaponPrimary()
    if not self:HasWeapon() then return false end
    if CurTime() < self:GetWeapon():GetNextPrimaryFire() then return false end
    if self._DrGBaseReloading then return false end
    if self:GetWeapon():CanPrimaryAttack() then
      self:GetWeapon():PrimaryAttack()
      return true
    else
      self:WeaponReload()
      return false
    end
  end

  function ENT:WeaponReload()
    if not self:HasWeapon() then return end
    if self._DrGBaseReloading then return end
    self._DrGBaseReloading = true
    local holdtype = self:GetWeapon():GetHoldType()
    if holdtype == "smg" then holdtype = "smg1" end
    self:Timer(self:PlayGesture("reload_"..holdtype) or 0, function()
      self._DrGBaseReloading = false
      if not self:HasWeapon() then return end
      self:GetWeapon():SetClip1(self:GetWeapon():GetMaxClip1())
    end)
  end

  -- Hooks --

  hook.Add("PlayerCanPickupWeapon", "DrGBaseWeaponsPlayerPickup", function(ply, wep)
    if IsValid(wep:GetOwner()) and wep:GetOwner().IsDrGNextbot then return false end
  end)

  -- Aliases --

  function ENT:Give(name)
    return self:GiveWeapon(name)
  end

else



end

-- Compatibility -- (because nextbots aren't supposed to use weapons)

  function ENT:ViewPunch() end
  function ENT:IsBot() return true end

if SERVER then

  function ENT:LagCompensation() end

else



end
