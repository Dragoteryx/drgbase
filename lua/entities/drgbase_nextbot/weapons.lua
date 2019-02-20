
function ENT:HasWeapon()
  return IsValid(self:GetWeapon())
end
function ENT:HaveWeapon()
  return self:HasWeapon()
end

function ENT:GetWeapon()
  return self:GetDrGVar("DrGBaseWeapon")
end

function ENT:HideWeapon(bool)
  if not self:HasWeapon() then return false end
  local wep = self:GetWeapon()
  if bool == nil then return wep:GetNoDraw()
  elseif bool then wep:SetNoDraw(true)
  else wep:SetNoDraw(false) end
end

function ENT:IsWeaponReady()
  return self:HasWeapon() and not self:HideWeapon() and self:GetDrGVar("DrGBaseWeaponReady")
end

-- Used for shooting --

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
    normal = util.TraceLine({
      start = self:GetShootPos(),
      endpos = self:PossessorTrace().HitPos,
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    }).Normal
  elseif self:HaveEnemy() then
    normal = util.TraceLine({
      start = self:GetShootPos(),
      endpos = self:GetEnemy():WorldSpaceCenter(),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    }).Normal
  else normal = self:GetForward() end
  local cap = 10
  local accuracy = (1 - self.WeaponAccuracy)*cap
  if accuracy < 0 then accuracy = 0 end
  if accuracy > cap then accuracy = cap end
  normal:Rotate(Angle(math.random(-accuracy, accuracy), math.random(-accuracy, accuracy), 0))
  return normal
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

  local wepReplace = {
    ["weapon_ar2"] = "weapon_drg_ar2"
  }

  function ENT:PickupWeapon(wep)
    local class = wep:GetClass()
    if wepReplace[class] then
      wep:Remove()
      return self:GiveWeapon(class)
    elseif self:OnPickupWeapon(wep) ~= false then
      local attach = self:GetAttachment(self:LookupAttachment(self.WeaponAttachmentRH))
      if attach == nil then return end
      wep:SetPos(attach.Pos)
      wep:SetMoveType(MOVETYPE_NONE)
      wep:SetOwner(self)
    	wep:SetParent(self, self.WeaponAttachmentRH)
    	wep:AddEffects(EF_BONEMERGE)
      wep:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
      wep:SetClip1(wep:GetMaxClip1())
      wep:SetClip2(wep:GetMaxClip2())
      self:SetDrGVar("DrGBaseWeapon", wep)
      return wep
    end
  end
  function ENT:OnPickupWeapon() end

  function ENT:GiveWeapon(class)
    if not self.UseWeapons then return end
    if self:HasWeapon() then return end
    local wep = ents.Create(wepReplace[class] or class)
    if not IsValid(wep) then return end
    if wepReplace[class] then
      wep._DrGBaseWeaponDropReplace = class
    end
    wep:Spawn()
    if self:PickupWeapon(wep) then return wep
    else wep:Remove() end
  end

  function ENT:DropWeapon()
    if not self:HasWeapon() then return end
    if self:OnDropWeapon(self:GetWeapon()) ~= false or self:IsDead() then
      local class = self:GetWeapon()._DrGBaseWeaponDropReplace or self:GetWeapon():GetClass()
      local pos = self:GetWeapon():GetPos()
      self:RemoveWeapon()
      local wep = ents.Create(class)
      if not IsValid(wep) then return end
      wep:SetPos(pos)
      wep:Spawn()
      return wep
    end
  end
  function ENT:OnDropWeapon() end

  function ENT:RemoveWeapon()
    if not self:HasWeapon() then return end
    self:GetWeapon():Remove()
    self:SetDrGVar("DrGBaseWeapon", nil)
  end

  function ENT:ToggleWeaponReady(bool)
    if bool == nil then self:ToggleWeaponReady(not self:IsWeaponReady())
    elseif bool then self:SetDrGVar("DrGBaseWeaponReady", true)
    else self:SetDrGVar("DrGBaseWeaponReady", false) end
  end

  -- Use weapons --

  function ENT:CanWeaponPrimary()
    if self._DrGBaseReloading then return false end
    if not self:IsWeaponReady() then return false end
    local wep = self:GetWeapon()
    if CurTime() < wep:GetNextPrimaryFire() then return false end
    if not wep:CanPrimaryAttack() then return false end
    return true
  end

  function ENT:WeaponPrimary(anim)
    if self:CanWeaponPrimary() then
      local wep = self:GetWeapon()
      self:PlayAnimation(anim)
      wep:PrimaryAttack()
      return wep:CanPrimaryAttack()
    else return false end
  end

  function ENT:CanWeaponSecondary()
    if self._DrGBaseReloading then return false end
    if not self:IsWeaponReady() then return false end
    local wep = self:GetWeapon()
    if wep.IsDrGWeapon and not wep.Secondary.Enabled then return false end
    if CurTime() < wep:GetNextSecondaryFire() then return false end
    if not wep:CanSecondaryAttack() then return false end
    return true
  end

  function ENT:WeaponSecondary(anim)
    if self:CanWeaponSecondary() then
      self:PlayAnimation(anim)
      wep:SecondaryAttack()
      return wep:CanSecondaryAttack()
    else return false end
  end

  function ENT:WeaponReload(anim)
    if self._DrGBaseReloading then return end
    if not self:HasWeapon() then return end
    if self:HideWeapon() then return end
    local wep = self:GetWeapon()
    self._DrGBaseReloading = true
    self:Timer(self:PlayAnimation(anim) or 0, function()
      self._DrGBaseReloading = false
      if not self:HasWeapon() then return end
      wep = self:GetWeapon()
      wep:SetClip1(wep:GetMaxClip1())
      wep:SetClip2(wep:GetMaxClip2())
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

end

-- Compatibility -- (because nextbots aren't supposed to use weapons)

function ENT:ViewPunch() end

if SERVER then

  function ENT:LagCompensation() end

else



end
