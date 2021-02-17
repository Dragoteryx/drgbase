
local plyMETA = FindMetaTable("Player")

function plyMETA:DrG_IsPossessing()
  return IsValid(self:DrG_Possessing())
end
function plyMETA:DrG_Possessing()
  return self:GetNW2Entity("DrG/Possessing")
end
function plyMETA:DrG_GetPossessing()
  return self:DrG_Possessing()
end

hook.Add("PlayerButtonDown", "DrGBasePlayerButtonDown", function(ply, button)
  ply.DrG_ButtonsDown = ply.DrG_ButtonsDown or {}
  ply.DrG_ButtonsDown[button] = {
    down = true, recent = true
  }
  timer.Simple(0, function()
    if not IsValid(ply) then return end
    ply.DrG_ButtonsDown[button].recent = false
  end)
end)
hook.Add("PlayerButtonUp", "DrGBasePlayerButtonUp", function(ply, button)
  ply.DrG_ButtonsDown = ply.DrG_ButtonsDown or {}
  ply.DrG_ButtonsDown[button] = {
    down = false, recent = true
  }
  timer.Simple(0, function()
    if not IsValid(ply) then return end
    ply.DrG_ButtonsDown[button].recent = false
  end)
end)
function plyMETA:DrG_ButtonUp(button)
  self.DrG_ButtonsDown = self.DrG_ButtonsDown or {}
  local data = self.DrG_ButtonsDown[button]
  if data == nil then return true end
  return not data.down
end
function plyMETA:DrG_ButtonPressed(button)
  self.DrG_ButtonsDown = self.DrG_ButtonsDown or {}
  local data = self.DrG_ButtonsDown[button]
  if data == nil then return false end
  return tobool(data.down and data.recent)
end
function plyMETA:DrG_ButtonDown(button)
  self.DrG_ButtonsDown = self.DrG_ButtonsDown or {}
  local data = self.DrG_ButtonsDown[button]
  if data == nil then return false end
  return data.down or false
end
function plyMETA:DrG_ButtonReleased(button)
  self.DrG_ButtonsDown = self.DrG_ButtonsDown or {}
  local data = self.DrG_ButtonsDown[button]
  if data == nil then return false end
  return tobool(not data.down and data.recent)
end

-- Toolgun --

function plyMETA:DrG_GetSelectionTable(mode)
  self.DrG_SelectionTables = self.DrG_SelectionTables or {}
  if isstring(mode) then
    self.DrG_SelectionTables[mode] = self.DrG_SelectionTables[mode] or {}
    return self.DrG_SelectionTables[mode]
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

-- Move --

local PlayerMove = DrGBase.CreateClass()

function PlayerMove:new(ply)
  self.Player = ply
end

function PlayerMove.prototype:IsMoving()
  return self:IsMovingForward() or
    self:IsMovingBackward() or
    self:IsMovingLeft() or
    self:IsMovingRight()
end
function PlayerMove.prototype:IsMovingForward()
  return self.Player:KeyDown(IN_FORWARD) and
    not self.Player:KeyDown(IN_BACK)
end
function PlayerMove.prototype:IsMovingBackward()
  return self.Player:KeyDown(IN_BACK) and
    not self.Player:KeyDown(IN_FORWARD)
end
function PlayerMove.prototype:IsMovingLeft()
  return self.Player:KeyDown(IN_MOVELEFT) and
    not self.Player:KeyDown(IN_MOVERIGHT)
end
function PlayerMove.prototype:IsMovingRight()
  return self.Player:KeyDown(IN_MOVERIGHT) and
    not self.Player:KeyDown(IN_MOVELEFT)
end

function PlayerMove.prototype:tostring()
  return "IsMoving = " .. tostring(self:IsMoving()) .. "\n" ..
    "| Forward = " .. tostring(self:IsMovingForward()) .. "\n" ..
    "| Backward = " .. tostring(self:IsMovingBackward()) .. "\n" ..
    "| Left = " .. tostring(self:IsMovingLeft()) .. "\n" ..
    "| Right = " .. tostring(self:IsMovingRight())
