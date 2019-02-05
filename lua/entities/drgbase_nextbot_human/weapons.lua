
ENT.ShootAnimations = {
  ["normal"] = ACT_HL2MP_GESTURE_RANGE_ATTACK,
  ["ar2"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
  ["camera"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_CAMERA,
  ["crossbow"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW,
  ["duel"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_DUEL,
  ["fist"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
  ["knife"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE,
  ["magic"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_MAGIC,
  ["melee2"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
  ["passive"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PASSIVE,
  ["physgun"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN,
  ["revolver"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
  ["rpg"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG,
  ["shotgun"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,
  ["smg"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1,
  ["grenade"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE,
  ["melee"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
  ["pistol"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
  ["slam"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM
}

ENT.ReloadAnimations = {
  ["normal"] = ACT_HL2MP_GESTURE_RELOAD,
  ["ar2"] = ACT_HL2MP_GESTURE_RELOAD_AR2,
  ["camera"] = ACT_HL2MP_GESTURE_RELOAD_CAMERA,
  ["crossbow"] = ACT_HL2MP_GESTURE_RELOAD_CROSSBOW,
  ["duel"] = ACT_HL2MP_GESTURE_RELOAD_DUEL,
  ["fist"] = ACT_HL2MP_GESTURE_RELOAD_FIST,
  ["knife"] = ACT_HL2MP_GESTURE_RELOAD_KNIFE,
  ["magic"] = ACT_HL2MP_GESTURE_RELOAD_MAGIC,
  ["melee2"] = ACT_HL2MP_GESTURE_RELOAD_MELEE2,
  ["passive"] = ACT_HL2MP_GESTURE_RELOAD_PASSIVE,
  ["physgun"] = ACT_HL2MP_GESTURE_RELOAD_PHYSGUN,
  ["revolver"] = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,
  ["rpg"] = ACT_HL2MP_GESTURE_RELOAD_RPG,
  ["shotgun"] = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
  ["smg"] = ACT_HL2MP_GESTURE_RELOAD_SMG1,
  ["grenade"] = ACT_HL2MP_GESTURE_RELOAD_GRENADE,
  ["melee"] = ACT_HL2MP_GESTURE_RELOAD_MELEE,
  ["pistol"] = ACT_HL2MP_GESTURE_RELOAD_PISTOL,
  ["slam"] = ACT_HL2MP_GESTURE_RELOAD_SLAM
}

if SERVER then

  function ENT:WeaponPrimary()
    if not self:HasWeapon() then return false end
    if self:HideWeapon() then return false end
    local wep = self:GetWeapon()
    if CurTime() < wep:GetNextPrimaryFire() then return false end
    if self._DrGBaseReloading then return false end
    if wep:CanPrimaryAttack() then
      self:PlayAnimation(self.ShootAnimations[wep:GetHoldType()])
      wep:PrimaryAttack()
      return true
    else
      self:WeaponReload()
      return false
    end
  end

  function ENT:WeaponSecondary()
    if not self:HasWeapon() then return false end
    if self:HideWeapon() then return false end
    local wep = self:GetWeapon()
    if wep.IsDrGWeapon and not wep.Secondary.Enabled then return false end
    if CurTime() < wep:GetNextSecondaryFire() then return false end
    if self._DrGBaseReloading then return false end
    if wep:CanSecondaryAttack() then
      self:PlayAnimation(self.ShootAnimations[wep:GetHoldType()])
      wep:SecondaryAttack()
      return true
    else
      self:WeaponReload()
      return false
    end
  end

  function ENT:WeaponReload()
    if not self:HasWeapon() then return end
    if self:HideWeapon() then return end
    local wep = self:GetWeapon()
    if self._DrGBaseReloading then return end
    self._DrGBaseReloading = true
    self:Timer(self:PlayAnimation(self.ReloadAnimations[wep:GetHoldType()]) or 0, function()
      self._DrGBaseReloading = false
      if not self:HasWeapon() then return end
      wep:SetClip1(wep:GetMaxClip1())
      wep:SetClip2(wep:GetMaxClip2())
    end)
  end

end
