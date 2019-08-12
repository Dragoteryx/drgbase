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

-- Stats --
DrGBase.IncludeFile("status.lua")
ENT.SpawnHealth = 100
ENT.HealthRegen = 0
ENT.MinPhysDamage = 10
ENT.MinFallDamage = 10

-- Sounds --
ENT.OnSpawnSounds = {}
ENT.OnIdleSounds = {}
ENT.IdleSoundDelay = 2
ENT.ClientIdleSounds = false
ENT.OnDamageSounds = {}
ENT.DamageSoundDelay = 0.25
ENT.OnDeathSounds = {}
ENT.OnDownedSounds = {}
ENT.Footsteps = {}

-- AI --
DrGBase.IncludeFile("ai.lua")
ENT.Omniscient = false
ENT.SpotDuration = 30
ENT.RangeAttackRange = 0
ENT.MeleeAttackRange = 50
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0
ENT.AvoidAfraidOfRange = 500
ENT.WatchAfraidOfRange = 750

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

-- Animations --
DrGBase.IncludeFile("movements.lua")
DrGBase.IncludeFile("animations.lua")
ENT.WalkAnimation = ACT_WALK
ENT.WalkAnimRate = 1
ENT.RunAnimation = ACT_RUN
ENT.RunAnimRate = 1
ENT.IdleAnimation = ACT_IDLE
ENT.IdleAnimRate = 1
ENT.JumpAnimation = ACT_JUMP
ENT.JumpAnimRate = 1

-- Movements --
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

-- Detection --
DrGBase.IncludeFile("awareness.lua")
DrGBase.IncludeFile("detection.lua")
ENT.EyeBone = ""
ENT.EyeOffset = Vector(0, 0, 0)
ENT.EyeAngle = Angle(0, 0, 0)
ENT.SightFOV = 150
ENT.SightRange = 15000
ENT.MinLuminosity = 0
ENT.MaxLuminosity = 1
ENT.HearingCoefficient = 1

-- Weapons --
DrGBase.IncludeFile("weapons2.lua")
ENT.UseWeapons = false
ENT.Weapons = {}
ENT.WeaponAccuracy = 1
ENT.DropWeaponOnDeath = false
ENT.AcceptPlayerWeapons = true

-- Possession --
DrGBase.IncludeFile("possession.lua")
ENT.PossessionEnabled = false
ENT.PossessionPrompt = true
ENT.PossessionCrosshair = false
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {}
ENT.PossessionBinds = {}

-- Misc --
DrGBase.IncludeFile("drgbase/entity_helpers.lua")
DrGBase.IncludeFile("behaviours.lua")
DrGBase.IncludeFile("hooks.lua")
DrGBase.IncludeFile("misc.lua")