end

local MOVE = {}
function plyMETA:DrG_Move()
  if not MOVE[self] then MOVE[self] = PlayerMove(self) end
  return MOVE[self]
end

-- Binds --

local PlayerBinds = DrGBase.CreateClass()

function PlayerBinds:new(ply)
  self.Player = ply
end

function PlayerBinds.prototype:IsUp(key)
  if string.StartWith(key, "IN_") then
    return not self.Player:KeyDown(_G[key])
  elseif string.StartWith(key, "KEY_") then
    return self.Player:DrG_ButtonUp(_G[key])
  else
    local key
    if CLIENT then
      local convar = GetConVar(key)
      if not convar then return false
      else key = convar:GetInt() end
    else
      key = self.Player:GetInfoNum(key, BUTTON_CODE_INVALID)
      if key == BUTTON_CODE_INVALID then return false end
    end
    return self.Player:DrG_ButtonUp(key)
  end
end
function PlayerBinds.prototype:IsDown(key)
  if string.StartWith(key, "IN_") then
    return self.Player:KeyDown(_G[key])
  elseif string.StartWith(key, "KEY_") then
    return self.Player:DrG_ButtonDown(_G[key])
  else
    local key
    if CLIENT then
      local convar = GetConVar(key)
      if not convar then return false
      else key = convar:GetInt() end
    else
      key = self.Player:GetInfoNum(key, BUTTON_CODE_INVALID)
      if key == BUTTON_CODE_INVALID then return false end
    end
    return self.Player:DrG_ButtonDown(key)
  end
end
function PlayerBinds.prototype:WasPressed(key)
  if string.StartWith(key, "IN_") then
    return self.Player:KeyPressed(_G[key])
  elseif string.StartWith(key, "KEY_") then
    return self.Player:DrG_ButtonPresed(_G[key])
  else
    local key
    if CLIENT then
      local convar = GetConVar(key)
      if not convar then return false
      else key = convar:GetInt() end
    else
      key = self.Player:GetInfoNum(key, BUTTON_CODE_INVALID)
      if key == BUTTON_CODE_INVALID then return false end
    end
    return self.Player:DrG_ButtonPressed(key)
  end
end
function PlayerBinds.prototype:WasReleased(key)
  if string.StartWith(key, "IN_") then
    return self.Player:KeyReleased(_G[key])
  elseif string.StartWith(key, "KEY_") then
    return self.Player:DrG_ButtonReleased(_G[key])
  else
    local key
    if CLIENT then
      local convar = GetConVar(key)
      if not convar then return false
      else key = convar:GetInt() end
    else
      key = self.Player:GetInfoNum(key, BUTTON_CODE_INVALID)
      if key == BUTTON_CODE_INVALID then return false end
    end
    return self.Player:DrG_ButtonReleased(key)
  end
end

function PlayerBinds.prototype:tostring()
  return ""
end

local BINDS = {}
function plyMETA:DrG_Binds()
  if not BINDS[self] then BINDS[self] = PlayerBinds(self) end
  return BINDS[self]
end

if SERVER then

  -- Possession --

  function plyMETA:DrG_StopPossession()
    if not self:DrG_IsPossessing() then return end
    self:DrG_Possessing():StopPossession()
  end

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

  function plyMETA:DrG_Luminosity()
    if self ~= LocalPlayer() then return -1 end
    local light = render.GetLightColor(self:EyePos())
    local length = math.Round(light:Length(), 2)
    return math.Clamp(math.sqrt(math.log(length)+5)/2, 0, 1)
  end

  net.DrG_DefineCallback("DrG/PlayerLuminosity", function()
    local ply = LocalPlayer()
    if not isfunction(ply.DrG_Luminosity) then return 1
    else return ply:DrG_Luminosity() end
  end)

end
