-- Getters --

function ENT:GetActiveWeapon()
  return self:GetNW2Entity("DrG/Weapon")
end
function ENT:GetWeapon(class)
  if isstring(class) then
    --
  else return self:GetActiveWeapon() end
end

function ENT:HasWeapon(class)
  return IsValid(self:GetWeapon(class))
end

if SERVER then



end