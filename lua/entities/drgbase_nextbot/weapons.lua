
function ENT:HasWeapon()
  return IsValid(self:GetWeapon())
end

function ENT:GetWeapon()
  return self:GetDrGVar("DrGBaseWeapon")
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
    if wepReplace[wep:GetClass()] ~= nil then
      self:GiveWeapon(wep:GetClass())
      wep:Remove()
    elseif self:OnPickupWeapon(wep) ~= false then
      wep:SetPos(self:GetAttachment(self:LookupAttachment(self.WeaponAttachmentRH)).Pos)
      wep:SetMoveType(MOVETYPE_NONE)
      wep:SetOwner(self)
    	wep:SetParent(self, self.WeaponAttachmentRH)
    	wep:AddEffects(EF_BONEMERGE)
      wep:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
      wep:SetClip1(wep:GetMaxClip1())
      wep:SetClip2(wep:GetMaxClip2())
      self:SetDrGVar("DrGBaseWeapon", wep)
    end
  end
  function ENT:OnPickupWeapon() end

  function ENT:GiveWeapon(name)
    if not self.UseWeapons then return end
    if IsValid(self:GetActiveWeapon()) then return end
    local wep = ents.Create(wepReplace[name] or name)
    if not IsValid(wep) then return end
    if wepReplace[name] ~= nil then
      wep._DrGBaseWeaponDropReplace = name
    end
    wep:Spawn()
    self:PickupWeapon(wep)
    return wep
  end

  function ENT:DropWeapon()
    if not self:HasWeapon() then return end
    if self:IsDead() or self:OnDropWeapon(self:GetWeapon()) ~= false then
      local class = self:GetWeapon()._DrGBaseWeaponDropReplace or self:GetWeapon():GetClass()
      local pos = self:GetWeapon():GetPos()
      self:RemoveWeapon()
      local wep = ents.Create(class)
      if not IsValid(wep) then return end
      wep:SetPos(pos)
      wep:Spawn()
    end
  end
  function ENT:OnDropWeapon() end

  function ENT:RemoveWeapon()
    if not self:HasWeapon() then return end
    self:GetWeapon():Remove()
    self:SetDrGVar("DrGBaseWeapon", nil)
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
