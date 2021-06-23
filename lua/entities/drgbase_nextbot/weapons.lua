-- Getters --

function ENT:GetActiveWeapon()
  return self:GetNW2Entity("DrG/Weapon")
end
function ENT:GetWeapon(class)
  if isstring(class) then
    --
  else return self:GetActiveWeapon() end
end

function ENT:HasWeapon()
  return IsValid(self:GetWeapon())
end

if SERVER then



end