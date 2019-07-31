ENT.Base = "base_entity"
ENT.Type = "point"
ENT.PrintName = "Ragdoll Attachment"
ENT.Category = "DrGBase"
function ENT:SetupDataTables()
  self:NetworkVar("Entity", 0, "Ragdoll")
  self:NetworkVar("Int", 0, "Bone")
end
if SERVER then
  AddCSLuaFile()
  function ENT:Initialize()
    local ragdoll = self:GetRagdoll()
    if IsValid(ragdoll) then
      --self:DeleteOnRemove(ragdoll)
    else self:Remove() end
  end
  function ENT:Think()
    --debugoverlay.Sphere(self:GetPos(), 2, 0.1, nil, true)
    local ragdoll = self:GetRagdoll()
    if IsValid(ragdoll) then
      local bone = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(self:GetBone()))
      if bone then
        bone:SetAngleDragCoefficient(100000)
        bone:SetPos(self:GetPos())
      end
    else self:Remove() end
    self:NextThink(CurTime() + engine.TickInterval())
    return true
  end
end
