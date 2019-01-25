DrGBase.Weapons = DrGBase.Weapons or {}

function DrGBase.Weapons.Load(weapon)

end
function DrGBase.Weapons.GetLoaded()
  return list.Get("DrGBaseWeapons")
end
function DrGBase.Weapons.IsLoaded(weapon)
  if not isstring(weapon) then weapon = weapon:GetClass() end
  return list.Get("DrGBaseWeapons")[weapon] ~= nil
end

if SERVER then



else



end
