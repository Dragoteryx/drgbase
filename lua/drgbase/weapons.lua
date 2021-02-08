-- Registry --

function DrGBase.AddWeapon(SWEP)
  local class = string.Replace(SWEP.Folder, "weapons/", "")
  if SWEP.PrintName == nil or SWEP.Category == nil then return false end
  if CLIENT then
    language.Add(class, SWEP.PrintName)
    SWEP.Killicon = SWEP.Killicon or {
      icon = "HUD/killicons/default",
      color = Color(255, 80, 0, 255)
    }
    killicon.Add(class, SWEP.Killicon.icon, SWEP.Killicon.color)
  else resource.AddFile("materials/weapons/"..class..".png") end
  list.Set("DrG/Weapons", class, {
    Name = SWEP.PrintName,
    Class = class,
    Category = SWEP.Category
  })
  DrGBase.Print("Weapon '"..class.."' loaded")
	return true
end

-- Spawnmenu --

hook.Add("DrG/PopulateSpawnmenu", "AddWeapons", function(panel, tree)
	--
end)

-- Misc --

local PlayersCanGiveWeapons = CreateConVar("drgbase_give_weapons", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

properties.Add("drg/giveweapon", {
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
    ent:SetActiveWeapon(ent:GiveWeapon(wep:GetClass()))
	end
})

properties.Add("drg/stripweapon", {
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