-- Convars --
local NextbotTickrate = CreateConVar("drgbase_nextbot_tickrate", "-1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local MultHealth = CreateConVar("drgbase_multiplier_health", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local EnablePatrol = CreateConVar("drgbase_ai_patrol", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

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
    self:ScaleHealth(MultHealth:GetFloat())
    self:SetHealthRegen(self.HealthRegen)
    self:SetBloodColor(self.BloodColor)
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    if isvector(self.CollisionBounds) then
      self:SetCollisionBounds(
        Vector(self.CollisionBounds.x, self.CollisionBounds.y, self.CollisionBounds.z),
        Vector(-self.CollisionBounds.x, -self.CollisionBounds.y, 0)
      )
    else self:SetCollisionBounds(self:GetModelBounds()) end
    self:SetUseType(SIMPLE_USE)
    self.VJ_AddEntityToSNPCAttackList = true
    self.vFireIsCharacter = true
    self._DrGBaseCorCalls = {}
    self._DrGBaseWaterLevel = self:WaterLevel()
    self._DrGBaseDownSpeed = 0
  else self:SetIK(true) end
  self:AddFlags(FL_OBJECT + FL_NPC)
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
  --DrGBase.Print("Nextbots spawned: "..tostring(#DrGBase.GetNextbots()), {color = DrGBase.CLR_GREEN, chat = true})
  self:UpdateAI()
end
function ENT:_BaseInitialize() end
function ENT:CustomInitialize() end
function ENT:_InitModules()
  if SERVER then
    self:_InitLocomotion()
    self:_InitPath()
  end
  self:_InitHooks()
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
  self:_HandleMovements()
  if SERVER then
    -- water level
    local waterLevel = self:WaterLevel()
    if self._DrGBaseWaterLevel ~= waterLevel then
      self:OnWaterLevelChange(self._DrGBaseWaterLevel, waterLevel)
      self._DrGBaseWaterLevel = waterLevel
    end
    -- on fire
    if self._DrGBaseIsOnFire and not self:IsOnFire() then
      self:OnExtinguish()
    end
    self._DrGBaseIsOnFire = self:IsOnFire()
    -- update fall speed
    local speed = -self:GetVelocity().z
    self:Timer(0.1, function()
      self._DrGBaseDownSpeed = speed
    end)
    -- on ground
    local onGround = self:IsOnGround()
    if self:GetNW2Bool("DrGBaseOnGround") ~= onGround then
      self:SetNW2Bool("DrGBaseOnGround", onGround)
      if onGround then
        self:InvalidatePath()
        local damage = math.floor(self:OnFallDamage(self._DrGBaseDownSpeed))
        --print(damage)
        if damage > math.max(0, self.MinFallDamage) then
          local dmg = DamageInfo()
          dmg:SetDamage(damage)
          dmg:SetAttacker(self)
          dmg:SetInflictor(self)
          dmg:SetDamageType(DMG_FALL)
          self:TakeDamageInfo(dmg)
        end
      else

      end
      self:UpdateAnimation()
      self:UpdateSpeed()
    end
    -- health
    local health = self:Health()
    local oldHealth = self:GetNW2Int("DrGBaseHealth")
    if oldHealth ~= health then
      self:OnHealthChange(oldHealth, health)
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
  if self:IsPossessed() and (SERVER or self:IsPossessedByLocalPlayer()) then
    local possessor = self:GetPossessor()
    if SERVER then possessor:SetPos(self:GetPos()) end
    self:_HandlePossession(false)
    if CurTime() > self._DrGBasePossessionThinkDelay then
      local delay = self:PossessionThink(possessor) or 0
      self._DrGBasePossessionThinkDelay = CurTime() + delay
    end
  end
  if CLIENT then return end
  local tickrate = NextbotTickrate:GetFloat()
  if tickrate > 0 then
    self:NextThink(CurTime() + 1/tickrate)
    return true
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
    if ent:SpawnedBy(ply) ~= false then
      if not navmesh.IsLoaded() and tobool(ply:GetInfoNum("drgbase_navmesh_error", 1)) then
        local msg = "Nextbots need a navmesh to navigate around the map. "
        if game.SinglePlayer() then msg = msg.."You can generate a navmesh using the command 'nav_generate' in the console."
        else msg = msg.."If you are the server owner you can generate a navmesh using the command 'nav_generate' in the server console." end
        DrGBase.Error(msg.."\nSet 'drgbase_navmesh_error' to 0 to disable this message.", {player = ply, color = DrGBase.CLR_GREEN, chat = true})
      end
    else ent:Remove() end
  end)
  function ENT:SpawnedBy() end

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
      until not self:IsAIDisabled() or self:IsPossessed() or self._DrGBaseRunningCorCall
    else coroutine.yield() end
  end
  function ENT:PauseCoroutine(duration, interrompt)
    if isnumber(duration) then
      if duration <= 0 then return end
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
  	if coroutine.status(self.BehaveThread) ~= "dead" then
      local ok, args = coroutine.resume(self.BehaveThread)
    	if not ok then
    		self.BehaveThread = nil
        if not self:OnError(args) then
          ErrorNoHalt(self, " Error: ", args, "\n")
        else self:BehaveStart() end
    	end
  	else self.BehaveThread = nil end
  end

  function ENT:RunBehaviour()
    if not self._DrGBaseSpawned then
      self._DrGBaseSpawned = true
      if #self.OnSpawnSounds > 0 then
        self:EmitSound(self.OnSpawnSounds[math.random(#self.OnSpawnSounds)])
      end
      self:OnSpawn()
    end
    while true do
      self:_HandleBehaviour()
      self:YieldCoroutine(true)
    end
  end
  function ENT:_HandleBehaviour()
    if self:IsPossessed() then
      self:_HandlePossession(true)
    elseif not self:IsAIDisabled() then
      self:AIBehaviour()
    end
  end

  -- Net --

  function ENT:_HandleNetMessage(name, ply, ...) end

  -- Hooks --

  function ENT:OnSpawn() end
  function ENT:OnError() end

  function ENT:OnHealthChange() end
  function ENT:OnExtinguish() end
  function ENT:OnWaterLevelChange() end
  function ENT:OnFallDamage(speed)
    --return math.max(0, speed-self.loco:GetDeathDropHeight())/15
    return 0
  end

  -- SLVBase compatibility --
  if file.Exists("autorun/slvbase", "LUA") then
    function ENT:PercentageFrozen() return 0 end
  end

  -- AI Behaviour --

  function ENT:AIBehaviour()
    if self:HasEnemy() then
      self:ReactToEnemy()
      if not self:HasEnemy() then self:UpdateEnemy() end
    elseif isvector(self:GetPatrolPos(1)) then self:Patrol()
    else self:OnIdle() end
  end

  function ENT:ReactToEnemy()
    local enemy = self:GetEnemy()
    local relationship = self:GetRelationship(enemy)
    if relationship == D_HT then
      local visible = self:Visible(enemy)
      if not self:IsInRange(enemy, self.ReachEnemyRange) or not visible then
        if self:OnChaseEnemy(enemy) ~= true then
          if self:FollowPath(enemy) == "unreachable" then
            self:OnEnemyUnreachable(enemy)
          end
        end
      elseif self:IsInRange(enemy, self.AvoidEnemyRange) and visible and
      not self:IsInRange(enemy, self.MeleeAttackRange) then
        if self:OnAvoidEnemy(enemy) ~= true then
          local away = self:GetPos()*2 - enemy:GetPos()
          self:FollowPath(away)
        end
      elseif self:OnWatchEnemy(enemy) ~= true then self:FaceTowards(enemy) end
      if not IsValid(enemy) or not self:Visible(enemy) then return end
      if self:IsInRange(enemy, self.MeleeAttackRange) and
      self:OnMeleeAttack(enemy) ~= false then
      elseif self:IsInRange(enemy, self.RangeAttackRange) then
        self:OnRangeAttack(enemy)
      end
    elseif relationship == D_FR then
      local visible = self:Visible(enemy)
      if self:IsInRange(enemy, self.AvoidAfraidOfRange) and visible then
        if self:OnAvoidAfraidOf(enemy) ~= true then
          local away = self:GetPos()*2 - enemy:GetPos()
          self:FollowPath(away)
        end
      elseif self:OnWatchAfraidOf(enemy) ~= true then self:FaceTowards(enemy) end
      if not IsValid(enemy) or not self:Visible(enemy) then return end
      if self:IsInRange(enemy, self.MeleeAttackRange) and
      self:OnMeleeAttack(enemy) ~= false then
      elseif self:IsInRange(enemy, self.RangeAttackRange) then
        self:OnRangeAttack(enemy)
      end
    elseif isvector(self:GetPatrolPos(1)) then self:Patrol() end
  end

  function ENT:Patrol()
    if not EnablePatrol:GetBool() then return end
    local patrol = self:GetPatrolPos(1)
    local res = self:OnPatrolling(patrol)
    if not isbool(res) then
      local follow = self:FollowPath(patrol)
      if follow == "unreachable" then res = false
      elseif follow == "reached" then res = true end
    end
    if isbool(res) then
      if res then self:OnReachedPatrol(patrol)
      else self:OnPatrolUnreachable(patrol) end
      self:RemovePatrolPos(1)
    end
  end

else

  local NavmeshMessage = CreateClientConVar("drgbase_navmesh_error", "1", true, true)

  -- Net --

  function ENT:_HandleNetMessage(name, ...)
    local args, n = table.DrG_Pack(...)
    if name == "DrGBasePickupWeapon" then
      local weapon = args[1]
      if not IsValid(weapon) then return end
      self._DrGBaseWeapons[weapon:GetClass()] = weapon
      self:OnPickupWeapon(weapon, weapon:GetClass())
      return true
    elseif name == "DrGBaseDropWeapon" then
      local class = args[1]
      self._DrGBaseWeapons[class] = nil
      self:OnDropWeapon(NULL, class)
      return true
    end
  end

  -- Draw --

  local DisplayCollisions = CreateClientConVar("drgbase_display_collisions", "0")
  local DisplaySight = CreateClientConVar("drgbase_display_sight", "0")

  function ENT:Draw()
    if DrGBase.INFO_TOOL.Viewcam then
      local selected = LocalPlayer():DrG_GetSelectedEntities()[1]
      if selected == self then return end
    end
    self:DrawModel()
    self:_DrawDebug()
    self:_BaseDraw()
    self:CustomDraw()
    if self:IsPossessedByLocalPlayer() then
      self:PossessionDraw()
    end
  end
  function ENT:_BaseDraw() end
  function ENT:CustomDraw() end
  function ENT:PossessionDraw() end

  function ENT:_DrawDebug()
    if not GetConVar("developer"):GetBool() then return end
    if DisplayCollisions:GetBool() then
      local bound1, bound2 = self:GetCollisionBounds()
      local center = self:GetPos() + self:OBBCenter()
      render.DrawWireframeBox(self:GetPos(), Angle(0, 0, 0), bound1, bound2, DrGBase.CLR_WHITE, false)
      render.DrawLine(center, center + self:GetVelocity(), DrGBase.CLR_ORANGE, false)
      render.DrawWireframeSphere(center, 2*self:GetScale(), 4, 4, DrGBase.CLR_ORANGE, false)
    end
    if DisplaySight:GetBool() then
       local eyepos = self:EyePos()
       local color = self:WasInSight(LocalPlayer()) and DrGBase.CLR_GREEN or DrGBase.CLR_RED
       if self:IsPossessedByLocalPlayer() then color = DrGBase.CLR_ORANGE end
       render.DrawWireframeSphere(eyepos, 2*self:GetScale(), 4, 4, color, false)
       render.DrawLine(eyepos, eyepos + self:EyeAngles():Forward()*15, color, false)
    end
  end

end
