
-- View --

function ENT:CurrentPossessionView()
  if not self:IsPossessed() then return end
  return self.PossessionViews[self:GetDrGVar("DrGBasePossessionView")], self:GetDrGVar("DrGBasePossessionView")
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
  if view.invertyaw then
    angles.y = -angles.y
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
  local offset = view.offset or Vector(0, 0, 0)
  local origin = center +
  self:GetForward()*offset.x*self:GetModelScale() +
  self:GetRight()*offset.y*self:GetModelScale() +
  self:GetUp()*offset.z*self:GetModelScale()
  local tr1 = util.TraceLine({
    start = center,
    endpos = origin,
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr1.HitWorld then origin = tr1.HitPos + tr1.Normal*-10 end
  local distance = view.distance or 1
  if distance < 1 then distance = 1 end
  local endpos = origin + angles:Forward()*distance*self:GetModelScale()
  local tr2 = util.TraceLine({
    start = origin,
    endpos = endpos,
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr2.HitWorld then endpos = tr2.HitPos + tr2.Normal*-10 end
  local viewangle = (tr2.Normal*-1):Angle()
  return endpos, viewangle
end

function ENT:PossessorNormal()
  if not self:IsPossessed() then return end
  local origin, angles = self:PossessorView()
  return angles:Forward()
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

-- Getters --

function ENT:IsPossessed()
  return IsValid(self:GetPossessor())
end

function ENT:GetPossessor()
  return self._DrGBasePossessor
end

-- Helpers --

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

-- Handlers --

function ENT:_HandlePossessionBinds(coroutine)
  if self:IsPossessed() then
    local possessor = self:GetPossessor()
    if CLIENT or not self:PossessionBlockInput() then
      for i, move in ipairs(self.PossessionBinds) do
        if CLIENT and not move.client then continue end
        if SERVER and ((not coroutine and move.coroutine) or (coroutine and not move.coroutine)) then continue end
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

if SERVER then
  util.AddNetworkString("DrGBaseNextbotPossess")
  util.AddNetworkString("DrGBaseNextbotDispossess")
  util.AddNetworkString("DrGBaseNextbotCanPossess")
  util.AddNetworkString("DrGBaseNextbotCantPossess")
  util.AddNetworkString("DrGBaseNextbotCyclePossessionViews")

  -- Activate --

  function ENT:Possess(ply, _client)
    if not self.PossessionEnabled then return "disabled" end
    if not IsValid(ply) then return "invalid player" end
    if not ply:IsPlayer() then return "not player" end
    if not ply:Alive() then return "not alive" end
    if IsValid(ply:DrG_Possessing()) then return "already possessing" end
    if self:IsPossessed() then return "already_possessed" end
    if #self.PossessionViews == 0 then return "no views" end
    local hookres = hook.Run("DrGBase/Possess", self, ply, _client or false)
    if hookres ~= nil and not hookres then return "not allowed" end
    hookres = self:OnPossess(ply)
    if hookres ~= nil and not hookres then return "not allowed" end
    drive.PlayerStartDriving(ply, self, "drive_drgbase_nextbot")
    if not ply:IsDrivingEntity(self) then return "error" end
    self:_Debug("possessed by player '"..ply:GetName().."'.", "drgbase_debug_misc")
    ply._DrGBasePossessing = self
    self._DrGBasePossessor = ply
    --ply:SetNoTarget(true)
    for i, ent in ipairs(self:GetTargets()) do
      self:ForgetEntity(ent)
    end
    net.Start("DrGBaseNextbotPossess")
    net.WriteEntity(self)
    net.WriteEntity(ply)
    net.Broadcast()
    self:SetDrGVar("DrGBasePossessionView", 1)
    return "ok"
  end
  function ENT:OnPossess() end

  function ENT:Dispossess(_client)
    if not self:IsPossessed() then return "not possessed" end
    local possessor = self:GetPossessor()
    local hookres = hook.Run("DrGBase/Dispossess", self, possessor, _client or false)
    if hookres ~= nil and not hookres then return "not allowed" end
    hookres = self:OnDispossess(possessor)
    if hookres ~= nil and not hookres then return "not allowed" end
    drive.PlayerStopDriving(possessor)
    if possessor:IsDrivingEntity(self) then return "error" end
    self:_Debug("dispossessed by player '"..possessor:GetName().."'.", "drgbase_debug_misc")
    possessor._DrGBasePossessing = nil
    self._DrGBasePossessor = nil
    possessor:SetNoTarget(false)
    net.Start("DrGBaseNextbotDispossess")
    net.WriteEntity(self)
    net.WriteEntity(possessor)
    net.Broadcast()
    self:SetDrGVar("DrGBasePossessionView", 1)
    return "ok"
  end
  function ENT:OnDispossess() end

  -- Setters --

  function ENT:PossessionBlockInput(bool)
    if bool == nil then return self._DrGBaseBlockInput
    elseif bool then self._DrGBaseBlockInput = true
    else self._DrGBaseBlockInput = false end
  end

  function ENT:PossessionBlockYaw(bool)
    if bool == nil then return self._DrGBaseBlockYaw
    elseif bool then self._DrGBaseBlockYaw = true
    else self._DrGBaseBlockYaw = false end
  end

  -- Views --

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

  -- Hooks --

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

  -- Handlers --

  function ENT:_HandlePossessionThink()
    if not self:IsPossessed() then return end
    local possessor = self:GetPossessor()
    if not IsValid(possessor) or not possessor:Alive() then
      self:Dispossess()
      return
    end
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

  -- Move spawned ents --

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

  function ENT:PossessionHalos() end
  hook.Add("PreDrawHalos", "DrGBasePossessionHalos", function()
    local possessing = LocalPlayer():DrG_Possessing()
    if not IsValid(possessing) then return end
    possessing:PossessionHalos(possessing:CurrentPossessionView())
  end)

end
