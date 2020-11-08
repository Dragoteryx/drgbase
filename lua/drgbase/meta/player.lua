
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

-- Toolgun --

function plyMETA:DrG_GetSelectionTable(mode)
  self._DrGBaseSelectionTables = self._DrGBaseSelectionTables or {}
  if isstring(mode) then
    self._DrGBaseSelectionTables[mode] = self._DrGBaseSelectionTables[mode] or {}
    return self._DrGBaseSelectionTables[mode]
  else
    local tool = self:GetTool()
    if tool == nil then return {}
    else return self:DrG_GetSelectionTable(tool.Mode) end
  end
end

local function NextSelectedEntity(ply, previous, mode)
  local ent = next(ply:DrG_GetSelectionTable(mode), previous)
  if ent == nil then return nil
  elseif not IsValid(ent) then
    return NextSelectedEntity(ply, ent, mode)
  else return ent end
end
function plyMETA:DrG_SelectedEntities(mode)
  return function(inv, previous)
    return NextSelectedEntity(self, previous, mode)
  end
end
function plyMETA:DrG_GetSelectedEntities(mode)
  local entities = {}
  for ent in self:DrG_SelectedEntities(mode) do
    table.insert(entities, ent)
  end
  return entities
end
function plyMETA:DrG_IsEntitySelected(ent, mode)
  return self:DrG_GetSelectionTable(mode)[ent] or false
end

if SERVER then

  -- Toolgun --

  util.AddNetworkString("DrGBaseSelectEntity")
  function plyMETA:DrG_SelectEntity(ent, mode)
    if not IsValid(ent) then return end
    self:DrG_GetSelectionTable(mode)[ent] = true
    net.Start("DrGBaseSelectEntity")
    net.WriteEntity(ent)
    if isstring(mode) then
      net.WriteBool(true)
      net.WriteString(mode)
    else net.WriteBool(false) end
    net.Send(self)
  end

  util.AddNetworkString("DrGBaseDeselectEntity")
  function plyMETA:DrG_DeselectEntity(ent, mode)
    if not IsValid(ent) then return end
    self:DrG_GetSelectionTable(mode)[ent] = nil
    net.Start("DrGBaseDeselectEntity")
    net.WriteEntity(ent)
    if isstring(mode) then
      net.WriteBool(true)
      net.WriteString(mode)
    else net.WriteBool(false) end
    net.Send(self)
  end

  function plyMETA:DrG_ClearSelectedEntities(mode)
    for ent in self:DrG_SelectedEntities(mode) do
      self:DrG_DeselectEntity(ent, mode)
    end
  end

  function plyMETA:DrG_ToggleEntitySelect(ent, mode)
    if self:DrG_IsEntitySelected(ent, mode) then
      self:DrG_DeselectEntity(ent, mode)
    else self:DrG_SelectEntity(ent, mode) end
  end

  function plyMETA:DrG_CleverEntitySelect(ent, mode)
    local selected = self:DrG_GetSelectedEntities(mode)
    if (#selected > 1 or selected[1] ~= ent) and
    not self:KeyDown(IN_SPEED) then
      self:DrG_ClearSelectedEntities(mode)
    end
    self:DrG_ToggleEntitySelect(ent, mode)
  end

  function plyMETA:DrG_SingleEntitySelect(ent, mode)
    if not self:DrG_IsEntitySelected(ent, mode) then
      self:DrG_ClearSelectedEntities(mode)
      self:DrG_SelectEntity(ent, mode)
    else self:DrG_DeselectEntity(ent, mode) end
  end

  hook.Add("SetupPlayerVisibility", "DrGBaseSelectedEntitiesAddToPVS", function(ply)
		local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
    if ply:GetTool() == nil then return end
		for ent in ply:DrG_SelectedEntities() do
      AddOriginToPVS(ent:GetPos())
    end
	end)

  -- Luminosity --

  coroutine.DrG_RunThread("DrG/PlayerLuminosity", function()
    while true do
      local players = player.GetHumans()
      for i = 1, #players do
        local ply = players[i]
        ply:DrG_RunCallback("DrG/PlayerLuminosity", function(luminosity)
          if IsValid(ply) then ply.DrG_LuminosityValue = luminosity end
        end)
      end
      coroutine.wait(0.5)
    end
  end)

  function plyMETA:DrG_Luminosity()
    return self.DrG_LuminosityValue or 1
  end

  -- Factions --

  local function InitFactions(ply)
    ply._DrGBaseFactions =ply._DrGBaseFactions or {}
  end

  function plyMETA:DrG_JoinFaction(faction)
    InitFactions(self)
    if self:DrG_IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = true
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function plyMETA:DrG_LeaveFaction(faction)
    InitFactions(self)
    if not self:DrG_IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = false
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function plyMETA:DrG_IsInFaction(faction)
    InitFactions(self)
    return self._DrGBaseFactions[string.upper(faction)] or false
  end
  function plyMETA:DrG_GetFactions()
    InitFactions(self)
    local factions = {}
    for faction, joined in pairs(self._DrGBaseFactions) do
      if joined then table.insert(factions, faction) end
    end
    return factions
  end
  function plyMETA:DrG_JoinFactions(factions)
    for _, faction in ipairs(factions) do self:DrG_JoinFaction(faction) end
  end
  function plyMETA:DrG_LeaveFactions(factions)
    for _, faction in ipairs(factions) do self:DrG_LeaveFaction(faction) end
  end
  function plyMETA:DrG_LeaveAllFactions()
    self:DrG_LeaveFactions(self:DrG_GetFactions())
  end

  -- Misc --

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
    if not isstring(text) then
      undo.SetCustomUndoText("Undone #"..ent:GetClass())
    else undo.SetCustomUndoText(text) end
    undo.Finish()
  end

else

  -- Toolgun --

  net.Receive("DrGBaseSelectEntity", function()
    local ply = LocalPlayer()
    local ent = net.ReadEntity()
    local mode = net.ReadBool() and net.ReadString()
    if IsValid(ent) then
      ply:DrG_GetSelectionTable(mode)[ent] = true
    end
  end)
  net.Receive("DrGBaseDeselectEntity", function()
    local ply = LocalPlayer()
    local ent = net.ReadEntity()
    local mode = net.ReadBool() and net.ReadString()
    if IsValid(ent) then
      ply:DrG_GetSelectionTable(mode)[ent] = nil
    end
  end)

  -- Luminosity --

  net.DrG_DefineCallback("DrG/PlayerLuminosity", function()
    return LocalPlayer():DrG_Luminosity()
  end)

  function plyMETA:DrG_Luminosity()
    if self ~= LocalPlayer() then return -1 end
    local light = render.GetLightColor(self:EyePos())
    local length = math.Round(light:Length(), 2)
    return math.Clamp(math.sqrt(math.log(length)+5)/2, 0, 1)
  end

end
