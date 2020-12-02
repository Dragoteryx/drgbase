-- Getters --

function ENT:GetWeapon()
  return self:GetNW2Entity("DrG/Weapon")
end
function ENT:GetActiveWeapon()
  return self:GetWeapon()
end

function ENT:HasWeapon()
  return IsValid(self:GetWeapon())
end

if SERVER then



end