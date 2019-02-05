if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot_human" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.Name = "DrGBase Test Nextbot Human"
ENT.Class = "npc_drg_nextbot_human_test"
ENT.Category = "DrGBase"
ENT.Models = {
  "models/player/kleiner.mdl",
  "models/player/magnusson.mdl"
}

-- Weapons --
ENT.Weapons = {"weapon_ar2"}
ENT.WeaponAccuracy = 0.75

-- Grenades --
ENT.GrenadeThrowDelay = 0
ENT.GrenadeClass = "prop_physics"
ENT.GrenadeCallback = function(grenade, init)
  if init then grenade:SetModel("models/props_junk/watermelon01.mdl") end
end

if SERVER then

  -- Misc --
  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
    self:SetFactionRelationship(DRGBASE_FACTION_REBELS, D_LI)
    self:SetModelRelationship(self:GetModel(), D_LI)
  end
  function ENT:Use(ply, ent)
    if IsValid(ply:GetActiveWeapon()) then
      if self:HasWeapon() and ply:GetActiveWeapon():GetClass() == self:GetWeapon():GetClass() then
        self:DropWeapon()
      else
        self:RemoveWeapon()
        self:GiveWeapon(ply:GetActiveWeapon():GetClass())
      end
    end
  end

  -- AI --
  function ENT:FetchDestination()
    return self:RandomPos(1500)
  end
  function ENT:ReachedDestination(pos)
    self:Idle(math.random(3, 7))
  end

  -- Hooks --
  function ENT:OnTakeDamage(dmg, hitgroups, bone)
    if hitgroups[HITGROUP_HEAD] then return 3 end
  end

  function ENT:OnDoorContact(door)
    return "open"
  end

end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
DrGBase.Nextbots.Load({
  Name = ENT.Name,
  Class = ENT.Class,
  Category = ENT.Category,
  Killicon = ENT.Killicon
})
