
function ENT:IsWeaponReady()
  return self:HasWeapon() and self:GetDrGVar("DrGBaseWeaponReady")
end

function ENT:HideWeapon(bool)
  if not self:HasWeapon() then return end
  local wep = self:GetWeapon()
  if bool == nil then return wep:GetNoDraw()
  elseif bool then wep:SetNoDraw(true)
  else wep:SetNoDraw(false) end
end

if SERVER then

  function ENT:ToggleWeaponReady(bool)
    if bool == nil then self:ToggleWeaponReady(not self:IsWeaponReady())
    elseif bool then self:SetDrGVar("DrGBaseWeaponReady", true)
    else self:SetDrGVar("DrGBaseWeaponReady", false) end
  end

  function ENT:ThrowGrenade(pos, class, callback)
    if CurTime() < self._DrGBaseGrenadeThrowDelay then return end
    if self._DrGBaseThrowingGrenade then return end
    self._DrGBaseGrenadeThrowDelay = CurTime() + self.GrenadeThrowDelay
    self._DrGBaseThrowingGrenade = true
    if callback == nil then callback = self.GrenadeCallback end
    local duration = self:SequenceDuration(self:LookupSequence("gesture_item_throw"))
    local hide = self:HideWeapon()
    self:HideWeapon(true)
    self:PlayAnimation("gesture_item_throw", 1, function()
      self._DrGBaseThrowingGrenade = false
      self:HideWeapon(hide)
    end)
    self:Timer(duration/2, function()
      if self:IsDying() then return end
      local bone = self:LookupBone("ValveBiped.Bip01_L_Hand")
      if bone == nil then return end
      local grenadepos = self:GetBonePosition(bone)
      local grenade = ents.Create(class or self.GrenadeClass)
      if not IsValid(grenade) then return end
      local res = callback(grenade, true)
      if res ~= nil then grenade = res end
      grenade:SetPos(grenadepos)
      grenade:Spawn()
      grenade:Activate()
      callback(grenade, false)
      local phys = grenade:GetPhysicsObject()
      if self:IsPossessed() and pos == nil then pos = self:PossessorTrace().HitPos end
      phys:DrG_ParabolicTrajectory(pos, {maxmagnitude = self.MaxGrenadeThrow*self:GetScale()})
    end)
  end

else



end
