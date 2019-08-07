
local plyMETA = FindMetaTable("Player")

function plyMETA:DrG_IsPossessing()
  return IsValid(self:DrG_Possessing())
end
function plyMETA:DrG_Possessing()
  return self:GetNW2Entity("DrGBasePossessing")
end
function plyMETA:DrG_GetPossessing()
  return self:DrG_Possessing()
end

hook.Add("PlayerButtonDown", "DrGBasePlayerButtonDown", function(ply, button)
  ply._DrGBaseButtonsDown = ply._DrGBaseButtonsDown or {}
  ply._DrGBaseButtonsDown[button] = {
    down = true, recent = true
  }
  timer.Simple(0, function()
    if not IsValid(ply) then return end
    ply._DrGBaseButtonsDown[button].recent = false
  end)
end)
hook.Add("PlayerButtonUp", "DrGBasePlayerButtonUp", function(ply, button)
  ply._DrGBaseButtonsDown = ply._DrGBaseButtonsDown or {}
  ply._DrGBaseButtonsDown[button] = {
    down = false, recent = true
  }
  timer.Simple(0, function()
    if not IsValid(ply) then return end
    ply._DrGBaseButtonsDown[button].recent = false
  end)
end)
function plyMETA:DrG_ButtonUp(button)
  self._DrGBaseButtonsDown = self._DrGBaseButtonsDown or {}
  local data = self._DrGBaseButtonsDown[button]
  if data == nil then return true end
  return not data.down
end
function plyMETA:DrG_ButtonPressed(button)
  self._DrGBaseButtonsDown = self._DrGBaseButtonsDown or {}
  local data = self._DrGBaseButtonsDown[button]
  if data == nil then return false end
  return tobool(data.down and data.recent)
end
function plyMETA:DrG_ButtonDown(button)
  self._DrGBaseButtonsDown = self._DrGBaseButtonsDown or {}
  local data = self._DrGBaseButtonsDown[button]
  if data == nil then return false end
  return data.down or false
end
function plyMETA:DrG_ButtonReleased(button)
  self._DrGBaseButtonsDown = self._DrGBaseButtonsDown or {}
  local data = self._DrGBaseButtonsDown[button]
  if data == nil then return false end
  return tobool(not data.down and data.recent)
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

  function plyMETA:DrG_AddUndo(ent, type, text)
    undo.Create(type)
    undo.SetPlayer(self)
    undo.AddEntity(ent)
    if isstring(text) then
      undo.SetCustomUndoText(text)
    end
    undo.Finish()
  end

  function plyMETA:DrG_NetCallback(name, callback, ...)
    return net.DrG_UseCallback(name, callback, self, ...)
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
    if string.upper(faction) == FACTION_PLAYERS then return true end
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

else

  local LAST_LUX_UPDATE = 0
  hook.Add("Think", "DrGBasePlayerLuminosity", function()
    --print(LocalPlayer():DrG_Luminosity())
    if CurTime() <= LAST_LUX_UPDATE + 0.1 then return end
    LAST_LUX_UPDATE = CurTime()
    net.Start("DrGBasePlayerLuminosity")
    net.WriteFloat(LocalPlayer():DrG_Luminosity())
    net.SendToServer()
  end)
  function plyMETA:DrG_Luminosity()
    local ply = LocalPlayer()
    local light = (render.GetLightColor(LocalPlayer():EyePos())*255):ToColor()
    return ((light.r + light.g + light.b)/3)/255
  end

end
