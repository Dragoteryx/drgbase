
-- Getters/setters --

function ENT:IsPossessionEnabled()
  return self:GetNW2Bool("DrGBasePossessionEnabled")
end

function ENT:GetPossessor()
  return self:GetNW2Entity("DrGBasePossessor")
end
function ENT:IsPossessed()
  return IsValid(self:GetPossessor())
end

function ENT:CurrentViewPreset()
  if not self:IsPossessed() then return -1 end
  if #self.PossessionViews == 0 then return -1 end
  local current = self:GetNW2Int("DrGBasePossessionView", 1)
  return current, self.PossessionViews[current]
end
function ENT:CycleViewPresets()
  if SERVER then
    local current = self:CurrentViewPreset()
    if current == -1 then return end
    current = current + 1
    if current > #self.PossessionViews then current = 1 end
    self:SetNW2Int("DrGBasePossessionView", current)
  elseif self:IsPossessedByLocalPlayer() then
    net.Start("DrGBasePossessionCycleViewPresets")
    net.WriteEntity(self)
    net.WriteEntity(LocalPlayer())
    net.SendToServer()
  end
end

-- Functions --

function ENT:PossessorView()
  if not self:IsPossessed() then return end
  local current, preset = self:CurrentViewPreset()
  local center = self:WorldSpaceCenter()
  local eyes = self:GetPossessor():EyeAngles()
  local angles = Angle(-eyes.p, eyes.y + 180, 0)
  if current == -1 then
    return center, angles
  else
    if preset.invertpitch then
      angles.p = -angles.p
    end
    if preset.invertyaw then
      angles.y = -angles.y
    end
    if preset.eyepos then
      center = self:EyePos()
    elseif isstring(preset.bone) then
      local boneid = self:LookupBone(preset.bone)
      if boneid ~= nil then
        center = self:GetBonePosition(boneid)
      end
    end
    local offset = preset.offset or Vector(0, 0, 0)
    local forward = -Angle(0, angles.y, 0):Forward()
    local right = Angle(0, angles.y + 90, 0):Forward()
    local up = Angle(-90, 0, 0):Forward()
    local origin = center +
    forward*offset.x*self:GetModelScale() +
    right*offset.y*self:GetModelScale() +
    up*offset.z*self:GetModelScale()
    local tr1 = util.TraceLine({
      start = center,
      endpos = origin,
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    })
    if tr1.HitWorld then origin = tr1.HitPos + tr1.Normal*-10 end
    local distance = preset.distance or 1
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
end
function ENT:PossessorTrace(options)
  if not self:IsPossessed() then return end
  local origin, angles = self:PossessorView()
  options = options or {}
  options.filter = options.filter or {}
  table.insert(options.filter, self)
  if self:HasWeapon() then
    table.insert(options.filter, self:GetWeapon())
  end
  options.start = origin
  options.endpos = origin + angles:Forward()*999999999
  return util.TraceLine(options)
end
function ENT:PossessorNormal()
  local origin, angles = self:PossessorView()
  return angles:Forward()
end

function ENT:PossessionAddBind(bind, data)
  if not istable(data) then return end
  data.bind = bind
  data.client = CLIENT or false
  table.insert(self.PossessionBinds, data)
end

-- Hooks --

function ENT:OnPossess() end
function ENT:OnDispossess() end

-- Handlers --

function ENT:_InitPossession()
  if SERVER then
    self:SetPossessionEnabled(self.PossessionEnabled)
  end
  self:SetNWVarProxy("DrGBasePossessor", function(self, name, old, new)
    if not IsValid(old) and IsValid(new) then self:OnPossess(new)
    elseif IsValid(old) and not IsValid(new) then self:OnDispossess(old) end
  end)
end

