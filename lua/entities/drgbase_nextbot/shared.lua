ENT.Type = "nextbot"
ENT.Base = "base_nextbot"
ENT.IsDrGNextbot = true

-- Misc --
ENT.Models = {"models/player/kleiner.mdl"}
ENT.ModelScale = 1
ENT.Skins = {0}
ENT.CollisionBounds = Vector(15, 15, 72)
ENT.RagdollOnDeath = true
ENT.Killicon = {
  icon = "HUD/killicons/default",
  color = Color(255, 80, 0, 255)
}
ENT.Footsteps = {
  [MAT_ANTLION] = {
    "physics/flesh/flesh_impact_hard1.wav",
    "physics/flesh/flesh_impact_hard2.wav",
    "physics/flesh/flesh_impact_hard3.wav",
    "physics/flesh/flesh_impact_hard4.wav",
    "physics/flesh/flesh_impact_hard5.wav",
    "physics/flesh/flesh_impact_hard6.wav"
  },
  [MAT_BLOODYFLESH] = {
    "physics/flesh/flesh_squishy_impact_hard1.wav",
    "physics/flesh/flesh_squishy_impact_hard2.wav",
    "physics/flesh/flesh_squishy_impact_hard3.wav",
    "physics/flesh/flesh_squishy_impact_hard4.wav"
  },
  [MAT_CONCRETE] = {
    "player/footsteps/concrete1.wav",
    "player/footsteps/concrete2.wav",
    "player/footsteps/concrete3.wav",
    "player/footsteps/concrete4.wav"
  },
  [MAT_DIRT] = {
    "player/footsteps/dirt1.wav",
    "player/footsteps/dirt2.wav",
    "player/footsteps/dirt3.wav",
    "player/footsteps/dirt4.wav"
  },
  [MAT_EGGSHELL] = {
    "physics/flesh/flesh_impact_hard1.wav",
    "physics/flesh/flesh_impact_hard2.wav",
    "physics/flesh/flesh_impact_hard3.wav",
    "physics/flesh/flesh_impact_hard4.wav",
    "physics/flesh/flesh_impact_hard5.wav",
    "physics/flesh/flesh_impact_hard6.wav"
  },
  [MAT_FLESH] = {
    "physics/flesh/flesh_impact_hard1.wav",
    "physics/flesh/flesh_impact_hard2.wav",
    "physics/flesh/flesh_impact_hard3.wav",
    "physics/flesh/flesh_impact_hard4.wav",
    "physics/flesh/flesh_impact_hard5.wav",
    "physics/flesh/flesh_impact_hard6.wav"
  },
  [MAT_GRATE] = {
    "player/footsteps/chainlink1.wav",
    "player/footsteps/chainlink2.wav",
    "player/footsteps/chainlink3.wav",
    "player/footsteps/chainlink4.wav"
  },
  [MAT_ALIENFLESH] = {
    "physics/flesh/flesh_impact_hard1.wav",
    "physics/flesh/flesh_impact_hard2.wav",
    "physics/flesh/flesh_impact_hard3.wav",
    "physics/flesh/flesh_impact_hard4.wav",
    "physics/flesh/flesh_impact_hard5.wav",
    "physics/flesh/flesh_impact_hard6.wav"
  },
  [MAT_SNOW] = {
    "player/footsteps/grass1.wav",
    "player/footsteps/grass2.wav",
    "player/footsteps/grass3.wav",
    "player/footsteps/grass4.wav"
  },
  [MAT_PLASTIC] = {
    "physics/plastic/plastic_box_impact_soft1.wav",
    "physics/plastic/plastic_box_impact_soft2.wav",
    "physics/plastic/plastic_box_impact_soft3.wav",
    "physics/plastic/plastic_box_impact_soft4.wav"
  },
  [MAT_METAL] = {
    "player/footsteps/metal1.wav",
    "player/footsteps/metal2.wav",
    "player/footsteps/metal3.wav",
    "player/footsteps/metal4.wav"
  },
  [MAT_SAND] = {
    "player/footsteps/sand1.wav",
    "player/footsteps/sand2.wav",
    "player/footsteps/sand3.wav",
    "player/footsteps/sand4.wav"
  },
  [MAT_FOLIAGE] = {
    "player/footsteps/grass1.wav",
    "player/footsteps/grass2.wav",
    "player/footsteps/grass3.wav",
    "player/footsteps/grass4.wav"
  },
  [MAT_COMPUTER] = {
    "player/footsteps/metal1.wav",
    "player/footsteps/metal2.wav",
    "player/footsteps/metal3.wav",
    "player/footsteps/metal4.wav"
  },
  [MAT_SLOSH] = {
    "player/footsteps/slosh1.wav",
    "player/footsteps/slosh2.wav",
    "player/footsteps/slosh3.wav",
    "player/footsteps/slosh4.wav"
  },
  [MAT_TILE] = {
    "player/footsteps/tile1.wav",
    "player/footsteps/tile2.wav",
    "player/footsteps/tile3.wav",
    "player/footsteps/tile4.wav"
  },
  [MAT_GRASS] = {
    "player/footsteps/grass1.wav",
    "player/footsteps/grass2.wav",
    "player/footsteps/grass3.wav",
    "player/footsteps/grass4.wav"
  },
  [MAT_VENT] = {
    "player/footsteps/duct1.wav",
    "player/footsteps/duct2.wav",
    "player/footsteps/duct3.wav",
    "player/footsteps/duct4.wav"
  },
  [MAT_WOOD] = {
    "player/footsteps/wood1.wav",
    "player/footsteps/wood2.wav",
    "player/footsteps/wood3.wav",
    "player/footsteps/wood4.wav"
  },
  [MAT_DEFAULT] = {
    "player/footsteps/concrete1.wav",
    "player/footsteps/concrete2.wav",
    "player/footsteps/concrete3.wav",
    "player/footsteps/concrete4.wav"
  },
  [MAT_GLASS] = {
    "physics/glass/glass_sheet_step1.wav",
    "physics/glass/glass_sheet_step2.wav",
    "physics/glass/glass_sheet_step3.wav",
    "physics/glass/glass_sheet_step4.wav"
  },
  [MAT_WARPSHIELD] = {
    "physics/glass/glass_sheet_step1.wav",
    "physics/glass/glass_sheet_step2.wav",
    "physics/glass/glass_sheet_step3.wav",
    "physics/glass/glass_sheet_step4.wav"
  }
}

