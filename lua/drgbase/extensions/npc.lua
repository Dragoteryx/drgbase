
local npcMETA = FindMetaTable("NPC")

if SERVER then

  function npcMETA:DrG_SetRelationship(ent, disp)
    if not IsValid(ent) then return end
    self._DrGBaseRelPrios = self._DrGBaseRelPrios or {}
    if not self._DrGBaseRelPrios[ent] then self._DrGBaseRelPrios[ent] = 0 end
    self._DrGBaseRelPrios[ent] = self._DrGBaseRelPrios[ent]+1
    self:AddEntityRelationship(ent, disp, self._DrGBaseRelPrios[ent])
  end

end
