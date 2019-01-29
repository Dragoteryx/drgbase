if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot_human" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.Name = "DrGBase Test Nextbot Human"
ENT.Class = "npc_drg_nextbot_human_test"
ENT.Category = "DrGBase"
ENT.Models = {"models/player/arctic.mdl"}

if SERVER then

  -- Misc --
  function ENT:SpawnedBy(ply)
    self:SetEntityRelationship(ply, D_LI)
    self._OwnerEntIndex = ply:EntIndex()
  end
  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
    self:DefineCustomRelationshipCheck("SameOwner", function(ent)
      if self:GetClass() ~= ent:GetClass() then return end
      if self._OwnerEntIndex == ent._OwnerEntIndex then return D_LI end
    end)
    self:GiveWeapon("weapon_drg_aug")
  end
  function ENT:CustomThink() end
  function ENT:CustomBehaviour() end
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

end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
DrGBase.Nextbot.Load({
  Name = ENT.Name,
  Class = ENT.Class,
  Category = ENT.Category,
  Killicon = ENT.Killicon
})
