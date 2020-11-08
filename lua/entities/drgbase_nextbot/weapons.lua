-- Getters --

function ENT:GetWeapon()
  return self:GetNW2Entity("DrG/Weapon")
end
function ENT:GetActiveWeapon()
  return self:GetWeapon()
end

if SERVER then



end