-- Stats --
ENT.SpawnHealth = 100
ENT.HealthRegen = 0
ENT.FallDamage = false
ENT.DamageMultipliers = {}

-- AI --
DrGBase.IncludeFile("ai.lua")
DrGBase.IncludeFile("memory.lua")
DrGBase.IncludeFile("relationships.lua")
ENT.PursueTime = 10
ENT.SearchTime = 50
ENT.Factions = {}
ENT.Frightening = false
ENT.EnemyReach = 250
ENT.EnemyStop = ENT.EnemyReach
ENT.EnemyAvoid = 100
ENT.AllyReach = 250
ENT.AfraidAvoid = 500
ENT.AttackAfraid = false
ENT.AllyDamageTolerance = 3
ENT.AllyDamagePriority = 99

-- Movements/animations --
DrGBase.IncludeFile("animations.lua")
DrGBase.IncludeFile("movements.lua")
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

-- Climbing --
ENT.ClimbWalls = false
ENT.ClimbLadders = false
ENT.ClimbLaddersUp = true
ENT.ClimbLaddersDown = false
ENT.ClimbWallsMaxHeight = math.huge
ENT.ClimbWallsMinHeight = 0
ENT.ClimbSpeed = 100
ENT.ClimbUpAnimation = ACT_CLIMB_UP
ENT.ClimbDownAnimation = ACT_CLIMB_DOWN
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(0, 0, 0)

-- Detection --
DrGBase.IncludeFile("detection.lua")
ENT.Omniscient = false
ENT.SightRange = math.huge
ENT.SightFOV = 150
ENT.SightDuration = 0
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
ENT.PossessionViews = {}
ENT.PossessionBinds = {}

-- Other --
DrGBase.IncludeFile("behaviours.lua")
DrGBase.IncludeFile("hooks.lua")
DrGBase.IncludeFile("meta.lua")
DrGBase.IncludeFile("misc.lua")
DrGBase.IncludeFile("path.lua")
DrGBase.IncludeFile("projectiles.lua")
DrGBase.IncludeFile("sounds.lua")

-- Convars --
local Radius = CreateConVar("drgbase_max_radius", "5000")

-- Initialize --

