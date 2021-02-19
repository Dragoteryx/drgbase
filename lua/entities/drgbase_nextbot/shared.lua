ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
ENT.IsDrGEntity = true
ENT.IsDrGNextbot = true

-- Misc --
ENT.PrintName = "Template"
ENT.Category = "Other"
ENT.Models = {"models/player/kleiner.mdl"}
ENT.Skins = {0}
ENT.ModelScale = 1
ENT.CollisionBounds = Vector(10, 10, 72)
ENT.BloodColor = BLOOD_COLOR_RED
ENT.RagdollOnDeath = true

-- Status --
DrGBase.IncludeFile("status.lua")
ENT.SpawnHealth = 100
ENT.HealthRegen = 0
ENT.MinPhysDamage = 10
ENT.MinFallDamage = 10

-- AI --
DrGBase.IncludeFile("ai.lua")
DrGBase.IncludeFile("enemy.lua")
ENT.BehaviourType = AI_BEHAV_BASE
ENT.Omniscient = false
ENT.RangeAttackRange = 0
ENT.MeleeAttackRange = 50
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0
ENT.AvoidAfraidOfRange = 500
ENT.WatchAfraidOfRange = 750

-- Relationships --
DrGBase.IncludeFile("relationships.lua")
ENT.DefaultRelationship = D_NU
ENT.Factions = {}
ENT.Frightening = false
ENT.AllyDamageTolerance = 0.33
ENT.AfraidDamageTolerance = 0.33
ENT.NeutralDamageTolerance = 0.33

-- Detection --
DrGBase.IncludeFile("detection.lua")
ENT.EyeBone = ""
ENT.EyeOffset = Vector(0, 0, 0)
ENT.EyeAngle = Angle(0, 0, 0)
ENT.SightFOV = 150
ENT.SightRange = 15000
ENT.MinLuminosity = 0.2
ENT.MaxLuminosity = 1
ENT.HearingCoefficient = 1

-- Movements --
DrGBase.IncludeFile("movements.lua")
DrGBase.IncludeFile("sv_locomotion.lua")
DrGBase.IncludeFile("sv_path.lua")
ENT.UseWalkframes = false
ENT.WalkSpeed = 100
ENT.RunSpeed = 200

-- Climbing --
ENT.ClimbLedges = false
ENT.ClimbLedgesMaxHeight = math.huge
ENT.ClimbLedgesMinHeight = 0
ENT.LedgeDetectionDistance = 20
ENT.ClimbProps = false
ENT.ClimbLadders = false
ENT.ClimbLaddersUp = true
ENT.LaddersUpDistance = 20
ENT.ClimbLaddersUpMaxHeight = math.huge
ENT.ClimbLaddersUpMinHeight = 0
ENT.ClimbLaddersDown = false
ENT.LaddersDownDistance = 20
ENT.ClimbLaddersDownMaxHeight = math.huge
ENT.ClimbLaddersDownMinHeight = 0
ENT.ClimbSpeed = 60
ENT.ClimbUpAnimation = ACT_CLIMB_UP
ENT.ClimbDownAnimation = ACT_CLIMB_DOWN
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(0, 0, 0)

-- Locomotion --
ENT.Acceleration = 400
ENT.Deceleration = 400
ENT.MaxYawRate = 250
ENT.JumpHeight = 58
ENT.StepHeight = 20
ENT.DeathDropHeight = 200

-- Animations --
DrGBase.IncludeFile("animations.lua")
ENT.WalkAnimation = ACT_WALK
ENT.WalkAnimRate = 1
ENT.RunAnimation = ACT_RUN
ENT.RunAnimRate = 1
ENT.IdleAnimation = ACT_IDLE
ENT.IdleAnimRate = 1
ENT.JumpAnimation = ACT_JUMP
ENT.JumpAnimRate = 1

-- Sounds --


-- Weapons --
DrGBase.IncludeFile("weapons.lua")

