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

-- Weapons --
DrGBase.IncludeFile("weapons.lua")

-- Possession --
DrGBase.IncludeFile("possession.lua")

-- Misc --
DrGBase.IncludeFile("misc.lua")
DrGBase.IncludeFile("hooks.lua")
DrGBase.IncludeFile("deprecated.lua")
DrGBase.IncludeFile("drgbase/entity_helpers.lua")

-- ConVars --
local MultHealth = DrGBase.ConVar("drgbase_multiplier_health", "1")

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
    self:ScaleHealth(MultHealth:GetFloat())
    -- vision
    self:SetMaxVisionRange(self.SightRange)
    self:SetFOV(self.SightFOV)
    -- collisions
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    if isvector(self.CollisionBounds) then
      self:SetCollisionBounds(
        Vector(self.CollisionBounds.x, self.CollisionBounds.y, self.CollisionBounds.z),
        Vector(-self.CollisionBounds.x, -self.CollisionBounds.y, 0)
      )
    else self:SetCollisionBounds(self:GetModelBounds()) end
    -- misc
    self:SetBloodColor(self.BloodColor)
    self:SetUseType(SIMPLE_USE)
    self:JoinFactions(self.Factions)
    self.VJ_AddEntityToSNPCAttackList = true
    self.vFireIsCharacter = true
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
  if SERVER then
    if self:IsOnGround() then self:SetAngles(Angle(0, self:GetAngles().y, 0)) end
    if self.DrG_OnFire and not self:IsOnFire() then
      self.DrG_OnFire = false
      self:OnExtinguish()
      self:ReactInThread(self.DoExtinguish)
    end
    if self:IsPossessed() then
      self:PossessionThink(...)
      self:DrG_PBehaviour(false)
    end
  else
    local ply = LocalPlayer()
    if self:IsAbleToSeeLocalPlayer() then
      self:OnEntitySightKept(ply)
    else self:OnEntityNotInSight(ply) end
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

function ENT:DrG_OnRemove()
  if SERVER and self:IsPossessed() then self:StopPossession() end
  table.RemoveByValue(DrG_Nextbots, self)
end
function ENT:OnRemove() end

if SERVER then
  AddCSLuaFile()

  -- Update behaviours --

  coroutine.DrG_RunThread("DrG/UpdateNextbots", function()
    while true do
      local yielded = false
      for nextbot in DrGBase.NextbotIterator() do
        if IsValid(nextbot) then
          yielded = true
          nextbot:UpdateSight()
          nextbot:UpdateEnemy()
          coroutine.yield()
        end
      end
      if not yielded then coroutine.yield() end
    end
  end)

  -- Coroutine --

  ENT.DrG_ThrReacts = {}
  ENT.DrG_ThrCalls = {}

  local function Behave(self)
    while true do
      if self:IsPossessed() then
        self:DrG_PBehaviour()
      else self:AIBehaviour() end
      self:YieldThread(true)
    end
  end

  function ENT:BehaveStart()
    self.BehaveThread = coroutine.create(function()
      self:DoSpawn()
      Behave(self)
    end)
  end
  function ENT:BehaveRestart()
    self.BehaveThread = coroutine.create(function()
      Behave(self)
    end)
  end

  function ENT:BehaveUpdate()
    if not self.BehaveThread then return end
    if coroutine.status(self.BehaveThread) ~= "dead" then
      local ok, args = coroutine.resume(self.BehaveThread)
      if not ok then
        ErrorNoHalt(self, " Error: ", args, "\n")
        if self:OnError(args) then self:BehaveRestart() end
      end
    else self.BehaveThread = nil end
  end
  function ENT:OnError()
    return self.RestartOnError
  end

  function ENT:YieldThread(cancellable)
    if cancellable then
      local now = CurTime()
      self:UpdateAnimation(true)
      self:UpdateSpeed()
      return self:YieldNoUpdate(true) or CurTime() > now
    else
      self:UpdateAnimation(false)
      self:UpdateSpeed()
      return self:YieldNoUpdate(false)
    end
  end
  function ENT:YieldNoUpdate(cancellable)
    if cancellable then
      local now = CurTime()
      while true do
        local innerNow = CurTime()
        while #self.DrG_ThrCalls > 0 do
          table.remove(self.DrG_ThrCalls, 1)(self)
        end
        self:DoThink()
        if CurTime() > innerNow then self.DrG_ThrReacts = {} end
        while #self.DrG_ThrReacts > 0 do
          local reactNow = CurTime()
          table.remove(self.DrG_ThrReacts, 1)(self)
          if CurTime() > reactNow then self.DrG_ThrReacts = {} end
        end
        if not self:IsAIDisabled() or self:IsPossessed() then break
        else coroutine.yield() end
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

  function ENT:ReactInThread(fn, arg1, ...)
    if not isfunction(fn) then return end
    local args, n = table.DrG_Pack(...)
    table.insert(self.DrG_ThrReacts, function(self)
      if isentity(arg1) and not IsValid(arg1) then return end
      fn(self, arg1, table.DrG_Unpack(args, n))
    end)
  end
  function ENT:CallInThread(fn, ...)
    if not isfunction(fn) then return end
    local args, n = table.DrG_Pack(...)
    table.insert(self.DrG_ThrCalls, function(self)
      fn(self, table.DrG_Unpack(args, n))
    end)
  end
  function ENT:OverrideThread(fn, ...)
    if not isfunction(fn) then return end
    local args, n = table.DrG_Pack(...)
    local old_BehaveThread = self.BehaveThread
    self.BehaveThread = coroutine.create(function()
      fn(self, table.DrG_Unpack(args, n))
      self.BehaveThread = old_BehaveThread
    end)
  end

  -- imo CallInCoroutineOverride is an ugly name, but there you go Roach
  function ENT:CallInCoroutineOverride(fn, ...)
    return self:OverrideThread(fn, ...)
  end

  -- SLVBase compatibility --
  if file.Exists("autorun/slvbase", "LUA") then
    function ENT:PercentageFrozen() return 0 end
  end

  -- Hooks --

  function ENT:DoThink() end
  function ENT:DoSpawn(...) return self:OnSpawn(...) end
  function ENT:OnSpawn() end

  function ENT:HandleAnimEvent() end

else

  -- ConVars --

  local DebugSight = DrGBase.ClientConVar("drgbase_debug_sight", "0")

  -- Misc --

  function ENT:FireAnimationEvent() end

  -- Draw --

  function ENT:DrG_PreDraw()
    if not DrGBase.DebugEnabled() then return end
    local ply = LocalPlayer()
    if DebugSight:GetBool() then
      local clr = self:IsAbleToSeeLocalPlayer() and DrGBase.CLR_GREEN or DrGBase.CLR_RED
      render.DrawLine(self:EyePos(), ply:WorldSpaceCenter(), clr, true)
    end
  end
  function ENT:DrG_PostDraw()
    if not GetConVar("developer"):GetBool() then return end
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