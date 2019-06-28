ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
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

-- Stats --
DrGBase.IncludeFile("status.lua")
ENT.SpawnHealth = 100
ENT.HealthRegen = 0
ENT.DamageMultipliers = {}
ENT.FallDamage = false

-- Sounds --
ENT.OnSpawnSounds = {}
ENT.OnIdleSounds = {}
ENT.IdleSoundDelay = 2
ENT.ClientIdleSounds = false
ENT.OnDamageSounds = {}
ENT.DamageSoundDelay = 0.25
ENT.OnDeathSounds = {}
ENT.Footsteps = {}

-- AI --
DrGBase.IncludeFile("ai.lua")
ENT.BehaviourTree = "BaseAI"
ENT.Omniscient = false
ENT.SpotDuration = 30
ENT.RangeAttackRange = 0
ENT.MeleeAttackRange = 50
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0

-- Relationships --
DrGBase.IncludeFile("relationships.lua")
ENT.Factions = {}
ENT.Frightening = false
ENT.AllyDamageTolerance = 0.33
ENT.AfraidDamageTolerance = 0.33
ENT.NeutralDamageTolerance = 0.33

-- Locomotion --
DrGBase.IncludeFile("locomotion.lua")
DrGBase.IncludeFile("path.lua")
ENT.Acceleration = 1000
ENT.Deceleration = 1000
ENT.JumpHeight = 50
ENT.StepHeight = 20
ENT.MaxYawRate = 250
ENT.DeathDropHeight = 200

-- Movements/animations --
DrGBase.IncludeFile("movements.lua")
DrGBase.IncludeFile("animations.lua")
ENT.WalkSpeed = 100
ENT.WalkAnimation = ACT_WALK
ENT.WalkAnimRate = 1
ENT.RunSpeed = 200
ENT.RunAnimation = ACT_RUN
ENT.RunAnimRate = 1
ENT.IdleAnimation = ACT_IDLE
ENT.IdleAnimRate = 1
ENT.JumpAnimation = ACT_JUMP
ENT.JumpAnimRate = 1
ENT.AnimMatchSpeed = true
ENT.AnimMatchDirection = true
ENT.UseWalkframes = false

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

-- Detection --
DrGBase.IncludeFile("awareness.lua")
DrGBase.IncludeFile("detection.lua")
ENT.SightFOV = 150
ENT.SightRange = math.huge
ENT.MinLuminosity = 0
ENT.MaxLuminosity = 1
ENT.EyeBone = ""
ENT.EyeOffset = Vector(0, 0, 0)
ENT.EyeAngle = Angle(0, 0, 0)
ENT.HearingCoefficient = 1

-- Weapons --
DrGBase.IncludeFile("weapons.lua")
ENT.UseWeapons = false
ENT.Weapons = {}
ENT.WeaponAccuracy = 1
ENT.WeaponAttachment = "Anim_Attachment_RH"
ENT.DropWeaponOnDeath = false
ENT.AcceptPlayerWeapons = false

-- Possession --
DrGBase.IncludeFile("possession.lua")
ENT.PossessionEnabled = false
ENT.PossessionPrompt = true
ENT.PossessionMovement = POSSESSION_MOVE_FORWARD
ENT.PossessionViews = {}
ENT.PossessionBinds = {}

-- Misc --
DrGBase.IncludeFile("drgbase/entity_helpers.lua")
DrGBase.IncludeFile("behaviours.lua")
DrGBase.IncludeFile("hooks.lua")
DrGBase.IncludeFile("misc.lua")