function ENT:Initialize()
  if SERVER then
    self:SetModel(self.Models[math.random(#self.Models)])
    self:SetModelScale(self.ModelScale)
    self:SetSkin(self.Skins[math.random(#self.Skins)])
    self:SetMaxHealth(self.SpawnHealth)
    self:SetHealth(self.SpawnHealth)
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    self:SetCollisionBounds(
      Vector(self.CollisionBounds.x, self.CollisionBounds.y, self.CollisionBounds.z),
      Vector(-self.CollisionBounds.x, -self.CollisionBounds.y, 0)
    )
    self:SetUseType(SIMPLE_USE)
    self:AddFlags(FL_OBJECT + FL_CLIENT)
    self.VJ_AddEntityToSNPCAttackList = true
    self.vFireIsCharacter = true
    self._DrGBaseCustomBehaviour = false
    self._DrGBaseCoroutineCalls = {}
    self._DrGBaseDamageMultipliers = {}
    for type, mult in pairs(self.DamageMultipliers) do
      self:SetDamageMultiplier(type, mult)
    end
  else
    self:SetIK(true)
  end
  self._DrGBaseBaseThinkDelay = 0
  self._DrGBaseCustomThinkDelay = 0
  self._DrGBasePossessionThinkDelay = 0
  self:_InitAnimations()
  self:_InitDetection()
  self:_InitMemory()
  self:_InitMisc()
  self:_InitMovements()
  self:_InitPossession()
  self:_InitRelationships()
  self:_InitWeapons()
  self:_InitAI()
  table.insert(DrGBase.Nextbots._Spawned, self)
  self:CallOnRemove("DrGBaseCallOnRemove", function()
    if SERVER then
      if self:IsPossessed() then self:Dispossess() end
    end
    table.RemoveByValue(DrGBase.Nextbots._Spawned, self)
    for i, sound in ipairs(self._DrGBaseEmitSounds) do
      self:StopSound(sound)
    end
    for i, sound in ipairs(self._DrGBaseLoopingSounds) do
      self:StopLoopingSound(sound)
    end
  end)
  self:_BaseInitialize()
  self:CustomInitialize()
  if SERVER and not navmesh.IsLoaded() then
    self:NoNavmesh()
    net.Start("DrGBaseNoNavmesh")
    net.WriteEntity(self)
    net.Broadcast()
  end
end
function ENT:_BaseInitialize() end
function ENT:CustomInitialize() end

-- Think --

function ENT:Think()
  self:_HandleMisc()
  self:_HandleAnimations()
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
  util.AddNetworkString("DrGBaseNoNavmesh")

  -- Getters --

  -- Setters --

  -- Functions --

  function ENT:UseCustomBehaviour(bool)
    if bool == nil then return self._DrGBaseCustomBehaviour
    elseif bool then self._DrGBaseCustomBehaviour = true
    else self._DrGBaseCustomBehaviour = false end
  end

  function ENT:CallInCoroutine(callback)
    table.insert(self._DrGBaseCoroutineCalls, {
      callback = callback,
      now = CurTime()
    })
  end
  function ENT:CoroutineCalls()
    return #self._DrGBaseCoroutineCalls > 0
  end

  -- Hooks --

  function ENT:NoNavmesh() end
  function ENT:OnSpawn() end
  function ENT:OnError() end
  function ENT:CustomBehaviour() end

  -- Handlers --

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
        self:_SetState(DRGBASE_STATE_ERROR)
    		self.BehaveThread = nil
        if not self:OnError(args) then
          ErrorNoHalt(self, " Error: ", args, "\n")
        end
    	end
  	end
  end

  function ENT:RunBehaviour()
    if not self._DrGBaseSpawned then
      self._DrGBaseSpawned = true
      self:OnSpawn()
    end
    while true do
      while self:CoroutineCalls() do
        local cor = table.remove(self._DrGBaseCoroutineCalls, 1)
        cor.callback(self, CurTime() - cor.now)
      end
      if self:IsPossessed() then
        self:_SetState(DRGBASE_STATE_POSSESSED)
        self:_HandlePossession(true)
      elseif not self:IsAIDisabled() then
        if self:UseCustomBehaviour() then
          self:_SetState(DRGBASE_STATE_AI_CUSTOM)
          self:CustomBehaviour()
        else self:_DefaultBehaviour() end
      else self:_SetState(DRGBASE_STATE_NONE) end
      coroutine.yield()
    end
  end

  -- SLVBase --

  if file.Exists("autorun/slvbase", "LUA") then
    function ENT:PercentageFrozen() return 0 end
  end

else

  local DisplayCollisions = CreateClientConVar("drgbase_display_collisions", "0")
  local DisplaySight = CreateClientConVar("drgbase_display_sight", "0")

  -- Getters --

  -- Setters --

  -- Functions --

  -- Hooks --

  function ENT:NoNavmesh() end
  net.Receive("DrGBaseNoNavmesh", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent:NoNavmesh()
  end)

  -- Handlers --

  function ENT:Draw()
    self:DrawModel()
    if GetConVar("developer"):GetBool() then
      if DisplayCollisions:GetBool() then
        local bound1, bound2 = self:GetCollisionBounds()
        local center = self:GetPos() + (bound1 + bound2)/2
        render.DrawWireframeBox(self:GetPos(), Angle(0, 0, 0), bound1, bound2, DrGBase.Colors.White, false)
        render.DrawLine(center, center + self:GetVelocity(), DrGBase.Colors.Orange, false)
        render.DrawWireframeSphere(center, 2*self:GetScale(), 4, 4, DrGBase.Colors.Orange, false)
      end
      if DisplaySight:GetBool() then
         local eyepos = self:EyePos()
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
