if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot_human_old" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Old Test Human"
ENT.Category = "DrGBase"
ENT.Models = {
  "models/player/kleiner.mdl",
  "models/player/magnusson.mdl"
}

-- Weapons --
ENT.Weapons = {"weapon_ar2"}
ENT.WeaponAccuracy = 0.75

if SERVER then
  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
    self:SetSelfModelRelationship(D_LI)
    self:SetFactionRelationship(DRGBASE_FACTION_REBELS, D_LI)
    if self:GetModel() == "models/player/kleiner.mdl" then
      self:SetModelRelationship("models/player/kleiner.mdl", D_LI)
    elseif self:GetModel() == "models/player/magnusson.mdl" then
      self:SetModelRelationship("models/player/magnusson.mdl", D_LI)
    end
  end
  function ENT:OnIdle()
    self:AddPatrolPos(self:RandomPos(1500))
  end
  function ENT:OnReachedPatrol()
    self:Wait(math.random(3, 7))
  end
end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