-- Initialize --
function ENT:Initialize()
  if SERVER then
    if istable(self.Models) and #self.Models > 0 then
      self:SetModel(self.Models[math.random(#self.Models)])
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
    self:SetMaxHealth(self.SpawnHealth)
    self:SetHealth(self.SpawnHealth)
    self:SetHealthRegen(self.HealthRegen)
    self:SetBloodColor(self.BloodColor)
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    self:SetCollisionBounds(
      Vector(self.CollisionBounds.x, self.CollisionBounds.y, self.CollisionBounds.z),
      Vector(-self.CollisionBounds.x, -self.CollisionBounds.y, 0)
    )
    self:SetUseType(SIMPLE_USE)
    self:AddFlags(FL_OBJECT + FL_CLIENT)
    self.VJ_AddEntityToSNPCAttackList = true
    self.vFireIsCharacter = true
    self._DrGBaseCorCalls = {}
  else self:SetIK(true) end
  self._DrGBaseBaseThinkDelay = 0
  self._DrGBaseCustomThinkDelay = 0
  self._DrGBasePossessionThinkDelay = 0
  self:_InitModules()
  table.insert(DrGBase._SpawnedNextbots, self)
  self:CallOnRemove("DrGBaseCallOnRemove", function(self)
    table.RemoveByValue(DrGBase._SpawnedNextbots, self)
    if isstring(self._DrGBaseIdleSound) then self:StopSound(self._DrGBaseIdleSound) end
    if SERVER and self:IsPossessed() then self:Dispossess() end
  end)
  self:_BaseInitialize()
  self:CustomInitialize()
  if CLIENT then return end
  --print(#DrGBase.GetNextbots())
  self:UpdateAI()
end
function ENT:_BaseInitialize() end
function ENT:CustomInitialize() end
function ENT:_InitModules()
  if SERVER then
    self:_InitLocomotion()
  end
  self:_InitMisc()
  self:_InitStatus()
  self:_InitAnimations()
  self:_InitMovements()
  self:_InitWeapons()
  self:_InitPossession()
  self:_InitRelationships()
  self:_InitAwareness()
  self:_InitDetection()
  self:_InitAI()
end

-- Think --
function ENT:Think()
  self:_HandleAnimations()
  if SERVER then
    -- on fire
    if self._DrGBaseIsOnFire and not self:IsOnFire() then
      self:OnExtinguish()
    end
    self._DrGBaseIsOnFire = self:IsOnFire()
    -- on ground
    local onGround = self:IsOnGround()
    if self:GetNW2Bool("DrGBaseOnGround") ~= onGround then
      self:SetNW2Bool("DrGBaseOnGround", onGround)
      if onGround then
        self:InvalidatePath()
      else

      end
      self:UpdateAnimation()
    end
    -- health
    local health = self:Health()
    if self:GetNW2Int("DrGBaseHealth") ~= health then
      self:SetNW2Int("DrGBaseHealth", health)
    end
    -- max health
    local maxHealth = self:GetMaxHealth()
    if self:GetNW2Int("DrGBaseMaxHealth") ~= maxHealth then
      self:SetNW2Int("DrGBaseMaxHealth", maxHealth)
    end
  end
  -- idle sounds
  if #self.OnIdleSounds > 0 then
    if (SERVER and not self.ClientIdleSounds) or
    (CLIENT and self.ClientIdleSounds) then
      self._DrGBaseIdleSound = self.OnIdleSounds[math.random(#self.OnIdleSounds)]
      local sound = self._DrGBaseIdleSound
      self:EmitSlotSound("DrGBaseIdleSounds", SoundDuration(sound) + self.IdleSoundDelay, sound)
    end
  end
  -- custom thinks
  if CurTime() > self._DrGBaseBaseThinkDelay then
    local delay = self:_BaseThink() or 0
    self._DrGBaseBaseThinkDelay = CurTime() + delay
  end
  if CurTime() > self._DrGBaseCustomThinkDelay then
    local delay = self:CustomThink() or 0
    self._DrGBaseCustomThinkDelay = CurTime() + delay
  end
  if self:IsPossessed() then
    self:_HandlePossession(false)
    if CLIENT and not self:IsPossessedByLocalPlayer() then return end
    if CurTime() > self._DrGBasePossessionThinkDelay then
      local delay = self:PossessionThink() or 0
      self._DrGBasePossessionThinkDelay = CurTime() + delay
    end
  end
end
function ENT:_BaseThink() end
function ENT:CustomThink() end
function ENT:PossessionThink() end

if SERVER then
  AddCSLuaFile()

  -- Sandbox support --

  hook.Add("PlayerSpawnedNPC", "DrGBasePlayerSpawnedNPC", function(ply, ent)
    if not ent.IsDrGNextbot then return end
    ent:SetCreator(ply)
    if ent:SpawnedBy(ply) == false then ent:Remove() end
  end)
  function ENT:SpawnedBy() end

  -- Behaviour tree --

  function ENT:GetBehaviourTree()
    return DrGBase.GetBehaviourTree(self.BehaviourTree)
  end
  function ENT:GetBT()
    return self:GetBehaviourTree()
  end

  function ENT:BehaviourTreeEvent(event, ...)
    local tree = self:GetBehaviourTree()
    if not tree then return end
    tree:Event(self, event, ...)
  end
  function ENT:BTEvent(event, ...)
    return self:BehaviourTreeEvent(event, ...)
  end

  -- Coroutine --

  function ENT:CallInCoroutine(callback, force)
    if force then
      local cor = self.BehaveThread
      self.BehaveThread = coroutine.create(function()
        callback(self, 0)
        if not IsValid(self) then return end
        self.BehaveThread = cor
      end)
    else
      table.insert(self._DrGBaseCorCalls, {
        callback = callback,
        now = CurTime()
      })
    end
  end
  function ENT:YieldCoroutine(interrompt)
    if interrompt then
      repeat
        if #self._DrGBaseCorCalls > 0 and not self._DrGBaseRunningCorCall then
          local cor = table.remove(self._DrGBaseCorCalls, 1)
          self._DrGBaseRunningCorCall = true
          cor.callback(self, CurTime() - cor.now)
          self._DrGBaseRunningCorCall = false
        end
        coroutine.yield()
      until not self:IsAIDisabled() or self:IsPossessed()
    else coroutine.yield() end
  end
  function ENT:PauseCoroutine(duration, interrompt)
    if isnumber(duration) and duration >= 0 then
      local now = CurTime()
      while CurTime() < now + duration do
        self:YieldCoroutine(interrompt)
      end
    else
      self._DrGBaseResumeCoroutine = false
      while not self._DrGBaseResumeCoroutine do
        self:YieldCoroutine(interrompt)
      end
      self._DrGBaseResumeCoroutine = nil
    end
  end
  function ENT:ResumeCoroutine()
    if self._DrGBaseResumeCoroutine ~= false then return end
    self._DrGBaseResumeCoroutine = true
  end

  function ENT:BehaveStart()
    self.BehaveThread = coroutine.create(function()
      self:RunBehaviour()
    end)
  end
  function ENT:BehaveUpdate(interval)
  	if not self.BehaveThread then return end
  	if coroutine.status(self.BehaveThread) == "dead" then
  		self.BehaveThread = nil
  		Msg(self, " Warning: ENT:RunBehaviour() has finished executing\n")
  	else
      local ok, args = coroutine.resume(self.BehaveThread)
    	if not ok then
    		self.BehaveThread = nil
        if not self:OnError(args) then
          ErrorNoHalt(self, " Error: ", args, "\n")
        end
    	end
  	end
  end

  function ENT:RunBehaviour()
    if #self.OnSpawnSounds > 0 then
      self:EmitSound(self.OnSpawnSounds[math.random(#self.OnSpawnSounds)])
    end
    self:OnSpawn()
    while true do
      if self:IsPossessed() then
        self:_HandlePossession(true)
      elseif not self:IsAIDisabled() then
        local tree = self:GetBehaviourTree()
        if tree then tree:Run(self)
        else self:AIBehaviour() end
      end
      self:YieldCoroutine(true)
    end
  end

  -- Hooks --

  function ENT:OnSpawn() end
  function ENT:OnError() end
  function ENT:AIBehaviour() end

  function ENT:OnExtinguish() end

  -- SLVBase compatibility --
  if file.Exists("autorun/slvbase", "LUA") then
    function ENT:PercentageFrozen() return 0 end
  end

else

  -- Draw --

  local DisplayCollisions = CreateClientConVar("drgbase_display_collisions", "0")
  local DisplaySight = CreateClientConVar("drgbase_display_sight", "0")

  function ENT:Draw()
    self:DrawModel()
    if GetConVar("developer"):GetBool() then
      if DisplayCollisions:GetBool() then
        local bound1, bound2 = self:GetCollisionBounds()
        local center = self:GetPos() + self:OBBCenter()
        render.DrawWireframeBox(self:GetPos(), Angle(0, 0, 0), bound1, bound2, DrGBase.CLR_WHITE, false)
        render.DrawLine(center, center + self:GetVelocity(), DrGBase.CLR_ORANGE, false)
        render.DrawWireframeSphere(center, 2*self:GetScale(), 4, 4, DrGBase.CLR_ORANGE, false)
      end
      if DisplaySight:GetBool() then
         local eyepos = self:EyePos()
         render.DrawWireframeSphere(eyepos, 2*self:GetScale(), 4, 4, DrGBase.CLR_GREEN, false)
         render.DrawLine(eyepos, eyepos + self:EyeAngles():Forward()*15, DrGBase.CLR_GREEN, false)
      end
    end
    self:_BaseDraw()
    self:CustomDraw()
    if self:IsPossessedByLocalPlayer() then
      self:PossessionDraw()
    end
  end
  function ENT:_BaseDraw() end
  function ENT:CustomDraw() end
  function ENT:PossessionDraw() end

end
