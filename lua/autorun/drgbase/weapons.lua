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

local PlayersCanGiveWeapons = CreateConVar("drgbase_give_weapons", "1")

properties.Add("drgbasegiveweapons", {
	MenuLabel = "Give Current Weapon",
	Order = 1001,
	MenuIcon = "icon16/gun.png",
	Filter = function(self, ent, ply)
    return ent.IsDrGNextbot and
    ent.UseWeapons and
    ent.AcceptPlayerWeapons and
		PlayersCanGiveWeapons:GetBool()
	end,
	Action = function(self, ent)
    self:MsgStart()
    net.WriteEntity(ent)
    self:MsgEnd()
  end,
	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if ent:HasWeapon() then ent:RemoveWeapon() end
    ent:GiveWeapon(wep:GetClass())
	end
})

properties.Add("drgbasestripweapons", {
	MenuLabel = "Strip Weapon",
	Order = 1002,
	MenuIcon = "icon16/gun.png",
	Filter = function(self, ent, ply)
    return ent.IsDrGNextbot and
    ent.UseWeapons and
    ent.AcceptPlayerWeapons and
		PlayersCanGiveWeapons:GetBool()
	end,
	Action = function(self, ent)
    self:MsgStart()
    net.WriteEntity(ent)
    self:MsgEnd()
  end,
	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent:RemoveWeapon()
	end
})

if SERVER then



else



end
