local plyMETA = FindMetaTable("Player")

--[[function plyMETA:DrG_GetPossessing()
  return self:DrG_IsPossessing() and self.DrG_Possessing or NULL
end
function plyMETA:DrG_IsPossessing()
  return IsValid(self.DrG_Possessing)
end]]

function plyMETA:DrG_GetPossessing()
  return self:GetNW2Entity("DrG/Possessing")
end
function plyMETA:DrG_IsPossessing()
  return IsValid(self:DrG_GetPossessing())
end

-- Buttons --

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

function plyMETA:DrG_Move()
  if not self.DrG_MoveObj then self.DrG_MoveObj = PlayerMove(self) end
  return self.DrG_MoveObj
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

function plyMETA:DrG_Binds()
  if not self.DrG_BindsObj then self.DrG_BindsObj = PlayerBinds(self) end
  return self.DrG_BindsObj
end

-- Selection

local PlayerSelection = DrGBase.CreateClass()

function PlayerSelection:new(ply, mode)
  self.Entities = {}
  self.Player = ply
  self.Mode = mode
end

function PlayerSelection.prototype:SelectedIterator()
  return function(_, ent)
    while true do
      ent = next(self.Entities, ent)
      if not ent then return end
      if not IsValid(ent) then continue end
      return ent
    end
  end
end
function PlayerSelection.prototype:GetSelected()
  local selected = {}
  for ent in self:SelectedIterator() do
    table.insert(selected, ent)
  end
  return selected
end
function PlayerSelection.prototype:IsSelected(ent)
  return self.Entities[ent] or false
end

function PlayerSelection.prototype:tostring()
  return ""
end

function plyMETA:DrG_ToolSelection(mode)
  local tool = self:GetTool(mode)
  if not tool then return end
  if not self.DrG_Selection then
    self.DrG_Selection = {}
  end
  if not self.DrG_Selection[tool.Mode] then
    self.DrG_Selection[tool.Mode] = PlayerSelection(self, tool.Mode)
  end
  return self.DrG_Selection[tool.Mode]
end

if SERVER then

  -- Possession --

  function plyMETA:DrG_StopPossession()
    if not self:DrG_IsPossessing() then return end
    self:DrG_GetPossessing():StopPossession()
  end

  -- Selection --

  function PlayerSelection.prototype:SelectEntity(ent)
    self.Entities[ent] = true
    net.Start("DrG/SelectEntity")
    net.WriteString(self.Mode)
    net.WriteEntity(ent)
    net.Send(self.Player)
  end
  function PlayerSelection.prototype:DeselectEntity(ent)
    self.Entities[ent] = nil
    net.Start("DrG/DeselectEntity")
    net.WriteString(self.Mode)
    net.WriteEntity(ent)
    net.Send(self.Player)
  end
  function PlayerSelection.prototype:ClearSelection()
    self.Entities = {}
    net.Start("DrG/ClearSelection")
    net.WriteString(self.Mode)
    net.Send(self.Player)
  end
  function PlayerSelection.prototype:ClearAndSelectEntity(ent)
    self.Entities = {[ent] = true}
    net.Start("DrG/ClearAndSelectEntity")
    net.WriteString(self.Mode)
    net.WriteEntity(ent)
    net.Send(self.Player)
  end

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

  net.Receive("DrG/SelectEntity", function()
    local ply = LocalPlayer()
    local mode = net.ReadString()
    local ent = net.ReadEntity()
    if IsValid(ent) then
      ply:DrG_Selection(mode).Entities[ent] = true
    end
  end)
  net.Receive("DrG/DeselectEntity", function()
    local ply = LocalPlayer()
    local mode = net.ReadString()
    local ent = net.ReadEntity()
    if IsValid(ent) then
      ply:DrG_Selection(mode).Entities[ent] = nil
    end
  end)
  net.Receive("DrG/ClearSelection", function()
    local ply = LocalPlayer()
    local mode = net.ReadString()
    if IsValid(ent) then
      ply:DrG_Selection(mode).Entities = {}
    end
  end)
  net.Receive("DrG/ClearAndSelectEntity", function()
    local ply = LocalPlayer()
    local mode = net.ReadString()
    local ent = net.ReadEntity()
    if IsValid(ent) then
      ply:DrG_Selection(mode).Entities = {[ent] = true}
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
