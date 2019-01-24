
function ENT:IsPossessed()
  return IsValid(self:GetPossessor())
end

function ENT:GetPossessor()
  return self._DrGBasePossessor
end

function ENT:PossessorTrace()
  if not self:IsPossessed() then return end
  local origin, angles = self:PossessorView()
  return util.TraceLine({
    start = origin,
    endpos = origin + angles:Forward()*999999999,
    filter = {self}
  })
end

function ENT:PossessorView()
  if not self:IsPossessed() then return end
  local forward = self:GetAngles()
  local eyes = self:GetPossessor():EyeAngles()
  local angles = Angle(-eyes.p, eyes.y, 0)
  local bound1, bound2 = self:GetCollisionBounds()
  local center = self:GetPos() + (bound1 + bound2)/2
  local offset = center +
  self:GetForward()*self.Possession.offset.x*self:GetModelScale() +
  self:GetRight()*self.Possession.offset.y*self:GetModelScale() +
  self:GetUp()*self.Possession.offset.z*self:GetModelScale()
  local tr1 = util.TraceLine({
    start = center,
    endpos = offset,
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr1.HitWorld then offset = tr1.HitPos + tr1.Normal*-10 end
  local endpos = offset + angles:Forward()*self.Possession.distance*self:GetModelScale()
  local tr2 = util.TraceLine({
    start = offset,
    endpos = endpos,
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr2.HitWorld then endpos = tr2.HitPos + tr2.Normal*-10 end
  return endpos, (tr2.Normal*-1):Angle()
end

if SERVER then
  util.AddNetworkString("DrGBaseNextbotPossess")
  util.AddNetworkString("DrGBaseNextbotDispossess")
  util.AddNetworkString("DrGBaseNextbotCanPossess")
  util.AddNetworkString("DrGBaseNextbotCantPossess")

  function ENT:Possess(ply, _client)
    if not self.PossessionEnabled then return DRGBASE_POSSESS_DISABLED end
    if not IsValid(ply) then return DRGBASE_POSSESS_INVALID end
    if not ply:IsPlayer() then return DRGBASE_POSSESS_NOT_PLAYER end
    if not ply:Alive() then return DRGBASE_POSSESS_NOT_ALIVE end
    if IsValid(ply:DrG_Possessing()) then return DRGBASE_POSSESS_ALREADY end
    if self:IsPossessed() then return DRGBASE_POSSESS_NOT_EMPTY end
    local hookres = hook.Run("DrGBase/Possess", self, ply, _client or false)
    if hookres ~= nil and not hookres then return DRGBASE_POSSESS_NOT_ALLOWED end
    hookres = self:OnPossess(ply)
    if hookres ~= nil and not hookres then return DRGBASE_POSSESS_NOT_ALLOWED end
    drive.PlayerStartDriving(ply, self, "drive_drgbase_nextbot")
    if not ply:IsDrivingEntity(self) then return DRGBASE_POSSESS_ERROR end
    self:SetEnemy(nil)
    self:SetDestination(nil)
    ply._DrGBasePossessing = self
    self._DrGBasePossessor = ply
    net.Start("DrGBaseNextbotPossess")
    net.WriteEntity(self)
    net.WriteEntity(ply)
    net.Broadcast()
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
    possessor._DrGBasePossessing = nil
    self._DrGBasePossessor = nil
    net.Start("DrGBaseNextbotDispossess")
    net.WriteEntity(self)
    net.WriteEntity(possessor)
    net.Broadcast()
    self:_Debug("no longer possessed by player '"..possessor:Nick().."' ("..possessor:EntIndex()..").")
    return DRGBASE_DISPOSSESS_OK
  end
  function ENT:OnDispossess() end

  -- Handlers --

  function ENT:PossessionBlockInput(bool)
    if bool == nil then return self._DrGBaseBlockInput
    elseif bool then self._DrGBaseBlockInput = true
    else self._DrGBaseBlockInput = false end
  end

  function ENT:_HandlePossessionBinds(coroutine)
    if self:IsPossessed() then
      local possessor = self:GetPossessor()
      if not IsValid(possessor) or not possessor:Alive() then
        self:Dispossess()
        return
      end
      if self._DrGBaseReady and not self:PossessionBlockInput() then
        for i, move in ipairs(self.Possession.binds) do
          if (not coroutine and move.coroutine) or (coroutine and not move.coroutine) then continue end
          if move.onkeypressed == nil then move.onkeypressed = function() end end
          if move.onkeydown == nil then move.onkeydown = function() end end
          if move.onkeynotdown == nil then move.onkeynotdown = function() end end
          if move.onkeydownlast == nil then move.onkeydownlast = function() end end
          if move.onkeyreleased == nil then move.onkeyreleased = function() end end
          if possessor:KeyPressed(move.bind) then move.onkeypressed(self, possessor) end
          if possessor:KeyDown(move.bind) then move.onkeydown(self, possessor) else move.onkeynotdown(self, possessor) end
          if possessor:KeyDownLast(move.bind) then move.onkeydownlast(self, possessor) end
          if possessor:KeyReleased(move.bind) then move.onkeyreleased(self, possessor) end
        end
      end
    end
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
      if self:IsMovingForward() then
        self:GoForward()
      elseif self:IsMovingBackward() then
        self:GoBackward()
      end
      if self:IsMovingLeft() then
        self:StrafeLeft()
      elseif self:IsMovingRight() then
        self:StrafeRight()
      end
      self:_HandlePossessionBinds(true)
    end
  end
  function ENT:PossessionCustomControls() end

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

end
