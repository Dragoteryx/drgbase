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
ENT.SpotDuration = 30
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
ENT.UseWalkframes = false
ENT.WalkSpeed = 100
ENT.RunSpeed = 200

-- Climbing --


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

-- Possession --
DrGBase.IncludeFile("possession.lua")

-- Misc --
DrGBase.IncludeFile("misc.lua")
DrGBase.IncludeFile("hooks.lua")
DrGBase.IncludeFile("deprecated.lua")

-- Convars --
local MultHealth = CreateConVar("drgbase_multiplier_health", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- Initialize --

function ENT:_DrGBasePreInitialize()
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
    self:JoinFactions(self.Factions)
    self.VJ_AddEntityToSNPCAttackList = true
    self.vFireIsCharacter = true
  else self:SetIK(true) end
  self:AddFlags(FL_OBJECT + FL_NPC)
  table.insert(DrGBase._NEXTBOTS, self)
end
function ENT:_DrGBasePostInitialize()
  if SERVER then
    self._DrGBaseRelationshipSystemReady = true
    self:UpdateRelationships()
  end
end

function ENT:Initialize(...) return self:CustomInitialize(...) end
function ENT:CustomInitialize() end -- backwards compatibility

-- Think --

function ENT:_DrGBasePreThink(...)
  if self:IsPossessed() then self:PossessionThink(...) end
end
function ENT:PossessionThink() end

function ENT:Think(...) return self:CustomThink(...) end
function ENT:CustomThink() end -- backwards compatibility

-- OnRemove --

function ENT:_DrGBaseOnRemove()
  if SERVER and self:IsPossessed() then self:StopPossession() end
  table.RemoveByValue(DrGBase._NEXTBOTS, self)
end
function ENT:OnRemove() end

if SERVER then
  AddCSLuaFile()

  -- Coroutine --

  ENT._DrGBaseCorReacts = {}
  ENT._DrGBaseCorCalls = {}

  local function Behave(self)
    while true do
      if self:IsPossessed() then
        self:_DrGBasePossessedBehaviour()
      else self:AIBehaviour() end
      self:YieldCoroutine(true)
    end
  end

  function ENT:BehaveStart()
    self.BehaveThread = coroutine.create(function()
      self:DoOnSpawn()
      Behave(self)
    end)
  end
  function ENT:BehaveRestart()
    self.BehaveThread = coroutine.create(function()
      Behave(self)
    end)
  end

  local IN_COROUTINE = nil
  function ENT:BehaveUpdate()
    if not self.BehaveThread then return end
    if coroutine.status(self.BehaveThread) ~= "dead" then
      local old_IN_COROUTINE = IN_COROUTINE
      IN_COROUTINE = self
      local ok, args = coroutine.resume(self.BehaveThread)
      IN_COROUTINE = old_IN_COROUTINE
      if not ok then
        ErrorNoHalt(self, " Error: ", args, "\n")
        if self:OnError(args) then self:BehaveRestart() end
      end
    else self.BehaveThread = nil end
  end
  function ENT:OnError()
    return self.RestartOnError
  end

  function ENT:InCoroutine()
    return IN_COROUTINE == self
  end

  function ENT:YieldCoroutine(interrupt)
    if not self._DrGBaseNextUpdate
    or CurTime() > self._DrGBaseNextUpdate then
      self._DrGBaseNextUpdate = CurTime() + 0.1
      self:UpdateAnimation()
      self:UpdateSpeed()
    end
    return self:YieldCoroutineNoUpdate(interrupt)
  end
  function ENT:YieldCoroutineNoUpdate(interrupt)
    if interrupt then
      local now = CurTime()
      if self._DrGBaseCorReacting or
      self._DrGBaseCorCalling then
        self._DrGBaseCorReacts = {}
      else
        if #self._DrGBaseCorCalls > 0 then
          self._DrGBaseCorCalling = true
          while #self._DrGBaseCorCalls > 0 do
            table.remove(self._DrGBaseCorCalls, 1)(self)
          end
          self._DrGBaseCorCalling = false
        end
        if #self._DrGBaseCorReacts > 0 then
          self._DrGBaseCorReacting = true
          while #self._DrGBaseCorReacts > 0 do
            table.remove(self._DrGBaseCorReacts, 1)(self)
          end
          self._DrGBaseCorReacting = false
        end
      end
      local yielded = CurTime() > now
      coroutine.yield()
      return yielded
    else
      self._DrGBaseCorReacts = {}
      coroutine.yield()
      return false
    end
  end

  function ENT:ReactInCoroutine(fn, ...)
    if not isfunction(fn) then return end
    if not self:InCoroutine() then
      local args, n = table.DrG_Pack(...)
      table.insert(self._DrGBaseCorReacts, function(self)
        fn(self, table.DrG_Unpack(args, n))
      end)
    else fn(self, ...) end
  end
  function ENT:CallInCoroutine(fn, ...)
    if not isfunction(fn) then return end
    if not self:InCoroutine() then
      local args, n = table.DrG_Pack(...)
      table.insert(self._DrGBaseCorCalls, function(self)
        fn(self, table.DrG_Unpack(args, n))
      end)
    else fn(self, ...) end
  end

  function ENT:OverrideCoroutine(fn, ...)
    if not isfunction(fn) then return end
    if not self:InCoroutine() then
      local args, n = table.DrG_Pack(...)
      local old_BehaveThread = self.BehaveThread
      self.BehaveThread = coroutine.create(function()
        fn(self, table.DrG_Unpack(args, n))
        self.BehaveThread = old_BehaveThread
      end)
    else fn(self, ...) end
  end
  -- imo CallInCoroutineOverride is an ugly name, but there you go Roach
  function ENT:CallInCoroutineOverride(fn, ...)
    return self:OverrideCoroutine(fn, ...)
  end

  -- SLVBase compatibility --
  if file.Exists("autorun/slvbase", "LUA") then
    function ENT:PercentageFrozen() return 0 end
  end

else

  -- Draw --

  function ENT:_DrGBasePostDraw()

  end

  function ENT:Draw()
    self:DrawModel()
    self:CustomDraw()
  end
  function ENT:CustomDraw() end -- backwards compatibility

end