ENT.Base = "base_entity"
ENT.Type = "point"
ENT.IsDrGRagdoll = true
ENT.PrintName = "Ragdoll"
ENT.Category = "DrGBase"

function ENT:Initialize() end
function ENT:SetupDataTables()
  self:NetworkVar("Entity", 0, "Ragdoll")
end

function ENT:Think()
  
  self:NextThink(CurTime() + engine.TickInterval())
  return true
end
