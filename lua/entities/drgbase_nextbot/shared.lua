ENT.Type = "nextbot"
ENT.Base = "base_nextbot"
ENT._DrGBaseNextbot = true

function ENT:_Debug(text)
  DrGBase.Nextbot.Debug(self, text)
end

-- Getters --
function ENT:LineOfSight(ent, fov, range)
  if not IsValid(ent) then return false end
  if self:EntIndex() == ent:EntIndex() then return false end
  if range == nil then range = self.SightRange end
  local sqrdist = self:GetRangeSquaredTo(ent)
  if sqrdist > math.pow(range, 2) then return false end
  if fov == nil then fov = self.SightFOV end
  if fov > 360 then fov = 360 end
  if fov < 0 then fov = 0 end
  local halfFov = fov/2
  local entpos = ent:GetPos()
  local filter = {self}
  local min, max = ent:GetModelBounds()
  local endpos = {ent:WorldSpaceCenter()}
  if min ~= nil and max ~= nil then
    for i = math.Round(max.z/10)*ent:GetModelScale(), math.Round(min.z/10) do
      table.insert(endpos, entpos + Vector(0, 0, i*10))
    end
  end
  if SERVER then filter = {self, self:_Bullseye()} end
  return DrGBase.Utils.RunTraces({self:EyesPos()}, endpos, {filter = filter}, function(tr)
    if IsValid(tr.Entity) and
    tr.Entity:EntIndex() == ent:EntIndex() then
      local angles = self:GetAngles()
      angles.p = 0
      local normal = tr.Normal:Angle()
      if math.abs(math.AngleDifference(angles.y, normal.y)) <= halfFov and
      math.abs(math.AngleDifference(angles.p, normal.p)) <= halfFov then return true
      else return false end
    end
  end).res or false
end
function ENT:IsBlind()
  return self.SightFOV <= 0 or self.SightRange <= 0
end
function ENT:BullseyePos()
  return self:GetPos() + Vector(0, 0, self:Height()/2)
end
function ENT:EyesPos()
  local eyespos = self:BullseyePos()
  if self.EyesBone ~= nil then
    local boneid = self:LookupBone(self.EyesBone)
    if boneid ~= nil then
      eyespos = self:GetBonePosition(boneid)
    end
  end
  return eyespos
end
function ENT:Height()
  local bound1, bound2 = self:GetCollisionBounds()
  if bound1.z > bound2.z then return bound1.z-bound2.z
  elseif bound1.z < bound2.z then return bound2.z-bound1.z
  else return 0 end
end
function ENT:IsMoving()
  return self:Speed() > 0
end
function ENT:Speed()
  return self:GetVelocity():Length()
end
function ENT:SpeedSqr()
  return self:GetVelocity():LengthSqr()
end
function ENT:IsOnGround()
  return self._DrGBaseOnGround
end
function ENT:GetPossessor()
  return self._DrGBasePossessor
end
function ENT:IsPossessed()
  return self:GetPossessor() ~= nil
end
function ENT:GetState()
  return self._DrGBaseState
end
function ENT:GetTarget()
  return self._DrGBaseTarget
end
function ENT:GetDestination()
  return self._DrGBaseDestination
end
function ENT:Physgun()
  return self._DrGBasePhygun or false
