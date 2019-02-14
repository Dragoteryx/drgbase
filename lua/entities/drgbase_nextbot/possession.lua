
function ENT:IsPossessed()
  return IsValid(self:GetPossessor())
end

function ENT:GetPossessor()
  return self._DrGBasePossessor
end

function ENT:PossessorTrace(options)
  if not self:IsPossessed() then return end
  local origin, angles = self:PossessorView()
  options = options or {}
  options.filter = options.filter or {}
  table.insert(options.filter, self)
  table.insert(options.filter, self:GetWeapon())
  options.start = origin
  options.endpos = origin + angles:Forward()*999999999
  return util.TraceLine(options)
end

function ENT:PossessorView(view)
  if not self:IsPossessed() then return end
  view = view or self:CurrentPossessionView()
  local eyes = self:GetPossessor():EyeAngles()
  local roll = self:GetAngles().r
  local angles = Angle(-eyes.p, eyes.y + 180, 0)
  if view.invertpitch then
    angles.p = -angles.p
  end
  local bound1, bound2 = self:GetCollisionBounds()
  local center = self:GetPos() + (bound1 + bound2)/2
  if view.eyepos then
    center = self:EyePos()
  elseif isstring(view.bone) then
    local boneid = self:LookupBone(view.bone)
    if boneid ~= nil then
      center = self:GetBonePosition(boneid)
    end
  end
  local offset = center +
  self:GetForward()*view.offset.x*self:GetModelScale() +
  self:GetRight()*view.offset.y*self:GetModelScale() +
  self:GetUp()*view.offset.z*self:GetModelScale()
  local tr1 = util.TraceLine({
    start = center,
    endpos = offset,
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr1.HitWorld then offset = tr1.HitPos + tr1.Normal*-10 end
  local distance = view.distance
  if distance < 1 then distance = 1 end
  local endpos = offset + angles:Forward()*distance*self:GetModelScale()
  local tr2 = util.TraceLine({
    start = offset,
    endpos = endpos,
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr2.HitWorld then endpos = tr2.HitPos + tr2.Normal*-10 end
  local viewangle = (tr2.Normal*-1):Angle()
  return endpos, viewangle
end

function ENT:CurrentPossessionView()
  if not self:IsPossessed() then return end
  return self.PossessionViews[self:GetDrGVar("DrGBasePossessionView")], self:GetDrGVar("DrGBasePossessionView")
end

function ENT:PossessorForward()
  if SERVER and self:IsPossessed() or
  CLIENT and self:IsPossessedByLocalPlayer() then
    if self:IsFlying() and not self.FlightBackward then
      return self:GetPossessor():KeyDown(IN_FORWARD)
    else
      return self:GetPossessor():KeyDown(IN_FORWARD) and
      not self:GetPossessor():KeyDown(IN_BACK)
    end
  else return false end
end

function ENT:PossessorBackward()
  if SERVER and self:IsPossessed() or
  CLIENT and self:IsPossessedByLocalPlayer() then
    return self:GetPossessor():KeyDown(IN_BACK) and
    not self:GetPossessor():KeyDown(IN_FORWARD)
  else return false end
end

function ENT:PossessorLeft()
  if SERVER and self:IsPossessed() or
  CLIENT and self:IsPossessedByLocalPlayer() then
    return self:GetPossessor():KeyDown(IN_MOVELEFT) and
    not self:GetPossessor():KeyDown(IN_MOVERIGHT)
  else return false end
end

function ENT:PossessorRight()
  if SERVER and self:IsPossessed() or
  CLIENT and self:IsPossessedByLocalPlayer() then
    return self:GetPossessor():KeyDown(IN_MOVERIGHT) and
    not self:GetPossessor():KeyDown(IN_MOVELEFT)
  else return false end
end

function ENT:KeyPressed(key)
  if self:IsPossessed() then return self:GetPossessor():KeyPressed(key)
  else return false end
end
function ENT:KeyDown(key)
  if self:IsPossessed() then return self:GetPossessor():KeyDown(key)
  else return false end
end
function ENT:KeyReleased(key)
  if self:IsPossessed() then return self:GetPossessor():KeyReleased(key)
  else return false end
end
function ENT:KeyDownLast(key)
  if self:IsPossessed() then return self:GetPossessor():KeyDownLast(key)
  else return false end
end

if SERVER then
  util.AddNetworkString("DrGBaseNextbotPossess")
  util.AddNetworkString("DrGBaseNextbotDispossess")
  util.AddNetworkString("DrGBaseNextbotCanPossess")
  util.AddNetworkString("DrGBaseNextbotCantPossess")
  util.AddNetworkString("DrGBaseNextbotCyclePossessionViews")
  util.AddNetworkString("DrGBasePossessionData")

  function ENT:Possess(ply, _client)
    if not self.PossessionEnabled then return DRGBASE_POSSESS_DISABLED end
    if not IsValid(ply) then return DRGBASE_POSSESS_INVALID end
    if not ply:IsPlayer() then return DRGBASE_POSSESS_NOT_PLAYER end
    if not ply:Alive() then return DRGBASE_POSSESS_NOT_ALIVE end
    if IsValid(ply:DrG_Possessing()) then return DRGBASE_POSSESS_ALREADY end
    if self:IsPossessed() then return DRGBASE_POSSESS_NOT_EMPTY end
    if #self.PossessionViews == 0 then return DRGBASE_POSSESS_NOVIEWS end
    local hookres = hook.Run("DrGBase/Possess", self, ply, _client or false)
    if hookres ~= nil and not hookres then return DRGBASE_POSSESS_NOT_ALLOWED end
    hookres = self:OnPossess(ply)
    if hookres ~= nil and not hookres then return DRGBASE_POSSESS_NOT_ALLOWED end
    drive.PlayerStartDriving(ply, self, "drive_drgbase_nextbot")
    if not ply:IsDrivingEntity(self) then return DRGBASE_POSSESS_ERROR end
    --self:SetSolidMask(MASK_NPCSOLID)
    self:SetEnemy(nil)
    self:SetDestination(nil)
    ply._DrGBasePossessing = self
    self._DrGBasePossessor = ply
    net.Start("DrGBaseNextbotPossess")
    net.WriteEntity(self)
    net.WriteEntity(ply)
    net.Broadcast()
    self:SetDrGVar("DrGBasePossessionView", 1)
    self:_Debug("possessed by player '"..ply:Nick().."' ("..ply:EntIndex()..").")
    return DRGBASE_POSSESS_OK
  end
  function ENT:OnPossess() end

  function ENT:Dispossess(_client)
    if not self:IsPossessed() then return DRGBASE_DISPOSSESS_EMPTY end
    local possessor = self:GetPossessor()
    local hookres = hook.Run("DrGBase/Dispossess", self, possessor, _client or false)
    if hookres ~= nil and not hookres then return DRGBASE_DISPOSSESS_NOT_ALLOWED end
    hookres = self:OnDispossess(possessor)
    if hookres ~= nil and not hookres then return DRGBASE_DISPOSSESS_NOT_ALLOWED end
    drive.PlayerStopDriving(possessor)
    if possessor:IsDrivingEntity(self) then return DRGBASE_DISPOSSESS_ERROR end
    --self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
    possessor._DrGBasePossessing = nil
    self._DrGBasePossessor = nil
    net.Start("DrGBaseNextbotDispossess")
    net.WriteEntity(self)
    net.WriteEntity(possessor)
    net.Broadcast()
    self:SetDrGVar("DrGBasePossessionView", 1)
    self:_Debug("no longer possessed by player '"..possessor:Nick().."' ("..possessor:EntIndex()..").")
    return DRGBASE_DISPOSSESS_OK
  end
  function ENT:OnDispossess() end

  function ENT:CyclePossessionViews()
    local view = self:GetDrGVar("DrGBasePossessionView")
    view = view+1
    if view > #self.PossessionViews then view = 1 end
    self:SetDrGVar("DrGBasePossessionView", view)
  end

  net.Receive("DrGBaseNextbotCyclePossessionViews", function(len, ply)
    if not ply:DrG_IsPossessing() then return end
    ply:DrG_Possessing():CyclePossessionViews()
  end)

  function ENT:PossessionSendData(name, data)
    if not self:IsPossessed() then return end
    net.Start("DrGBasePossessionData")
    local compressed = util.Compress(util.TableToJSON({
      ply = self:GetPossessor():EntIndex(),
      ent = self:EntIndex(),
      name = name, data = data
    }))
    net.WriteData(compressed, #compressed)
    net.Send(self:GetPossessor())
    self:_Debug("sent data: '"..name.."'.")
  end

  -- Handlers --

  function ENT:PossessionBlockInput(bool)
    if bool == nil then return self._DrGBaseBlockInput
    elseif bool then self._DrGBaseBlockInput = true
    else self._DrGBaseBlockInput = false end
  end

  function ENT:PossessionBlockRotation(bool)
    if bool == nil then return self._DrGBaseBlockRotation
    elseif bool then self._DrGBaseBlockRotation = true
    else self._DrGBaseBlockRotation = false end
  end

  function ENT:_HandlePossessionThink()
    if not self:IsPossessed() then return end
    self:_HandlePossessionBinds(false)
  end

  function ENT:_HandlePossessionCoroutine()
    if not self:IsPossessed() then return end
    local possessor = self:GetPossessor()
    self:_SetState(DRGBASE_STATE_POSSESSED)
    if not self:PossessionBlockInput() then
      self:PossessionControls()
      self:_HandlePossessionBinds(true)
    end
  end
  function ENT:PossessionControls()
    if self:IsFlying() then
      local moving = false
      local origin, angles = self:PossessorView()
      local direction = angles:Forward()
      if self:PossessorForward() then
        moving = true
        self:FlyTowards(self:GetPos() + direction)
      elseif self.FlightBackward and self:PossessorBackward() then
        moving = true
        self:FlyTowards(self:GetPos() - direction)
      end
      if self.FlightStrafe then
        if self:PossessorLeft() then
          moving = true
          self:StrafeLeft()
        elseif self:PossessorRight() then
          moving = true
          self:StrafeRight()
        end
      end
      if not moving then self:FlightHover() end
    else
      if self:PossessorForward() then
        self:GoForward()
      elseif self:PossessorBackward() then
        self:GoBackward()
      end
      if self:PossessorLeft() then
        self:StrafeLeft()
      elseif self:PossessorRight() then
        self:StrafeRight()
      end
    end
  end

  function ENT:_HandlePossessionBinds(coroutine)
    if self:IsPossessed() then
      local possessor = self:GetPossessor()
      if not IsValid(possessor) or not possessor:Alive() then
        self:Dispossess()
        return
      end
      if self._DrGBaseReady and not self:PossessionBlockInput() then
        for i, move in ipairs(self.PossessionBinds) do
          if (not coroutine and move.coroutine) or (coroutine and not move.coroutine) then continue end
          if move.onkeypressed == nil then move.onkeypressed = function() end end
          if move.onkeydown == nil then move.onkeydown = function() end end
          if move.onkeyup == nil then move.onkeyup = function() end end
          if move.onkeydownlast == nil then move.onkeydownlast = function() end end
          if move.onkeyreleased == nil then move.onkeyreleased = function() end end
          if possessor:KeyPressed(move.bind) then move.onkeypressed(self, possessor) end
          if possessor:KeyDown(move.bind) then move.onkeydown(self, possessor) else move.onkeyup(self, possessor) end
          if possessor:KeyDownLast(move.bind) then move.onkeydownlast(self, possessor) end
          if possessor:KeyReleased(move.bind) then move.onkeyreleased(self, possessor) end
        end
      end
    end
  end

  -- Hooks (move spawned ents when possessing) --

  local function MoveEnt(ply, ent)
    if not IsValid(ply:DrG_Possessing()) then return end
    local tr = ply:DrG_Possessing():PossessorTrace()
    ent:SetPos(tr.HitPos)
  end
  local function MoveEntModel(ply, model, ent)
    MoveEnt(ply, ent)
  end
  hook.Add("PlayerSpawnedEffect", "DrGBasePlayerPossessingSpawnedEffect", MoveEntModel)
  hook.Add("PlayerSpawnedNPC", "DrGBasePlayerPossessingSpawnedNPC", MoveEnt)
  hook.Add("PlayerSpawnedProp", "DrGBasePlayerPossessingSpawnedProp", MoveEntModel)
  hook.Add("PlayerSpawnedRagdoll", "DrGBasePlayerPossessingSpawnedRagdoll", MoveEntModel)
  hook.Add("PlayerSpawnedSENT", "DrGBasePlayerPossessingSpawnedSENT", MoveEnt)
  hook.Add("PlayerSpawnedSWEP", "DrGBasePlayerPossessingSpawnedSWEP", MoveEnt)
  hook.Add("PlayerSpawnedVehicle", "DrGBasePlayerPossessingSpawnedVehicle", MoveEnt)

else

  function ENT:CyclePossessionViews()
    if not self:IsPossessedByLocalPlayer() then return end
    net.Start("DrGBaseNextbotCyclePossessionViews")
    net.SendToServer()
  end

  function ENT:IsPossessedByLocalPlayer()
    return self:IsPossessed() and self:GetPossessor():EntIndex() == LocalPlayer():EntIndex()
  end

  net.Receive("DrGBaseNextbotPossess", function()
    local ent = net.ReadEntity()
    local possessor = net.ReadEntity()
    if IsValid(ent) and IsValid(possessor) then
      ent._DrGBasePossessor = possessor
      possessor._DrGBasePossessing = ent
      hook.Run("DrGBase/Possess", ent, possessor)
      if ent.OnPossess == nil then return end
      ent:OnPossess(possessor)
    end
  end)

  net.Receive("DrGBaseNextbotDispossess", function()
    local ent = net.ReadEntity()
    local dispossessor = net.ReadEntity()
    if IsValid(ent) and IsValid(dispossessor) then
      ent._DrGBasePossessor = nil
      dispossessor._DrGBasePossessing = nil
      hook.Run("DrGBase/Dispossess", ent, dispossessor)
      if ent.OnDispossess == nil then return end
      ent:OnDispossess(dispossessor)
    end
  end)

  function ENT:PossessionHUD() end
  hook.Add("HUDPaint", "DrGBasePossessionHUD", function()
    local possessing = LocalPlayer():DrG_Possessing()
    if not IsValid(possessing) then return end
    local hookres = possessing:PossessionHUD(possessing:CurrentPossessionView())
    if hookres then return end
    -- draw possession hud

  end)

  function ENT:PossessionRender() end
  hook.Add("RenderScreenspaceEffects", "DrGBasePossessionDraw", function()
    local possessing = LocalPlayer():DrG_Possessing()
    if not IsValid(possessing) then return end
    possessing:PossessionRender(possessing:CurrentPossessionView())
  end)

  function ENT:PossessionReceiveData() end
  net.Receive("DrGBasePossessionData", function(len)
    local ply = LocalPlayer()
    if not ply:DrG_IsPossessing() then return end
    local ent = ply:DrG_Possessing()
    local tab = util.JSONToTable(util.Decompress(net.ReadData(len/8)))
    if tab.ply ~= ply:EntIndex() or tab.ent ~= ent:EntIndex() then return end
    ent:_Debug("received data: '"..tab.name.."'.")
    ent:PossessionReceiveData(tab.name, tab.data)
  end)

end