function ENT:_HandlePossession(cor)
  if not self:IsPossessed() then return end
  local possessor = self:GetPossessor()
  if cor then
    local forward = possessor:KeyDown(IN_FORWARD)
    local backward = possessor:KeyDown(IN_BACK)
    local left = possessor:KeyDown(IN_MOVELEFT)
    local right = possessor:KeyDown(IN_MOVERIGHT)
    self:PossessionControls(forward and not backward, backward and not forward, right and not left, left and not right)
    if self.ClimbLadders and navmesh.IsLoaded() then
      local ladders = navmesh.GetNearestNavArea(self:GetPos()):GetLadders()
      for i, ladder in ipairs(ladders) do
        if self.ClimbLadderUp then
          if self:GetHullRangeSquaredTo(ladder:GetBottom()) < 20^2 then
            self:ClimbLadderUp(ladder)
            break
          end
        elseif self.ClimbLaddersDown then
          if self:GetHullRangeSquaredTo(ladder:GetTop()) < 20^2 then
            self:ClimbLadderDown(ladder)
            break
          end
        end
      end
    end
  elseif SERVER and not self:IsClimbing() then
    local origin, angles = self:PossessorView()
    self:SetAngles(Angle(0, angles.y, 0))
  end
  for i, move in ipairs(self.PossessionBinds) do
    if CLIENT and not move.client then continue end
    if SERVER and ((not cor and move.coroutine) or (cor and not move.coroutine)) then continue end
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

if SERVER then
  util.AddNetworkString("DrGBasePossessionCycleViewPresets")

  -- Getters/setters --

  function ENT:SetPossessionEnabled(bool)
    self:SetNW2Bool("DrGBasePossessionEnabled", bool)
    if not bool and self:IsPossessed() then self:Dispossess() end
  end

  -- Functions --

  function ENT:Possess(ply)
    if not self:IsPossessionEnabled() then return "disabled" end
    if self:IsPossessed() then return "already possessed" end
    if not IsValid(ply) then return "invalid" end
    if not ply:IsPlayer() then return "not player" end
    if not ply:Alive() then return "not alive" end
    if ply:DrG_IsPossessing() then return "already possessing" end
    if not self:CanPossess(ply) then return "not allowed" end
    drive.PlayerStartDriving(ply, self, "drive_drgbase_nextbot")
    if not ply:IsDrivingEntity(self) then return "error" end
    self:SetNW2Entity("DrGBasePossessor", ply)
    ply:SetNW2Entity("DrGBasePossessing", self)
    self:SetNW2Int("DrGBasePossessionView", 1)
    ply:SetNoTarget(true)
    return "ok"
  end

  function ENT:Dispossess()
    if not self:IsPossessed() then return "not possessed" end
    local ply = self:GetPossessor()
    if not self:CanDispossess(ply) then return "not allowed" end
    drive.PlayerStopDriving(ply)
    if ply:IsDrivingEntity(self) then return "error" end
    self:SetNW2Entity("DrGBasePossessor", nil)
    ply:SetNW2Entity("DrGBasePossessing", nil)
    ply:SetNoTarget(false)
    return "ok"
  end

  net.Receive("DrGBasePossessionCycleViewPresets", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    local ply = net.ReadEntity()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if ent:IsPossessed() and ent:GetPossessor() == ply then
      ent:CycleViewPresets()
    end
  end)

  -- Hooks --

  function ENT:CanPossess() return true end
  function ENT:CanDispossess() return true end
  function ENT:OnPossess() end
  function ENT:OnDispossess() end

  function ENT:PossessionControls(forward, backward, right, left)
    if forward then
      self:MoveForward()
    elseif backward then
      self:MoveBackward()
    end
    if right then
      self:MoveRight()
    elseif left then
      self:MoveLeft()
    end
  end

  -- Handlers --

  local function MoveEnt(ply, ent)
    if not ply:DrG_IsPossessing() then return end
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

  -- Getters/setters --

  function ENT:IsPossessedByLocalPlayer()
    return self:IsPossessed() and self:GetPossessor():EntIndex() == LocalPlayer():EntIndex()
  end

  -- Functions --

  -- Hooks --

  function ENT:PossessionHUD() end
  hook.Add("HUDPaint", "DrGBasePossessionHUD", function()
    local possessing = LocalPlayer():DrG_Possessing()
    if not IsValid(possessing) then return end
    local hookres = possessing:PossessionHUD()
    if hookres then return end
    -- draw possession hud

  end)

  function ENT:PossessionRender() end
  hook.Add("RenderScreenspaceEffects", "DrGBasePossessionDraw", function()
    local possessing = LocalPlayer():DrG_Possessing()
    if not IsValid(possessing) then return end
    possessing:PossessionRender()
  end)

  function ENT:PossessionHalos() end
  hook.Add("PreDrawHalos", "DrGBasePossessionHalos", function()
    local possessing = LocalPlayer():DrG_Possessing()
    if not IsValid(possessing) then return end
    possessing:PossessionHalos()
  end)

  -- Handlers --

end