end
function ENT:Altitude()
  local tr = util.TraceLine({
    start = self:GetPos(),
    endpos = self:GetPos() - Vector(0, 0, 999999),
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr.HitWorld then return self:GetPos().z - tr.HitPos.z
  else return nan end
end

-- QOL Hooks --

hook.Add("PhysgunPickup", "DrGBaseNextbotPhysgunPickup", function(ply, ent)
  if not ent:IsDrGBaseNextbot() then return end
  ent._DrGBasePhygun = true
  local res = ent:PhysgunPickup_DrG(ply)
  if SERVER then return res end
end)

hook.Add("PhysgunDrop", "DrGBaseNextbotPhysgunDrop", function(ply, ent)
  if not ent:IsDrGBaseNextbot() then return end
  ent._DrGBasePhygun = false
  if SERVER and not ent:IsOnGround() then
    ent._DrGBaseDisableFallDamage = true
  end
  ent:PhysgunDrop_DrG(ply)
end)

if SERVER then
  AddCSLuaFile("shared.lua")
  util.AddNetworkString("DrGBaseNextbotNewTarget")
  util.AddNetworkString("DrGBaseNextbotNoTarget")
  util.AddNetworkString("DrGBaseNextbotReachedTarget")
  util.AddNetworkString("DrGBaseNextbotNewDestination")
  util.AddNetworkString("DrGBaseNextbotNoDestination")
  util.AddNetworkString("DrGBaseNextbotReachedDestination")
  util.AddNetworkString("DrGBaseNextbotPossess")
  util.AddNetworkString("DrGBaseNextbotDispossess")
  util.AddNetworkString("DrGBaseNextbotCanPossess")
  util.AddNetworkString("DrGBaseNextbotCantPossess")
  util.AddNetworkString("DrGBaseNextbotOnStateChange")
  util.AddNetworkString("DrGBaseNextbotNoNavmesh")
  util.AddNetworkString("DrGBaseNextbotTouchGround")
  util.AddNetworkString("DrGBaseNextbotLeaveGround")
  util.AddNetworkString("DrGBaseNetworkHealth")

  hook.Add("PlayerSpawnedNPC", "DrGBaseNextbotPlayerSpawnedNPC", function(ply, ent)
    if not ent:IsDrGBaseNextbot() then return end
    ent:SetCreator(ply)
    local spawned = ent:SpawnedBy(ply)
    if spawned ~= nil and not spawned then ent:Remove() end
  end)

  function ENT:Initialize()
    self:SetModel(self.Models[math.random(#self.Models)])
    self:SetModelScale(self.ModelScale)
    self:SetSkin(self.Skins[math.random(#self.Skins)])
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    self:SetCollisionBounds(Vector(-8, -8, 0), Vector(8, 8, 70))
    self:SetCustomCollisionCheck(true)
    self:SetMaxHealth(self.MaxHealth)
    self:SetHealth(self.MaxHealth)
    self:SetUseType(SIMPLE_USE)
    self.loco:SetDeathDropHeight(self.loco:GetStepHeight())
    self._DrGBaseTargetPriorities = {}
    self._DrGBaseState = DRGBASE_NEXTBOT_STATE_NONE
    self._DrGBaseCombineBall = DRGBASE_NEXTBOT_COMBINE_BALL_DISSOLVE
    self._DrGBaseSpotted = {}
    self._DrGBaseMovementRefresh = 0
    self._DrGBaseSyncAnimation = true
    self._DrGBaseLastSpeed = 0
    self._DrGBaseDisableFallDamage = true
    self._DrGBaseZVelocity = 0
    self._DrGBaseSequenceRestarted = false
    self._DrGBaseCycle = 0
    self._DrGBaseAnimChange = 0
    self._DrGBaseLOSDelay = 0
    self._DrGBaseHealth = self.MaxHealth
    self.loco:SetDesiredSpeed(0)
    self:_Bullseye()
    self:Initialize_DrG()
    self:RefreshInteractions()
    table.insert(DrGBase.Nextbot._Spawned, self)
  end

  function ENT:BodyUpdate()
    if self:IsPossessed() then
      local moveX = math.Round(self:GetPoseParameter("move_x"), 1)
      local moveY = math.Round(self:GetPoseParameter("move_y"), 1)
      local possessor = self:GetPossessor()
      local front = possessor:KeyDown(IN_FORWARD)
      local back = possessor:KeyDown(IN_BACK)
      local left = possessor:KeyDown(IN_MOVELEFT)
      local right = possessor:KeyDown(IN_MOVERIGHT)
      if front and not back then
        self:SetPoseParameter("move_x", moveX+0.1)
      elseif back and not front then
        self:SetPoseParameter("move_x", moveX-0.1)
      elseif moveX > 0 then
        self:SetPoseParameter("move_x", moveX-0.1)
      elseif moveX < 0 then
        self:SetPoseParameter("move_x", moveX+0.1)
      end
      --[[if right and not left then
        self:SetPoseParameter("move_y", moveY+0.1)
      elseif left and not right then
        self:SetPoseParameter("move_y", moveY-0.1)
      elseif moveY > 0 then
        self:SetPoseParameter("move_y", moveY-0.1)
      elseif moveY < 0 then
        self:SetPoseParameter("move_y", moveY+0.1)
      end]]
    else
      self:SetPoseParameter("move_x", 1)
      self:SetPoseParameter("move_y", 0)
    end
    self:FrameAdvance()
  end

  function ENT:OnRemove()
    table.RemoveByValue(DrGBase.Nextbot._Spawned, self)
    if self:IsPossessed() then self:Dispossess() end
    return self:OnRemove_DrG()
  end

  function ENT:_Bullseye()
    while not IsValid(self._DrGBaseBullseye) do
      self._DrGBaseBullseye = ents.Create("npc_bullseye")
      self._DrGBaseBullseye:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
      self._DrGBaseBullseye:SetPos(self:BullseyePos())
      self._DrGBaseBullseye:Spawn()
      self._DrGBaseBullseye:Activate()
      self._DrGBaseBullseye:SetParent(self)
      self._DrGBaseBullseye:SetCustomCollisionCheck(true)
      self._DrGBaseBullseye._DrGBaseBullseyeNextbot = self
    end
    self._DrGBaseBullseye:SetPos(self:BullseyePos())
    self._DrGBaseBullseye:Extinguish()
    return self._DrGBaseBullseye
  end

  function ENT:Think()
    local state = self:GetState()
    self:_Bullseye()
    -- set speed / sync animations with speed and ground
    if CurTime() > self._DrGBaseMovementRefresh+0.1 and self._DrGBaseSyncAnimation then
      self._DrGBaseMovementRefresh = CurTime()
      local seq, rate = self:SyncAnimation(self:Speed(), self:IsOnGround())
      if rate == nil then rate = 1 end
      if rate ~= self._DrGBasePlaybackRate then self:SetPlaybackRate(rate) end
      if seq ~= nil and (rate ~= self._DrGBasePlaybackRate or
      self:GetCycle() < self._DrGBaseCycle or
      self:GetSequence() ~= self:LookupSequence(seq)) then
        self:ResetSequence(seq)
        local animchange = self._DrGBaseAnimChange+1
        local effects = DrGBase.Utils.PackTable(self:OnSyncedAnimation(seq, rate))
        if effects.n > 0 then
          for i = 1, effects.n do
            local effect = effects[i]
            if type(effect) ~= "table" then continue end
            if effect.delay == nil then effect.delay = {0} end
            if type(effect.delay) ~= "table" then effect.delay = {effect.delay} end
            for i, delay in ipairs(effect.delay) do
              if delay >= 0 then
                self:Timer_DrG(delay, function()
                  if self._DrGBaseAnimChange ~= animchange or self:GetCycle() < self._DrGBaseCycle then return end
                  if self:IsOnGround() and effect.footsteps ~= nil and #effect.footsteps > 0 then
                    self:EmitSound(effect.footsteps[math.random(#effect.footsteps)], nil, nil, nil, CHAN_BODY)
                  end
                  if effect.callback ~= nil then effect.callback() end
                end)
              end
            end
          end
        end
        self._DrGBaseAnimChange = self._DrGBaseAnimChange+1
      end
      self._DrGBaseCycle = self:GetCycle()
      self._DrGBasePlaybackRate = self:GetPlaybackRate()
    end
    -- network health
    if self:Health() ~= self._DrGBaseHealth then
      self._DrGBaseHealth = self:Health()
      net.Start("DrGBaseNetworkHealth")
      net.WriteEntity(self)
      net.WriteFloat(self._DrGBaseHealth)
      net.Broadcast()
    end
    -- fall damage
    if not self:IsOnGround() then
      self._DrGBaseZVelocity = self:GetVelocity().z*-1
    else self._DrGBaseZVelocity = 0 end
    -- fire
    if self:IsOnFire() then self:OnIgnite() end
    -- keep upright
    if self:IsOnGround() then
      self:AdjustAngles()
    end
    -- ambient sounds
    if #self.AmbientSounds > 0 and self._DrGBaseAmbientSound == nil then
      local ambient = self.AmbientSounds[math.random(#self.AmbientSounds)]
      self._DrGBaseAmbientSound = ambient.sound
      self:EmitSound(ambient.sound)
      self:Timer_DrG(ambient.duration, function()
        self._DrGBaseAmbientSound = nil
      end)
    end
    -- line of sight
    if CurTime() > self._DrGBaseLOSDelay then
      self._DrGBaseLOSDelay = CurTime() + 0.2
      for i, ent in ipairs(self._DrGBasePotentialTargets) do
        if self:CanSeeEntity(ent) then
          self:SpotEntity(ent)
        end
      end
    end
    -- turn left/right possession
    if self:IsPossessed() and not self:PossessionBlockInput() then
      local possessor = self:GetPossessor()
      local left = possessor:KeyDown(IN_MOVELEFT)
      local right = possessor:KeyDown(IN_MOVERIGHT)
      if left and not right then
        self:TurnLeft()
      elseif right and not left then
        self:TurnRight()
      end
      for i, move in ipairs(self.Possession.binds) do
        if move.coroutine then continue end
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
    -- call think hook
    return self:Think_DrG()
  end

  function ENT:Use(ply)
    self:Use_DrG(ply)
  end

  function ENT:RunBehaviour()
    if not navmesh.IsLoaded() then
      self:NoNavmesh()
      net.Start("DrGBaseNextbotNoNavmesh")
      net.WriteEntity(self)
      net.Broadcast()
    end

    while true do

      if self:IsPossessed() then -- check if the nextbot is possessed

        local possessor = self:GetPossessor()
        self:_SetState(DRGBASE_NEXTBOT_STATE_POSSESSED)
        local speed = self:PossessionGroundSpeed(possessor:KeyDown(IN_SPEED))
        if speed ~= nil then self:SetSpeed(speed) end
        if not self:PossessionBlockInput() then -- check input isn't disabled
          local front = possessor:KeyDown(IN_FORWARD)
          local back = possessor:KeyDown(IN_BACK)
          if front and not back then
            self:GoForward()
          elseif back and not front then
            self:GoBackward()
          end
          for i, move in ipairs(self.Possession.binds) do
            if not move.coroutine then continue end
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

      elseif not GetConVar("ai_disabled"):GetBool() and navmesh.IsLoaded() then -- the nextbot is not possessed

        if self:GetTarget() == nil then self:_SetTarget(self:FindTarget()) end
        if self:GetTarget() ~= nil then -- target
          self:_SetState(DRGBASE_NEXTBOT_STATE_TARGET)
          local speed = self:GroundSpeed(self:GetState())
          if speed ~= nil then self:SetSpeed(speed) end
          if self:MoveToPos_DrG(function()
            self:_SetTarget(self:FindTarget())
            if not IsValid(self:GetTarget()) then return
            else return self:GetTarget():GetPos() end
          end, {repath = 0.2, delay = 0.5}, function(path, options)
            self:_SetState(DRGBASE_NEXTBOT_STATE_TARGET)
            if GetConVar("ai_disabled"):GetBool() then return "aidisabled" end
            if self:IsPossessed() then return "possessed" end
            local target = self:FindTarget()
            if target == nil then return "notarget" end
            if self:GetRangeSquaredTo(target) <= math.pow(self.Reach, 2) and
            self:LineOfSight(target, 360, self.Reach*2) and not self:ReachedTarget(target) then
              net.Start("DrGBaseNextbotReachedTarget")
              net.WriteEntity(self)
              net.WriteEntity(target)
              net.Broadcast()
              return "ok"
            end
            options.repath = 0.15*#path:GetAllSegments()
            options.delay = options.repath
            return self:FollowTarget(target)
          end) == "close" then
            self:ForgetEntity(self:FindTarget())
          end
        else -- no target
          if self:GetDestination() == nil then self:SetDestination(self:FetchDestination()) end
          if self:GetDestination() ~= nil then
            self:_SetState(DRGBASE_NEXTBOT_STATE_DESTINATION)
            local speed = self:GroundSpeed(self:GetState())
            if speed ~= nil then self:SetSpeed(speed) end
            local reached = self:MoveToPos_DrG(function()
              return self:GetDestination()
            end, {repath = 0.05, delay = 0.5}, function(path, options)
              self:_SetState(DRGBASE_NEXTBOT_STATE_DESTINATION)
              local speed = self:GroundSpeed(self:GetState())
              if speed ~= nil then self:SetSpeed(speed) end
              if GetConVar("ai_disabled"):GetBool() then return "aidisabled" end
              if self:IsPossessed() then return "possessed" end
              if self:FindTarget() ~= nil then return "target" end
              return self:MovingToDestination(self:GetDestination())
            end)
            if reached == "ok" or reached == "close" then
              self:ReachedDestination(self:GetDestination(), reached == "ok")
              net.Start("DrGBaseNextbotReachedDestination")
              net.WriteEntity(self)
              net.WriteVector(self:GetDestination())
              net.WriteBool(reached == "ok")
              net.Broadcast()
              self:SetDestination(nil)
              self:Idle()
            end
          end
        end

      else
        self:_SetState(DRGBASE_NEXTBOT_STATE_NONE)
      end

      coroutine.yield()
    end
  end

  function ENT:FindTarget()
    local target = nil
    local priority = 0
    local distance = math.huge
    for i, ent in ipairs(self._DrGBasePotentialTargets) do
      if not IsValid(ent) or self:GetRangeSquaredTo(ent) > math.pow(self.Range, 2) then continue end
      local targetprio = self:TargetPriority(ent)
      if targetprio > 0 and self:HasSpottedEntity(ent) then
        local sqrdist = self:GetRangeSquaredTo(ent)
        if targetprio > priority or (targetprio == priority and distance > sqrdist) then
          priority = targetprio
          target = ent
          distance = sqrdist
        end
      else self:ForgetEntity(ent) end
    end
    return target
  end

  -- Relationships --

  local function CalcTargetPriority(self, ent)
    if not IsValid(ent) then return 0 end
    if self:EntIndex() == ent:EntIndex() then return 0 end
    if ent:GetClass() == "npc_bullseye" then return 0 end
    local res = self:FetchTargetPriority(ent)
    if res == nil or res < 0 then res = 0 end
    return res
  end

  function ENT:TargetPriority(ent)
    if not IsValid(ent) then return 0 end
    if ent:IsPlayer() and not ent:Alive() then return 0 end
    if ent.Health ~= nil and ent:Health() <= 0 then return 0 end
    if ent:IsPlayer() and IsValid(DrGBase.Nextbot.Possessing(ent)) then return 0 end
    if self:IsPossessed() then return 1 end
    if ent:IsPlayer() and GetConVar("ai_ignoreplayers"):GetBool() then return 0 end
    return self._DrGBaseTargetPriorities[ent:GetCreationID()] or 0
  end

  function ENT:SetTargetPriority(ent, value)
    if not IsValid(ent) then return end
    if value == nil or value < 0 then value = 0 end
    self:_Debug("setting target priority of '"..ent:GetClass().."' ("..ent:EntIndex()..") to "..value..".")
    if value > 0 then
      if not table.HasValue(self._DrGBasePotentialTargets, ent) then
        table.insert(self._DrGBasePotentialTargets, ent)
      end
    else table.RemoveByValue(self._DrGBasePotentialTargets, ent) end
    self._DrGBaseTargetPriorities[ent:GetCreationID()] = value
  end

  function ENT:RefreshTargetPriorities(ent)
    if not IsValid(ent) then
      self._DrGBasePotentialTargets = {}
      for i, ent in ipairs(ents.GetAll()) do
        self:SetTargetPriority(ent, CalcTargetPriority(self, ent))
      end
    else self:SetTargetPriority(ent, CalcTargetPriority(self, ent)) end
  end

  DrGBase.Net.DefineCallback("DrGBaseNextbotFetchTargetPriority", function(data)
    local nextbot = Entity(data.nextbot)
    local ent = Entity(data.ent)
    if IsValid(nextbot) and IsValid(ent) then
      return nextbot:TargetPriority(ent)
    end
  end)

  function ENT:NPCRelationship(npc)
    --[[local relationship = nil
    if self:IsPossessed() and DrGBase.Nextbot.ConVars.PossessionRelationships:GetBool() then
      relationship = npc:Disposition(self:GetPossessor())
    else relationship = self:FetchNPCRelationship(ent) end
    return relationship]]
    return self:FetchNPCRelationship(npc)
  end

  function ENT:RefreshNPCRelationships(ent)
    local bullseye = self:_Bullseye()
    if not IsValid(ent) then
      for i, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:IsNPC() and ent:GetClass() ~= "npc_bullseye" then
          self:SetNPCRelationship(ent, self:NPCRelationship(ent))
        end
      end
    elseif IsValid(ent) and ent:IsNPC() and ent:GetClass() ~= "npc_bullseye" then
      self:SetNPCRelationship(ent, self:NPCRelationship(ent))
    end
  end

  function ENT:SetNPCRelationship(npc, relationship)
    if npc:GetClass() == "npc_bullseye" then return end
    relationship = relationship or D_NU
    self:_Debug("setting relationship with '"..npc:GetClass().."' ("..npc:EntIndex()..") to "..relationship..".")
    npc:AddEntityRelationship(self:_Bullseye(), relationship, 100)
  end

  hook.Add("OnEntityCreated", "DrGBaseNextbotNPCRelationships", function(ent)
    for i, nextbot in ipairs(DrGBase.Nextbot.GetAll()) do
      if IsValid(ent) and ent:IsNPC() and ent:GetClass() ~= "npc_bullseye" then
        nextbot:SetNPCRelationship(ent, nextbot:NPCRelationship(ent))
      end
      nextbot:SetTargetPriority(ent, CalcTargetPriority(nextbot, ent))
    end
  end)

  function ENT:RefreshInteractions(ent)
    self:RefreshTargetPriorities(ent)
    self:RefreshNPCRelationships(ent)
  end

  function ENT:HasSpottedEntity(ent)
    if not IsValid(ent) then return false end
    if self.Omniscient then return true end
    if self._DrGBaseSpotted[ent:GetCreationID()] == nil then
    self._DrGBaseSpotted[ent:GetCreationID()] = 0 end
    return CurTime() < self._DrGBaseSpotted[ent:GetCreationID()] + self.ForgetTime
  end

  local onspotentity = false
  function ENT:SpotEntity(ent)
    if not IsValid(ent) then return end
    if not self:HasSpottedEntity(ent) then
      self:_Debug("spotted entity '"..ent:GetClass().."' ("..ent:EntIndex()..").")
    end
    self._DrGBaseSpotted[ent:GetCreationID()] = CurTime()
    if not onspotentity then
      onspotentity = true
      self:OnSpotEntity(ent)
      onspotentity = false
    end
  end

  function ENT:ForgetEntity(ent)
    if not IsValid(ent) then return end
    self._DrGBaseSpotted[ent:GetCreationID()] = 0
  end

  hook.Add("PostPlayerDeath", "DrGBaseNextbotPostPlayerDeathForget", function(ply)
    for i, nextbot in ipairs(DrGBase.Nextbot.GetAll()) do
      nextbot:ForgetEntity(ply)
    end
  end)

  function ENT:CanSeeEntity(ent)
    if self:IsBlind() then return false end
    if not self:LineOfSight(ent) then return false
    else
      local seen = self:OnSeeEntity(ent)
      if seen == nil then return true
      else return seen end
    end
  end

  -- hearing sounds
  hook.Add("EntityEmitSound", "DrGBaseEntityEmitSoundHearing", function(sound)
    if not IsValid(sound.Entity) or GetConVar("ai_disabled"):GetBool() then return end
    for i, ent in ipairs(DrGBase.Nextbot.GetAll()) do
      if ent.HearingRange > 0 and
      ent:GetRangeSquaredTo(sound.Entity) <= math.pow(ent.HearingRange, 2) then
        local heard = ent:OnHearEntity(sound.Entity, sound)
        if heard == nil or heard then ent:SpotEntity(sound.Entity) end
      end
    end
  end)

  -- hearing bullets
  hook.Add("EntityFireBullets", "DrgBaseEntityFireBullets", function(ent2, bullet)
    if not IsValid(ent2) or GetConVar("ai_disabled"):GetBool() then return end
    for i, ent in ipairs(DrGBase.Nextbot.GetAll()) do
      if ent.HearingRangeBullets > 0 and
      ent:GetRangeSquaredTo(ent2) <= math.pow(ent.HearingRangeBullets, 2) then
        local heard = ent:OnHearBullet(ent2, bullet)
        if heard == nil or heard then ent:SpotEntity(ent2) end
      end
    end
  end)

  -- Animations --

  function ENT:EnableSyncedAnimations(bool)
    if bool == nil then return self._DrGBaseSyncAnimation
    elseif bool then self._DrGBaseSyncAnimation = true
    else self._DrGBaseSyncAnimation = false end
  end

  function ENT:PlaySequenceAndWait(name, speed)
    local len = self:SetSequence(name)
    speed = speed or 1
    self:ResetSequenceInfo()
    self:SetCycle(0)
    self:SetPlaybackRate(speed)
    local synced = self:EnableSyncedAnimations()
    self:EnableSyncedAnimations(false)
    coroutine.wait(len/speed)
    self:EnableSyncedAnimations(synced)
  end

  function ENT:PlayGesture(name)
    self:AddGestureSequence(self:LookupSequence(name))
  end

  function ENT:ResetLookAt()
    self:SetPoseParameter("head_yaw", 0)
    self:SetPoseParameter("head_pitch", 0)
  end

  function ENT:LookAtPos(pos)
    local forward = self:GetForward():Angle()
    local direction = util.TraceLine({
      start = self:GetPos() + Vector(0, 0, 1),
      endpos = pos + Vector(0, 0, 1),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    }).Normal:Angle()
    self:SetPoseParameter("head_yaw", math.AngleDifference(direction.y, forward.y))
    self:SetPoseParameter("head_pitch", math.AngleDifference(direction.p, forward.p))
  end

  function ENT:LookAtEntity(ent)
    return self:LookAtPos(ent:GetPos())
  end

  -- Movement --

  function ENT:MoveToPos_DrG(dest, options, callback)
    options = options or {}
    options.tries = options.tries or math.huge
    local tries = 0
    local height = self:Height()
    if options.generator == nil then options.generator = function(area, fromArea, ladder, elevator, length)
      if tries > options.tries then return -1 end
      tries = tries + 1
      if not IsValid(fromArea) then return 0 end
      if not self.loco:IsAreaTraversable(area) then return -1 end
      local dist = 0
      if IsValid(ladder) then
        dist = ladder:GetLength()
      elseif length > 0 then
        dist = length
      else
        dist = (area:GetCenter() - fromArea:GetCenter()):GetLength()
      end
      local cost = dist + fromArea:GetCostSoFar()
      local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange(area)
      if deltaZ >= self.loco:GetStepHeight() then
        if deltaZ >= self.loco:GetMaxJumpHeight() then return -1 end -- too high
        local jumpPenalty = 5
        cost = cost + jumpPenalty * dist
      elseif deltaZ < -self.loco:GetDeathDropHeight() then return -1 end -- too low
      return cost
    end end
    options.lookahead = options.lookahead or 300
    options.tolerance = options.tolerance or 20
    options.maxage = options.maxage or math.huge
    options.repath = options.repath or math.huge
    options.delay = options.delay or 0
    if callback == nil then callback = function() end end
  	local path = Path("Follow")
    local maxage = CurTime() + options.maxage
    local stuck = false
    local pos = dest
    if type(dest) == "function" then pos = dest() end
    if pos == nil then return "failed" end
    pos = navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos)
    if pos == nil then return "failed" end
    local now = CurTime()
    self:_Debug("computing path to "..pos.x.." "..pos.y.." "..pos.z..".")
    local reached = DrGBase.Navmesh.ComputePath(path, self, pos, options.generator)
    self:_Debug("computed path ("..math.Round(CurTime()-now, 3).." seconds).")
    if not IsValid(path) then return "failed" end
    local oldpos = pos
  	while IsValid(path) do
      self._DrGBaseMoving = true
      if CurTime() > maxage then
        self._DrGBaseMoving = false
        return "timeout"
      end
      --[[if self.loco:GetVelocity():IsZero() and not stuck then
        self:Timer_DrG(1, function()
          if not self.loco:GetVelocity():IsZero() or stuck then return end
          stuck = true
        end)
      end]]
      if stuck or self.loco:IsStuck() then
        self:OnStuck()
        stuck = false
        self._DrGBaseMoving = false
        return "stuck"
      end
      local res = callback(path, options)
      if type(res) == "string" then
        self._DrGBaseMoving = false
        return res
      elseif res ~= nil then dest = res end
      path:SetMinLookAheadDistance(options.lookahead)
    	path:SetGoalTolerance(options.tolerance)
      if path:GetAge() > options.repath or self._DrGBaseShouldRebuildPath then
        if type(dest) == "function" then pos = dest() end
        if type(pos) ~= "Vector" then
          self._DrGBaseMoving = false
          return "failed"
        end
        if pos == nil then return "failed" end
        pos = navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos)
        if pos == nil then return "failed" end
        if pos ~= oldpos or self._DrGBaseShouldRebuildPath then
          self._DrGBaseShouldRebuildPath = false
          self:_Debug("computing path to "..pos.x.." "..pos.y.." "..pos.z..".")
          now = CurTime()
          reached = DrGBase.Navmesh.ComputePath(path, self, pos, options.generator)
          self:_Debug("computed path ("..math.Round(CurTime()-now, 3).." seconds).")
        else path:ResetAge() end
      end
      if not IsValid(path) then
        self._DrGBaseMoving = false
        return "failed"
      end
      if not reached then
        local segments = path:GetAllSegments()
        if #segments == 2 or
        segments[#segments-1].pos == path:GetCurrentGoal().pos then
          self._DrGBaseMoving = false
          return "close"
        end
      end
      oldpos = pos
      if options.draw then path:Draw() end
      path:Update(self)
      coroutine.yield()
  	end
    self._DrGBaseMoving = false
  	return "ok"
  end

  function ENT:RandomPos(maxradius, minradius)
    return DrGBase.Utils.RandomPos(self:GetPos(), maxradius, minradius)
  end

  function ENT:SetSpeed(speed)
    if speed == self._DrGBaseLastSpeed then return end
    self._DrGBaseLastSpeed = speed
    self:_Debug("speed set to "..speed..".")
    return self.loco:SetDesiredSpeed(speed)
  end

  function ENT:FacePos(pos)
    local angle = util.TraceLine({
      start = self:GetPos() + Vector(0, 0, 1),
      endpos = pos + Vector(0, 0, 1),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    }).Normal:Angle()
    angle.p = 0
    angle.r = 0
    self:SetAngles(angle)
  end

  function ENT:FaceEntity(ent)
    self:FacePos(ent:GetPos())
  end

  function ENT:GoForward()
    self.loco:Approach(self:GetPos() + self:GetForward(), 1)
  end

  function ENT:GoBackward()
    self.loco:Approach(self:GetPos() + self:GetForward()*-1, 1)
  end

  function ENT:StrafeLeft()
    self.loco:Approach(self:GetPos() + self:GetRight()*-1, 1)
  end

  function ENT:StrafeRight()
    self.loco:Approach(self:GetPos() + self:GetRight(), 1)
  end

  function ENT:TurnLeft()
    self:SetAngles(self:GetAngles() + Angle(0, 2, 0))
  end

  function ENT:TurnRight()
    self:SetAngles(self:GetAngles() + Angle(0, -2, 0))
  end

  -- Setters / server-side getters --

  function ENT:_SetState(state)
    local oldstate = self._DrGBaseState
    self._DrGBaseState = state
    if oldstate ~= state then
      if oldstate == nil then oldstate = DRGBASE_NEXTBOT_STATE_NONE end
      self:_Debug("state change ("..oldstate.." => "..state..")")
      self:OnStateChange(oldstate, state)
      net.Start("DrGBaseNextbotOnStateChange")
      net.WriteEntity(self)
      net.WriteFloat(oldstate)
      net.WriteFloat(state)
      net.Broadcast()
    end
  end

  function ENT:_SetTarget(target)
    if IsValid(target) then
      self._DrGBaseTarget = target
      net.Start("DrGBaseNextbotNewTarget")
      net.WriteEntity(self)
      net.WriteEntity(target)
      net.Broadcast()
    else
      self._DrGBaseTarget = nil
      net.Start("DrGBaseNextbotNoTarget")
      net.WriteEntity(self)
      net.Broadcast()
    end
  end

  function ENT:SetDestination(dest)
    if dest ~= nil then
      self._DrGBaseDestination = dest
      net.Start("DrGBaseNextbotNewDestination")
      net.WriteEntity(self)
      net.WriteVector(dest)
      net.Broadcast()
    else
      self._DrGBaseDestination = nil
      net.Start("DrGBaseNextbotNoDestination")
      net.WriteEntity(self)
      net.Broadcast()
    end
  end

  function ENT:CombineBall(enum)
    if enum == nil then
      return self._DrGBaseCombineBall
    else self._DrGBaseCombineBall = enum end
  end

  -- QOL --

  function ENT:Kill()
    local dmg = DamageInfo()
    dmg:SetDamage(self:Health())
    dmg:SetAttacker(self)
    self:TakeDamageInfo(dmg)
  end

  function ENT:AdjustAngles()
    local selfAngles = self:GetAngles()
    if self.ParallelToGround and self:IsOnGround() then
      selfAngles.p = 0
    else selfAngles.p = 0 end
    selfAngles.r = 0
    self:SetAngles(selfAngles)
  end

  -- Nextbot hooks --

  function ENT:OnContact(ent)
    if IsValid(ent._DrGBaseBullseyeNextbot) then return end
    self:_Debug("contact with '"..ent:GetClass().."' ("..ent:EntIndex()..").")
    if self._DrGBaseCharging then
      self._DrGBaseChargingEnt = ent
    end
    if ent:GetClass() == "prop_combine_ball" then
      local enum = self:CombineBall()
      if enum == DRGBASE_NEXTBOT_COMBINE_BALL_DISSOLVE then
        local dmg = DamageInfo()
        dmg:SetAttacker(ent:GetOwner())
        dmg:SetInflictor(ent)
        dmg:SetDamage(self:Health())
        dmg:SetDamageType(DMG_DISSOLVE)
        self:TakeDamageInfo(dmg)
      elseif enum == DRGBASE_NEXTBOT_COMBINE_BALL_BOUNCE then
        DrGBase.Error("DRGBASE_NEXTBOT_COMBINE_BALL_BOUNCE doesn't work.")
      elseif enum == DRGBASE_NEXTBOT_COMBINE_BALL_EXPLODE then
        ent:Fire("Explode", 0)
      end
    end
    local doors = ents.FindInSphere(ent:GetPos(), 20)
    for _, door in pairs(doors) do
      if (door:GetClass() == "func_door" or
      door:GetClass() == "prop_door_rotating") and
      not door._DrGBaseBreakingDoor then
        if self:CanOpenDoor(door, true) then
          door:Fire("Open")
          local closeDoor = self:CloseDoor(door)
          closeDoor = closeDoor or 0
          if closeDoor > 0 then
            self:Timer_DrG(closeDoor, function()
              if not IsValid(door) then return end
              door:Fire("Close")
            end)
          end
          if not self._DrGBaseOpeningDoor then
            self._DrGBaseOpeningDoor = true
            local collision = self:GetCollisionGroup()
            self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            self:Timer_DrG(1, function()
              self._DrGBaseOpeningDoor = false
              self:SetCollisionGroup(collision)
            end)
          end
        elseif self:CanBreakDoor(door, true) then
          door._DrGBaseBreakingDoor = true
          local delay = self:BreakDoorDelay(door)
          if delay == nil then delay = 0 end
          self:Timer_DrG(delay, function()
            if not IsValid(door) then return end
            door:Remove()
          end)
        end
      end
    end
    self:OnContact_DrG(ent)
  end

  function ENT:OnIgnite()
    self:_Debug("ignited.")
    if self:OnIgnite_DrG() then
      if vFireInstalled then
        local vFires = vFireGetFires(self)
        for _, fire in pairs(vFires) do
          fire:Remove()
        end
      else self:Extinguish() end
    end
  end

  -- transfer bullseye damage / prevent damage
  hook.Add("EntityTakeDamage", "DrGBaseNextbotDamage", function(ent, dmg)
    if ent._DrGBaseBullseyeNextbot ~= nil then
      ent._DrGBaseBullseyeNextbot:TakeDamageInfo(dmg)
      return true
    elseif ent:IsDrGBaseNextbot() then
      if dmg:GetDamage() <= 0 then return true end
      if ent:OnInjured_DrG(dmg, dmg:GetDamage() >= ent:Health()) then return true end
      ent:_Debug("take damage => "..dmg:GetDamage()..".")
    end
  end)

  function ENT:BecomeRagdoll_DrG(dmg)
    local model = self:GetModel()
    local skin = self:GetSkin()
    self:BecomeRagdoll(dmg)
    for i, ragdoll in ipairs(ents.FindByClass("prop_ragdoll")) do
      if ragdoll:GetModel() == model and
      ragdoll:GetSkin() == skin and
      ragdoll:GetCreationTime() == CurTime() then
        return ragdoll
      end
    end
  end
  function ENT:OnKilled(dmg)
    if self:OnKilled_DrG(dmg) then return end
    self:_Debug("killed.")
    local callback = self.RagdollCallback
    if self:HasWeapon() then self:DropWeapon() end
    if #self.DeathAnimations > 0 and false then
      local ammotype = dmg:GetAmmoType()
      local attacker = dmg:GetAttacker()
      local damage = dmg:GetDamage()
      local inflictor = dmg:GetInflictor()
      local force = dmg:GetDamageForce()
      local dmgtype = dmg:GetDamageType()
      local maxdmg = dmg:GetMaxDamage()
      local pos = dmg:GetReportedPosition()
      local model = self:GetModel()
      self:ClearBehaviours()
      self:Behaviour(function()
        self:PlaySequenceAndWait(self.DeathAnimations[math.random(#self.DeathAnimations)], self.DeathAnimationPlaybackRate)
        hook.Call("OnNPCKilled", GAMEMODE, self, attacker, inflictor)
        dmg = DamageInfo()
        dmg:SetAmmoType(ammotype)
        dmg:SetAttacker(attacker)
        dmg:SetDamage(damage)
        dmg:SetDamageType(dmgtype)
        dmg:SetDamageForce(force)
        dmg:SetMaxDamage(maxdmg)
        dmg:SetReportedPosition(pos)
        if self.RagdollOnDeath then
          local ragdoll = self:BecomeRagdoll_DrG(dmg)
          if ragdoll ~= nil then callback(ragdoll, dmg) end
        else self:Remove() end
      end)
    else
      hook.Call("OnNPCKilled", GAMEMODE, self, dmg:GetAttacker(), dmg:GetInflictor())
      if self.RagdollOnDeath then
        local ragdoll = self:BecomeRagdoll_DrG(dmg)
        if ragdoll ~= nil then callback(ragdoll, dmg) end
      else self:Remove() end
    end
  end

  function ENT:OnLandOnGround()
    self._DrGBaseOnGround = true
    self:_Debug("land on ground.")
    net.Start("DrGBaseNextbotTouchGround")
    net.WriteEntity(self)
    net.Broadcast()
    self:OnLandOnGround_DrG()
    if self._DrGBaseDisableFallDamage then self._DrGBaseDisableFallDamage = false
    elseif not self:Physgun() then
      self:_Debug("downwards velocity => "..self._DrGBaseZVelocity..".")
      local dmg = self:OnFallDamage(self._DrGBaseZVelocity, self:WaterLevel())
      self._DrGBaseZVelocity = 0
      dmg = dmg or 0
      if dmg > 0 then
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(dmg)
        dmginfo:SetDamageType(DMG_FALL)
        dmginfo:SetAttacker(self)
        self:TakeDamageInfo(dmginfo)
      end
    end
  end

  function ENT:OnLeaveGround()
    self._DrGBaseOnGround = true
    self:_Debug("leave ground.")
    net.Start("DrGBaseNextbotLeaveGround")
    net.WriteEntity(self)
    net.Broadcast()
    self:OnLeaveGround_DrG()
  end

  function ENT:OnNavAreaChanged(oldarea, newarea)
    self:_Debug("nav area changed.")
    self:AdjustAngles()
    self:OnNavAreaChanged_DrG(oldarea, newarea)
  end

  function ENT:OnOtherKilled(ent, dmg)
    self:_Debug("other killed.")
    self:OnOtherKilled_DrG(ent, dmg)
  end

  function ENT:OnStuck()
    if not self:IsPossessed() then
      self:_Debug("stuck!")
      local res = self:OnStuck_DrG()
      if res == nil or res then
        self:HandleStuck()
      end
    end
  end
  function ENT:OnUnStuck()
    self:_Debug("unstuck.")
    self:OnUnStuck_DrG()
  end
  function ENT:HandleStuck()
    self:SetPos(self:RandomPos(50))
    self.loco:ClearStuck()
  end

  -- Else --

  hook.Add("PhysgunPickup", "DrGBasePhysgunPickupBullseyeNextbot", function(ply, ent)
    if IsValid(ent._DrGBaseBullseyeNextbot) then
      return false
    end
  end)
  hook.Add("ShouldCollide", "DrGBaseNextbotShouldCollide", function(ent1, ent2)
    if IsValid(ent1._DrGBaseBullseyeNextbot) or IsValid(ent2._DrGBaseBullseyeNextbot) then
      return false
    end
  end)

  -- Possession --
  function ENT:Possess(ply, _client)
    if _client == nil then _client = false end
    if not IsValid(ply) then return DRGBASE_NEXTBOT_POSSESS_INVALID end
    if not ply:IsPlayer() then return DRGBASE_NEXTBOT_POSSESS_NOT_PLAYER end
    if not ply:Alive() then return DRGBASE_NEXTBOT_POSSESS_NOT_ALIVE end
    if self:IsPossessed() then return DRGBASE_NEXTBOT_POSSESS_NOT_EMPTY end
    local hookres = hook.Run("DrGBase-NextbotPossess", self, ply, _client)
    if hookres ~= nil and not hookres then return DRGBASE_NEXTBOT_POSSESS_NOT_ALLOWED end
    if IsValid(DrGBase.Nextbot.Possessing(ply)) then return DRGBASE_NEXTBOT_POSSESS_ALREADY end
    drive.PlayerStartDriving(ply, self, "drive_drgbase_nextbot")
    if not ply:IsDrivingEntity(self) then return DRGBASE_NEXTBOT_POSSESS_HOOK end
    self:OnPossess(ply)
    net.Start("DrGBaseNextbotPossess")
    net.WriteEntity(self)
    net.WriteEntity(ply)
    net.Broadcast()
    --self:SetSolidMask(MASK_NPCSOLID)
    ply._DrGBasePossessing = self
    self._DrGBasePossessor = ply
    self:_Debug("possessed by player '"..ply:Nick().."' ("..ply:EntIndex()..").")
    return DRGBASE_NEXTBOT_POSSESS_OK
  end

  function ENT:Dispossess(_client)
    if _client == nil then _client = false end
    if not self:IsPossessed() then return DRGBASE_NEXTBOT_DISPOSSESS_EMPTY end
    local possessor = self:GetPossessor()
    local hookres = hook.Run("DrGBase-NextbotDispossess", self, possessor, _client)
    if hookres ~= nil and not hookres then return DRGBASE_NEXTBOT_DISPOSSESS_NOT_ALLOWED end
    drive.PlayerStopDriving(possessor)
    if possessor:IsDrivingEntity(self) then return DRGBASE_NEXTBOT_DISPOSSESS_HOOK end
    self:OnDispossess(possessor)
    net.Start("DrGBaseNextbotDispossess")
    net.WriteEntity(self)
    net.WriteEntity(self._DrGBasePossessor)
    net.Broadcast()
    --self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
    possessor._DrGBasePossessing = nil
    self._DrGBasePossessor = nil
    self:_Debug("no longer possessed by player '"..possessor:Nick().."' ("..possessor:EntIndex()..").")
    return DRGBASE_NEXTBOT_DISPOSSESS_OK
  end

  function ENT:PossessionBlockInput(bool)
    if bool == nil then return self._DrGBaseBlockInput
    elseif bool then self._DrGBaseBlockInput = true
    else self._DrGBaseBlockInput = false end
  end

  -- Behaviours --
  function ENT:Idle(duration)
    duration = duration or self:IdleDuration()
    if duration == 0 then return end
    local delay = CurTime() + duration
    local targetdelay = 0
    while CurTime() < delay do
      if CurTime() > targetdelay then
        targetdelay = CurTime() + 0.2
        if IsValid(self:FindTarget()) then return end
      end
      if self:IsPossessed() then return end
      coroutine.yield()
    end
  end

  function ENT:Attack(attacks, onattack)
    if self._DrGBaseAttacking then return end
    if onattack == nil then onattack = function() end end
    for i, attack in ipairs(attacks) do
      self._DrGBaseAttacking = true
      attack.damage = attack.damage or 0
      attack.damagetype = attack.damagetype or DMG_DIRECT
      attack.force = attack.force or self:GetForward()*attack.damage
      attack.reach = attack.reach or self.Reach
      if attack.lineofsight == nil then attack.lineofsight = true end
      self:Timer_DrG(attack.delay, function()
        local targets = ents.FindInSphere(self:GetPos(), attack.reach)
        local hit = {}
        for i, target in ipairs(targets) do
          if self:TargetPriority(target) > 0 and
          self:GetRangeSquaredTo(target) <= math.pow(attack.reach, 2) and
          (not attack.lineofsight or self:LineOfSight(target, 90, attack.reach*2)) then
            local dmg = DamageInfo()
            dmg:SetAttacker(self)
            dmg:SetDamage(attack.damage)
            dmg:SetDamageType(attack.damagetype)
            dmg:SetDamageForce(attack.force)
            local phys = target:GetPhysicsObject()
            if IsValid(phys) then phys:AddVelocity(attack.force) end
            target:TakeDamageInfo(dmg)
            table.insert(hit, target)
          end
        end
        onattack(hit, i)
        if i == #attacks then
          self._DrGBaseAttacking = false
        end
      end)
    end
  end

  function ENT:Jump(pos, jumping, onland)
    if pos == nil then return end
    if type(pos) ~= "number" and type(pos) ~= "Vector" then pos = pos:GetPos() end
    if jumping == nil then jumping = function() end end
    if onland == nil then onland = function() end end
    local jumpheight = self.loco:GetMaxJumpHeight()
    if self:IsOnGround() then
      if type(pos) == "Vector" then
        self:FacePos(pos)
        self.loco:JumpAcrossGap(pos, util.TraceLine({
          start = self:GetPos() + Vector(0, 0, 1),
          endpos = pos + Vector(0, 0, 1),
          collisiongroup = COLLISION_GROUP_IN_VEHICLE
        }).Normal)
      elseif type(pos) == "number" then
        self.loco:SetJumpHeight(pos)
        self.loco:Jump()
      end
    end
    while not self:IsOnGround() do
      jumping()
      coroutine.yield()
    end
    self.loco:SetJumpHeight(jumpheight)
    onland(pos)
  end

  function ENT:Fly(jump, options, flying, onland)
    options = options or {}
    options.speed = options.speed or 100
    if flying == nil then flying = function() end end
    if onland == nil then onland = function() end end
    local jumping = true
    self:Jump(jump, function()
      if jumping then
        jumping = self.loco:GetVelocity().z > 0
        flying(false, true, false, options)
        return
      end
      local up = false
      local down = false
      if self:IsPossessed() then
        local possessor = self:GetPossessor()
        up = possessor:KeyDown(IN_JUMP)
        down = possessor:KeyDown(IN_DUCK)
      end
      local angs = self:GetAngles()
      if up and not down and options.up ~= nil then
        local velocity = angs:Forward()*options.speed
        velocity.z = options.up
        self.loco:SetVelocity(velocity)
        flying(true, true, false, options)
      elseif down and not up and options.down ~= nil then
        local velocity = angs:Forward()*options.speed
        velocity.z = -options.down
        self.loco:SetVelocity(velocity)
        flying(true, false, true, options)
      elseif options.drop ~= nil then
        local velocity = angs:Forward()*options.speed
        velocity.z = -options.drop
        self.loco:SetVelocity(velocity)
        flying(true, false, false, options)
      else flying(true, false, false, options) end
    end, onland)
  end

  function ENT:Charge(duration, callback, onstop)
    if self._DrGBaseCharging then return end
    if self._DrGBaseCharging then return end
    self._DrGBaseCharging = true
    duration = duration or 3
    if duration < 0 then duration = 0 end
    if callback == nil then callback = function() end end
    if onstop == nil then onstop = function() end end
    local delay = CurTime() + duration
    local start = CurTime()
    while CurTime() < delay do
      if callback(self._DrGBaseChargingEnt, start - CurTime(), CurTime() - delay) then break end
      self:GoForward()
      coroutine.yield()
    end
    self._DrGBaseCharging = false
    onstop()
  end

  -- Weapons --

  function ENT:GiveWeapon(class)
    if self:HasWeapon() then return false end
    local wep = ents.Create(class)
    wep:SetOwner(class)
	  wep:Spawn()
    return self:SetWeapon(wep)
  end

  function ENT:SetWeapon(wep)
    if self:HasWeapon() then return false end
    wep:SetPos(self:GetAttachment(self:LookupAttachment("anim_attachment_RH")).Pos)
    wep:SetSolid(SOLID_NONE)
	  wep:SetParent(self)
	  wep:Fire("setparentattachment", "anim_attachment_RH")
	  wep:AddEffects(EF_BONEMERGE)
    self._DrGBaseWeapon = wep
    wep._DrGBaseNextbot = self
    return true
  end

  function ENT:HasWeapon()
    return IsValid(self:GetWeapon())
  end

  function ENT:GetWeapon()
    return self._DrGBaseWeapon
  end

  function ENT:RemoveWeapon()
    if not self:HasWeapon() then return false end
    self._DrGBaseWeapon:Remove()
    self._DrGBaseWeapon = nil
    return true
  end

  function ENT:DropWeapon()
    if not self:HasWeapon() then return false end
    local class = self:GetWeapon():GetClass()
    local angles = self:GetWeapon():GetAngles()
    self:RemoveWeapon()
    local wep = ents.Create(class)
	  wep:Spawn()
    wep:SetPos(self:GetAttachment(self:LookupAttachment("anim_attachment_RH")).Pos)
    wep:SetAngles(angles)
    return true
  end

  hook.Add("PlayerCanPickupWeapon", "DrGBaseNextbotPlayerCanPickupWeapon", function(ply, wep)
    if IsValid(wep._DrGBaseNextbot) then return false end
  end)

  -- conflicts with SLVBase 2 --
  if file.Exists("autorun/slvbase", "LUA") then
    function ENT:PercentageFrozen() return 0 end
  end

else

  function ENT:Initialize()
    if self._DrGBaseInitialized then return end
    self._DrGBaseInitialized = true
    -- do stuff
    self:Initialize_DrG()
  end

  function ENT:OnRemove()
    if #self.AmbientSounds > 0 and self._DrGBaseAmbientSound ~= nil then
      self:StopSound(self._DrGBaseAmbientSound)
    end
    self:OnRemove_DrG()
  end

  function ENT:Think()
    if not self._DrGBaseInitialized then
      self:Initialize()
    end
    self:MarkShadowAsDirty()
    self:Think_DrG()
  end

  -- Possession --

  function ENT:IsPossessedByLocalPlayer()
    return self._DrGBasePossessor ~= nil
  end

  -- Else --

  function ENT:GetRangeTo(pos)
    if type(pos) ~= "Vector" then pos = pos:GetPos() end
    return self:GetPos():Distance(pos)
  end
  function ENT:GetRangeSquaredTo(pos)
    if type(pos) ~= "Vector" then pos = pos:GetPos() end
    return self:GetPos():DistToSqr(pos)
  end

  function ENT:TargetPriority(ent, callback)
    DrGBase.Net.UseCallback("DrGBaseNextbotFetchTargetPriority", {
      nextbot = self:EntIndex(),
      ent = ent:EntIndex()
    }, callback)
  end

  net.Receive("DrGBaseNextbotNewTarget", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    local target = net.ReadEntity()
    if IsValid(target) then ent._DrGBaseTarget = target
    else ent._DrGBaseTarget = nil end
  end)

  net.Receive("DrGBaseNextbotNoTarget", function()
    local ent = net.ReadEntity()
    if IsValid(ent) then
      ent._DrGBaseTarget = nil
    end
  end)

  net.Receive("DrGBaseNextbotNewDestination", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent._DrGBaseDestination = net.ReadVector()
  end)

  net.Receive("DrGBaseNextbotNoDestination", function()
    local ent = net.ReadEntity()
    if IsValid(ent) then
      ent._DrGBaseDestination = nil
    end
  end)

  net.Receive("DrGBaseNextbotReachedTarget", function()
    local ent = net.ReadEntity()
    local target = net.ReadEntity()
    if IsValid(ent) and IsValid(target) and ent.ReachedTarget ~= nil then
      ent:ReachedTarget(target)
    end
  end)

  net.Receive("DrGBaseNextbotReachedDestination", function()
    local ent = net.ReadEntity()
    if IsValid(ent) and ent.ReachedDestination ~= nil then
      ent:ReachedDestination(ent, net.ReadVector(), net.ReadBool())
    end
  end)

  net.Receive("DrGBaseNextbotOnStateChange", function()
    local ent = net.ReadEntity()
    local oldstate = net.ReadFloat()
    local newstate = net.ReadFloat()
    if IsValid(ent) then
      ent._DrGBaseState = newstate
      if ent.OnStateChange == nil then return end
      ent:OnStateChange(oldstate, newstate)
    end
  end)

  net.Receive("DrGBaseNextbotPossess", function()
    local ent = net.ReadEntity()
    local possessor = net.ReadEntity()
    if IsValid(ent) and IsValid(possessor) then
      ent._DrGBasePossessor = possessor
      possessor._DrGBasePossessing = ent
      hook.Run("DrGBaseNextbotPossess", ent, possessor)
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
      hook.Run("DrGBaseNextbotPossess", ent, dispossessor)
      if ent.OnDispossess == nil then return end
      ent:OnDispossess(dispossessor)
    end
  end)

  net.Receive("DrGBaseNextbotNoNavmesh", function()
    local ent = net.ReadEntity()
    if ent.NoNavmesh ~= nil then
      ent:NoNavmesh()
    end
  end)

  net.Receive("DrGBaseNextbotTouchGround", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent._DrGBaseOnGround = true
  end)

  net.Receive("DrGBaseNextbotLeaveGround", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent._DrGBaseOnGround = false
  end)

  net.Receive("DrGBaseNetworkHealth", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent:SetHealth(net.ReadFloat())
  end)

end
