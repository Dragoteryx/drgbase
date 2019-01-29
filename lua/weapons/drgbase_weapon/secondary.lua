
function SWEP:CanSecondaryAttack()
  if not self.Secondary.Enabled then return false end
  if self:GetSecondaryAmmoType() < 0 then return true end
  if self.Secondary.Ammo == -1 then return true end
  if self.Secondary.ClipSize > 0 then
    return self.Weapon:Clip2() >= self.Secondary.Cost
  else return self.Owner:GetAmmoCount(self.Secondary.Ammo) >= self.Secondary.Cost end
end
function SWEP:TriedToSecondaryAttack()
  self:EmitSound(self.Secondary.EmptySound)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Cooldown)
end
function SWEP:SecondaryAttack()
  if CLIENT then return end
  if not self.Secondary.Enabled then return false end
  if not self:CanSecondaryAttack() then
    self:TriedToSecondaryAttack()
    return false
  end
  if self:PreSecondaryAttack() == false then return false end
	self:EmitSound(self.Secondary.Sound)
  self.Owner:ViewPunch(self.Secondary.ViewPunch)
	self:FireSecondary()
	self:TakeSecondaryAmmo(self.Secondary.Cost)
  if self.Secondary.Cooldown >= 0 then
    local delay = CurTime() + self.Secondary.Cooldown
    self:SetNextSecondaryFire(delay)
    self:PostSecondaryAttack(delay)
  else self:PostSecondaryAttack(CurTime()) end
  return true
end
function SWEP:PreSecondaryAttack() end
function SWEP:FireSecondary()
  self:ShootBullet(self.Secondary.Damage, self.Secondary.Bullets, self.Secondary.Spread)
end
function SWEP:PostSecondaryAttack() end
