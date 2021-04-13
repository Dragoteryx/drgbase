local META = FindMetaTable("DrG/NextBot")

-- Getters --

function META:GetWeapon()
  return self:GetNW2Entity("DrG/Weapon")
end
function META:GetActiveWeapon()
  return self:GetWeapon()
end

function META:HasWeapon()
  return IsValid(self:GetWeapon())
end

if SERVER then



end