-- Possession --
DrGBase.IncludeFile("possession.lua")
ENT.PossessionEnabled = false
ENT.PossessionPrompt = true
ENT.PossessionMove = POSSESSION_MOVE_1DIR
--ENT.PossessionViews = {{auto = true}}

-- Misc --
DrGBase.IncludeFile("drgbase/entity_helpers.lua")
DrGBase.IncludeFile("misc.lua")
DrGBase.IncludeFile("hooks.lua")
DrGBase.IncludeFile("deprecated.lua")

-- ConVars --

DrGBase.MultHealth = DrGBase.ConVar("drgbase_multiplier_health", "1")
DrGBase.MultSpeed = DrGBase.ConVar("drgbase_multiplier_speed", "1")

DrGBase.AllOmniscient = DrGBase.ConVar("drgbase_ai_omniscient", "0")
DrGBase.AIBlind = DrGBase.ConVar("drgbase_ai_blind", "0")
DrGBase.AIDeaf = DrGBase.ConVar("drgbase_ai_deaf", "0")
DrGBase.EnableRoam = DrGBase.ConVar("drgbase_ai_roam", "1")
DrGBase.TargetInsects = DrGBase.ConVar("drgbase_ai_target_insects", "0")
DrGBase.TargetRepMelons = DrGBase.ConVar("drgbase_ai_target_repmelons", "1")

DrGBase.PossessionEnabled = DrGBase.ConVar("drgbase_possession_enabled", "1")
DrGBase.LockOnEnabled = DrGBase.ConVar("drgbase_possession_lockon", "1")

DrGBase.PathfindingMode = DrGBase.ConVar("drgbase_pathfinding", "custom", "Pathfinding mode:\n"..
  "    'custom' => DrGBase custom pathfinding, allows climbing at the cost of performance\n"..
  "    'default' => default Garry's Mod nextbot pathfinding, more efficient than custom but dumber\n"..
  "    'none' => disable pathfinding entirely, best performance at the cost of having nextbots running into every wall")
DrGBase.ComputeDelay = DrGBase.ConVar("drgbase_compute_delay", "0.1")
DrGBase.AvoidObstacles = DrGBase.ConVar("drgbase_avoid_obstacles", "1")

DrGBase.RemoveRagdolls = DrGBase.ConVar("drgbase_ragdolls_remove", "-1")
DrGBase.RagdollFadeOut = DrGBase.ConVar("drgbase_ragdolls_fadeout", "3")
DrGBase.DisableRagCollisions = DrGBase.ConVar("drgbase_ragdolls_collisions_disabled", "0")

-- Initialize --

