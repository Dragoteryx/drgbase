DrGBase.Weapons = DrGBase.Weapons or {}

function DrGBase.Weapons.Load(weapon)
  if weapon.Name == nil or weapon.Class == nil or weapon.Category == nil then
    DrGBase.Error("Couldn't load weapon: name, class or category nil.")
  else
    if SERVER then
      resource.AddFile("materials/weapons/"..weapon.Class..".png")
    end
    if weapon.Spawnable then
      list.Set("DrGBaseWeapons", weapon.Class, weapon)
    end
    DrGBase.Print("Weapon '"..weapon.Class.."': loaded.")
  end
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
