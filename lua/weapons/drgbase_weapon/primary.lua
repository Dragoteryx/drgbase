
function SWEP:CanPrimaryAttack()
  if self:GetPrimaryAmmoType() < 0 then return true end
  if self.Primary.ClipSize > 0 then
    return self.Weapon:Clip1() >= self.Primary.Cost
  else return self.Owner:GetAmmoCount(self.Primary.Ammo) >= self.Primary.Cost end
end
function SWEP:TriedToPrimaryAttack()
  self:EmitSound(self.Primary.EmptySound)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Cooldown)
end
function SWEP:PrimaryAttack()
  if CLIENT then return end
	if not self:CanPrimaryAttack() then
    self:TriedToPrimaryAttack()
    return false
  end
  if self:PrePrimaryAttack() == false then return false end
	self:EmitSound(self.Primary.Sound)
  self.Owner:ViewPunch(self.Primary.ViewPunch)
	self:FirePrimary()
	self:TakePrimaryAmmo(self.Primary.Cost)
  if self.Primary.Cooldown >= 0 then
    local delay = CurTime() + self.Primary.Cooldown
    self:SetNextPrimaryFire(delay)
    self:PostPrimaryAttack(delay)
  else self:PostPrimaryAttack(CurTime()) end
  return true
end
function SWEP:PrePrimaryAttack() end
function SWEP:FirePrimary()
  self:ShootBullet(self.Primary.Damage, self.Primary.Bullets, self.Primary.Spread)
end
function SWEP:PostPrimaryAttack() end