function ENT:DrG_PreInitialize()
  if SERVER then
    -- model
    if istable(self.Models) and #self.Models > 0 then
      self:SetModel(self.Models[math.random(#self.Models)])
    elseif isstring(self.Models) then
      self:SetModel(self.Models)
    end
    if istable(self.ModelScale) and #self.ModelScale == 2 then
      self:SetModelScale(self.ModelScale[math.random(2)])
    elseif isnumber(self.ModelScale) then
      self:SetModelScale(self.ModelScale)
    end
    if istable(self.Skins) and #self.Skins > 0 then
      self:SetSkin(self.Skins[math.random(#self.Skins)])
    elseif isnumber(self.Skins) then
      self:SetSkin(self.Skins)
    end
    -- status
    self:SetMaxHealth(self.SpawnHealth)
    self:SetHealth(self.SpawnHealth)
    self:ScaleHealth(DrGBase.MultHealth:GetFloat())
    -- vision
    self:SetMaxVisionRange(self.SightRange)
    self:SetFOV(self.SightFOV)
    -- collisions
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    if isvector(self.CollisionBounds) then
      self:SetCollisionBounds(
        Vector(-self.CollisionBounds.x, -self.CollisionBounds.y, 0),
        Vector(self.CollisionBounds.x, self.CollisionBounds.y, self.CollisionBounds.z)
      )
    else self:SetCollisionBounds(self:GetModelBounds()) end
    -- physics
    self:PhysicsInitShadow()
    self:AddCallback("PhysicsCollide", function(self, data)
      local ent = data.HitEntity
      if not IsValid(ent) then return end
      if ent:GetClass() == "prop_combine_ball" then
        ent:EmitSound("NPC_CombineBall.Impact")
      end
    end)
    -- locomotion --
    local scale = self:GetModelScale()
    self:SetAcceleration(self.Acceleration*scale)
    self:SetDeceleration(self.Deceleration*scale)
    self:SetMaxYawRate(self.MaxYawRate)
    self:SetJumpHeight(self.JumpHeight*scale)
    self:SetStepHeight(self.StepHeight*scale)
    self:SetDeathDropHeight(self.DeathDropHeight*scale)
    -- misc
    self:SetBloodColor(self.BloodColor)
    self:SetUseType(SIMPLE_USE)
    self:AddCallback("OnAngleChange", function(self, ang)
      if true then self:SetAngles(Angle(0, ang.y, 0)) end
    end)
    self:JoinFactions(self.Factions)
    self.VJ_AddEntityToSNPCAttackList = true
    self.vFireIsCharacter = true
    -- parallel coroutines
    local function UpdateEntity(ent)
      self:UpdateSight(ent)
      coroutine.yield()
    end
    self:ParallelCoroutine(function(self)
      while true do
        for hostile in self:HostileIterator() do
          UpdateEntity(hostile)
        end
        self:UpdateEnemy()
        coroutine.yield()
      end
    end)
    self:ParallelCoroutine(function(self)
      while true do
        for ally in self:AllyIterator() do UpdateEntity(ally) end
        coroutine.yield()
      end
    end)
    self:ParallelCoroutine(function()
      while true do
        for _, ply in ipairs(player.GetAll()) do UpdateEntity(ply) end
        coroutine.yield()
      end
    end)
    self:ParallelCoroutine(function(self)
      while true do
        for ent in pairs(self.DrG_InSight) do UpdateEntity(ent) end
        coroutine.yield()
      end
    end)
    self:ParallelCoroutine(function(self)
      while true do
        for ent, state in self:DetectedEntities() do
          if self:IsOmniscient() then break end
          local newState = self:OnUpdateDetectState(ent, state, CurTime() - self:GetDetectStateLastUpdate(ent))
          if newState then self:SetDetectState(ent, newState) end
          coroutine.yield()
        end
        coroutine.yield()
      end
    end)
  else self:SetIK(true) end
  self:AddFlags(FL_OBJECT + FL_NPC)
  table.insert(DrG_Nextbots, self)
end
function ENT:DrG_PostInitialize()
  if SERVER then self:InitRelationships() end
end

local CustomInitializeDeprecation = DrGBase.Deprecation("ENT:CustomInitialize()", "ENT:Initialize()")
function ENT:Initialize(...)
  if isfunction(self.CustomInitialize) then -- backwards compatibility
    CustomInitializeDeprecation()
    return self:CustomInitialize(...)
  end
end

-- Think --

function ENT:DrG_PreThink(...)
  -- anim events
  local seq = self:GetSequence()
  local curCycle = self:GetCycle()
  if seq ~= self.DrG_PrevSeq then
    self.DrG_PrevSeq = seq
    self.DrG_LastCycle = 0
    curCycle = 0
  end
  self:DrG_PlayAnimEvents(seq, curCycle, self.DrG_LastCycle)
  self.DrG_LastCycle = curCycle
  -- misca
  if SERVER then
    if self.DrG_OnFire and not self:IsOnFire() then
      self.DrG_OnFire = false
      self:OnExtinguish()
      self:ReactInCoroutine(self.DoExtinguish)
    end
  else
    local ply = LocalPlayer()
    if self:IsAbleToSee(ply) then
      self:OnEntitySightKept(ply)
    else self:OnEntityNotInSight(ply) end
  end
  -- possessiona
  if self:IsPossessed() then
    self:PossessionThink(...)
    self:PossessionBehaviour()
  end
end
function ENT:PossessionThink() end

local CustomThinkDeprecation = DrGBase.Deprecation("ENT:CustomThink()", "ENT:Think()")
function ENT:Think(...)
  if isfunction(self.CustomThink) then -- backwards compatibility
    CustomThinkDeprecation()
    return self:CustomThink(...)
  end
end

-- OnRemove --

function ENT:OnRemove() end
function ENT:DrG_OnRemove()
  if SERVER and self:IsPossessed() then self:StopPossession() end
  table.RemoveByValue(DrG_Nextbots, self)
end

if SERVER then
  AddCSLuaFile()

  -- Misc --

  hook.Add("EntityRemoved", "DrG/EntityRemovalCleanup", function(ent)
    for nb in DrGBase.NextbotIterator() do
      if ent == nb then continue end
      -- detection
      nb.DrG_DetectState[ent] = nil
      nb.DrG_DetectStateLastUpdate[ent] = nil
      nb.DrG_InSight[ent] = nil
      -- relationships
      nb.DrG_Relationships[ent] = nil
      nb.DrG_RelationshipCache[D_LI][ent] = nil
      nb.DrG_RelationshipCache[D_HT][ent] = nil
      nb.DrG_RelationshipCache[D_FR][ent] = nil
      nb.DrG_RelationshipCacheDetected[D_LI][ent] = nil
      nb.DrG_RelationshipCacheDetected[D_HT][ent] = nil
      nb.DrG_RelationshipCacheDetected[D_FR][ent] = nil
      nb.DrG_DefinedRelationships["Entity"][ent] = nil
      nb.DrG_IgnoredEntities[ent] = nil
    end
  end)

  -- Coroutine --

  ENT.DrG_ThrReacts = {}
  ENT.DrG_ThrCalls = {}

  local function RunBehaviour(self)
    while true do
      if self:IsPossessed() then
        self:PossessionBehaviour()
      elseif not self:IsAIDisabled() then
        self:AIBehaviour()
      end
      self:YieldCoroutine(true)
    end
  end

  function ENT:BehaveStart()
    self.BehaveThread = coroutine.create(function()
      self:DoSpawn()
      RunBehaviour(self)
    end)
  end
  function ENT:BehaveRestart()
    self.BehaveThread = coroutine.create(function()
      RunBehaviour(self)
    end)
  end

  function ENT:BehaveUpdate()
    if self.BehaveThread then
      if coroutine.status(self.BehaveThread) ~= "dead" then
        local ok, args = coroutine.resume(self.BehaveThread)
        if not ok then
          ErrorNoHalt(self, " Error: ", args, "\n")
          if self:OnError(args) then
            if isfunction(self.DoError) then
              self.BehaveThread = coroutine.create(function()
                self:DoError(args)
                RunBehaviour(self)
              end)
            else self:BehaveRestart() end
          end
        end
      else self.BehaveThread = nil end
    end
    local dead = {}
    for thr, done in pairs(self.DrG_ThrParallel) do
      local ok, args = coroutine.resume(thr)
      if coroutine.status(thr) == "dead" then
        dead[thr] = true
        if not ok then
          ErrorNoHalt(self, " Parallel Error: ", args, "\n")
          self:OnParallelError(args)
        else done(self, args) end
      end
    end
    for thr in pairs(dead) do
      self.DrG_ThrParallel[thr] = nil
    end
  end
  function ENT:OnError()
    return self.RestartOnError
  end
  function ENT:OnParallelError() end

  function ENT:YieldCoroutine(cancellable)
    if cancellable then
      local now = CurTime()
      self:UpdateAnimation(true)
      self:UpdateSpeed()
      local yielded = CurTime() > now
      return self:YieldNoUpdate(true) or yielded
    else
      self:UpdateAnimation(false)
      self:UpdateSpeed()
      return self:YieldNoUpdate(false)
    end
  end
  function ENT:YieldNoUpdate(cancellable)
    if cancellable then
      local now = CurTime()
      while #self.DrG_ThrCalls > 0 do
        table.remove(self.DrG_ThrCalls, 1)(self)
      end
      self:DoThink()
      if self:IsPossessed() then self:DoPossessionThink() end
      if CurTime() > now then self.DrG_ThrReacts = {} end
      while #self.DrG_ThrReacts > 0 do
        local reactNow = CurTime()
        table.remove(self.DrG_ThrReacts, 1)(self)
        if CurTime() > reactNow then self.DrG_ThrReacts = {} end
      end
      local yielded = CurTime() > now
      if not yielded then coroutine.yield() end
      return yielded
    else
      self.DrG_ThrReacts = {}
      coroutine.yield()
      return false
    end
  end

  function ENT:ReactInCoroutine(fn, arg1, ...)
    if not isfunction(fn) then return end
    if not self:InCoroutine() then
      local args, n = table.DrG_Pack(...)
      table.insert(self.DrG_ThrReacts, function(self)
        if isentity(arg1) and not IsValid(arg1) then return end
        fn(self, arg1, table.DrG_Unpack(args, n))
      end)
    else fn(self, arg1, ...) end
  end
  function ENT:CallInCoroutine(fn, ...)
    if not isfunction(fn) then return end
    if not self:InCoroutine() then
      local args, n = table.DrG_Pack(...)
      table.insert(self.DrG_ThrCalls, function(self)
        fn(self, table.DrG_Unpack(args, n))
      end)
    else fn(self, ...) end
  end
  function ENT:OverrideCoroutine(fn, ...)
    if not isfunction(fn) then return end
    if not self:InCoroutine() then
      local args, n = table.DrG_Pack(...)
      local BehaveThread = self.BehaveThread
      self.BehaveThread = coroutine.create(function()
        fn(self, table.DrG_Unpack(args, n))
        self.BehaveThread = BehaveThread
      end)
    else fn(self, ...) end
  end

  ENT.DrG_ThrParallel = {}
  function ENT:ParallelCoroutine(fn, done)
    if not isfunction(fn) then return end
    self.DrG_ThrParallel[coroutine.create(function()
      fn(self)
    end)] = done or function() end
  end

  function ENT:InCoroutine()
    return self.BehaveThread ~= nil and coroutine.status(self.BehaveThread) == "running"
  end

  -- SLVBase compatibility --
  if file.Exists("autorun/slvbase", "LUA") then
    function ENT:PercentageFrozen() return 0 end
  end

  -- Hooks --

  function ENT:DoThink() end
  function ENT:DoPossessionThink() end
  function ENT:DoSpawn(...) return self:OnSpawn(...) end
  function ENT:OnSpawn() end

else

  -- ConVars --

  DrGBase.BGMEnabled = DrGBase.SharedClientConVar("drgbase_bgm_enabled", "1")
  DrGBase.BGMVolume = DrGBase.ClientConVar("drgbase_bgm_volume", "1")

  DrGBase.DebugSight = DrGBase.ClientConVar("drgbase_debug_sight", "0")

  -- Draw --

  function ENT:DrG_PreDraw()
    if not DrGBase.DebugEnabled() then return end
    local ply = LocalPlayer()
    if not self:IsPossessedByLocalPlayer() and DrGBase.DebugSight:GetBool() then
      local clr = self:IsAbleToSee(LocalPlayer()) and DrGBase.CLR_GREEN or DrGBase.CLR_RED
      render.DrawLine(self:EyePos(), ply:WorldSpaceCenter(), clr, true)
    end
  end
  function ENT:DrG_PostDraw()
    if not DrGBase.DebugEnabled() then return end
  end

  local CustomDrawDeprecation = DrGBase.Deprecation("ENT:CustomDraw()", "ENT:Draw()")
  function ENT:Draw(...)
    self:DrawModel()
    if isfunction(self.CustomDraw) then -- backwards compatibility
      CustomDrawDeprecation()
      return self:CustomDraw(...)
    end
  end

end