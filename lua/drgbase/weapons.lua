
-- Registry --

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

-- Misc --

local PlayersCanGiveWeapons = CreateConVar("drgbase_give_weapons", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

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
