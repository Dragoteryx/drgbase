
local entMETA = FindMetaTable("Entity")
local plyMETA = FindMetaTable("Player")
local npcMETA = FindMetaTable("NPC")

function entMETA:GetDrGVar(name)
  return DrGBase.Net.GetVar(name, self)
end

function plyMETA:DrG_IsPossessing()
  return IsValid(self:DrG_Possessing())
end
function plyMETA:DrG_Possessing()
  return DrGBase.Nextbot.Possessing(self)
end

if SERVER then

  function entMETA:SetDrGVar(name, value)
    return DrGBase.Net.SetVar(name, value, self)
  end
  function entMETA:DrG_IsSanic()
    return self.OnReloaded ~= nil and
    self.GetNearestTarget ~= nil and
    self.AttackNearbyTargets ~= nil and
    self.IsHidingSpotFull ~= nil and
    self.GetNearestUsableHidingSpot ~= nil and
    self.ClaimHidingSpot ~= nil and
    self.AttemptJumpAtTarget ~= nil and
    self.LastPathingInfraction ~= nil and
    self.RecomputeTargetPath ~= nil and
    self.UnstickFromCeiling ~= nil
  end

  function plyMETA:DrG_JoinFaction(faction)
    self:DrG_InitFactions()
    self._DrGBaseFactions[string.upper(faction)] = true
  end
  function plyMETA:DrG_LeaveFaction(faction)
    self:DrG_InitFactions()
    self._DrGBaseFactions[string.upper(faction)] = false
  end
  function plyMETA:DrG_IsInFaction(faction)
    self:DrG_InitFactions()
    return self._DrGBaseFactions[string.upper(faction)] or false
  end
  function plyMETA:DrG_GetFactions()
    self:DrG_InitFactions()
    local factions = {}
    for faction, joined in pairs(self._DrGBaseFactions) do
      if joined then table.insert(factions, faction) end
    end
    return factions
  end
  function plyMETA:DrG_InitFactions()
    self._DrGBaseFactions = self._DrGBaseFactions or {}
  end

  -- Callbacks --

  DrGBase.Net.DefineCallback("DrGBaseFetchCreationID", function(data)
    local ent = Entity(data.ent)
    if not IsValid(ent) then return -1
    else return ent:GetCreationID() end
  end)

else

  function entMETA:DrG_FetchCreationID(callback)
    DrGBase.Net.UseCallback("DrGBaseFetchCreationID", callback)
  end

end
