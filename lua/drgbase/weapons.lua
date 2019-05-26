
function DrGBase.AddWeapon(SWEP)
  local class = string.Replace(SWEP.Folder, "weapons/", "")
  if SWEP.Name == nil or SWEP.Category == nil then return end
  if CLIENT then
    language.Add(class, SWEP.PrintName)
    SWEP.Killicon = SWEP.Killicon or {
      icon = "HUD/killicons/default",
      color = Color(255, 80, 0, 255)
    }
    killicon.Add(class, SWEP.Killicon.icon, SWEP.Killicon.color)
  else resource.AddFile("materials/weapons/"..class..".png") end
  local weapon = {
    PrintName = ENT.Name,
    Class = class,
    Category = ENT.Category
  }
  list.Set("DrGBaseWeapons", class, SWEP)
  DrGBase.Print("Weapon '"..class.."': loaded.")
end
