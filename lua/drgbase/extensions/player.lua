
local plyMETA = FindMetaTable("Player")

function plyMETA:DrG_IsPossessing()
  return IsValid(self:DrG_Possessing())
end
function plyMETA:DrG_Possessing()
  return self:GetNW2Entity("DrGBasePossessing")
end

function plyMETA:DrG_SteamAvatar(callback, onerror)
  http.Fetch("https://steamcommunity.com/profiles/"..self:SteamID64().."?xml=1", function(body)
    -- fetch the avatar from the xml file
    callback(avatar)
  end, function(err)
    if isfunction(onerror) then onerror(err) end
  end)
end

-- Factions --

function plyMETA:DrG_JoinFaction(faction)
  self:DrG_InitFactions()
  if self:DrG_IsInFaction(faction) then return end
  self._DrGBaseFactions[string.upper(faction)] = true
  for i, nextbot in ipairs(DrGBase.GetNextbots()) do
    nextbot:UpdateRelationshipWith(self)
  end
end
function plyMETA:DrG_LeaveFaction(faction)
  self:DrG_InitFactions()
  if not self:DrG_IsInFaction(faction) then return end
  self._DrGBaseFactions[string.upper(faction)] = false
  for i, nextbot in ipairs(DrGBase.GetNextbots()) do
    nextbot:UpdateRelationshipWith(self)
  end
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
function plyMETA:DrG_JoinFactions(factions)
  for i, faction in ipairs(factions) do
    self:DrG_JoinFaction(faction)
  end
end
function plyMETA:DrG_LeaveFactions(factions)
  for i, faction in ipairs(factions) do
    self:DrG_LeaveFaction(faction)
  end
end
function plyMETA:DrG_LeaveAllFactions()
  self:DrG_LeaveFactions(self:DrG_GetFactions())
end
