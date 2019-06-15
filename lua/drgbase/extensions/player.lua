
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

if SERVER then

  util.AddNetworkString("DrGBasePlayerLuminosity")
  net.Receive("DrGBasePlayerLuminosity", function(len, ply)
    ply._DrGBaseLuminosity = net.ReadFloat()
  end)
  function plyMETA:DrG_Luminosity()
    return self._DrGBaseLuminosity
  end

  function plyMETA:DrG_Immobilize()
    local chair = ents.Create("prop_vehicle_prisoner_pod")
    if not chair then return end
    chair:SetModel("models/nova/airboat_seat.mdl")
    chair:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
    chair:SetPos(self:GetPos())
    chair:SetAngles(self:GetAngles())
    chair:SetNoDraw(true)
    chair:Spawn()
    self:EnterVehicle(chair)
  end

else

  local lastLuminosityUpdate = 0
  hook.Add("Think", "DrGBasePlayerLuminosity", function()
    --print(LocalPlayer():DrG_Luminosity())
    if CurTime() <= lastLuminosityUpdate + 0.1 then return end
    lastLuminosityUpdate = CurTime()
    net.Start("DrGBasePlayerLuminosity")
    net.WriteFloat(LocalPlayer():DrG_Luminosity())
    net.SendToServer()
  end)
  function plyMETA:DrG_Luminosity()
    local ply = LocalPlayer()
    return math.Clamp(render.GetLightColor(LocalPlayer():EyePos()):Length()^(1/3), 0, 1)
  end

end
