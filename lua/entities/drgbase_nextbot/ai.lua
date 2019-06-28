
-- Convars --

local EnemyRadius = CreateConVar("drgbase_enemy_radius", "5000", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- Getters/setters --

function ENT:IsAIDisabled()
  return self:GetNW2Bool("DrGBaseAIDisabled") or GetConVar("ai_disabled"):GetBool()
end

function ENT:GetEnemy()
  return self:GetNW2Entity("DrGBaseEnemy")
end
function ENT:HasEnemy()
  return IsValid(self:GetEnemy())
end
function ENT:HaveEnemy()
  return self:HasEnemy()
end

function ENT:GetNemesis()
  if self:HasNemesis() then
    return self:GetEnemy()
  else return NULL end
end
function ENT:HasNemesis()
  return self:GetNW2Bool("DrGBaseNemesis") and self:HasEnemy()
end
function ENT:HaveNemesis()
  return self:HasNemesis()
end

-- Functions --

-- Hooks --

function ENT:OnNewEnemy() end
function ENT:OnEnemyChange() end
function ENT:OnLastEnemy() end

-- Handlers --

function ENT:_InitAI()
  if SERVER then
    self._DrGBasePatrolPos = {}
    self._DrGBaseAllyDamageTolerance = {}
    self._DrGBaseAfraidOfDamageTolerance = {}
    self._DrGBaseNeutralDamageTolerance = {}
    self:LoopTimer(1, self.UpdateAI)
  end
  self:SetNWVarProxy("DrGBaseEnemy", function(self, name, old, new)
    if not self._DrGBaseHasEnemy and IsValid(new) then
      self._DrGBaseHasEnemy = true
      self:OnNewEnemy(new)
      if SERVER then self:BehaviourTreeEvent("NewEnemy", new) end
    elseif self._DrGBaseHasEnemy and not IsValid(new) then
      self._DrGBaseHasEnemy = false
      self:OnLastEnemy(old)
      if SERVER then self:BehaviourTreeEvent("LastEnemy", old) end
    else
      self:OnEnemyChange(old, new)
      if SERVER then self:BehaviourTreeEvent("EnemyChange", old, new) end
    end
  end)
end

if SERVER then

  -- Getters/setters --

  function ENT:SetAIDisabled(bool)
    local disabled = self:GetNW2Bool("DrGBaseAIDisabled")
    self:SetNW2Bool("DrGBaseAIDisabled", bool)
    if disabled and not bool then
      nextbot:UpdateAI()
    end
  end
  function ENT:DisableAI()
    self:SetAIDisabled(true)
  end
  function ENT:EnableAI()
    self:SetAIDisabled(false)
  end

  function ENT:SetEnemy(enemy)
    self:SetNW2Entity("DrGBaseEnemy", enemy)
    self:SetNW2Bool("DrGBaseNemesis", false)
  end
  function ENT:SetNemesis(nemesis)
    self:SetNW2Entity("DrGBaseEnemy", nemesis)
    self:SetNW2Bool("DrGBaseNemesis", true)
  end

  function ENT:AddPatrolPos(pos, i)
    if not isvector(pos) then return end
    if isnumber(i) then
      table.insert(self._DrGBasePatrolPos, i, pos)
      self:BehaviourTreeEvent("PatrolPos", self:GetPatrolPos(1))
    else
      table.insert(self._DrGBasePatrolPos, pos)
      self:BehaviourTreeEvent("PatrolPos", self:GetPatrolPos(1))
    end
  end
  function ENT:GetPatrolPos(i)
    return self._DrGBasePatrolPos[i]
  end
  function ENT:RemovePatrolPos(i)
    local pos = table.remove(self._DrGBasePatrolPos, i)
    self:BehaviourTreeEvent("PatrolPos", self:GetPatrolPos(1))
    return pos
  end

  -- Functions --

  function ENT:UpdateAI()
    self:UpdateEnemiesSight()
    self:UpdateEnemy()
  end

  function ENT:UpdateEnemy()
    local enemy
    if not self:IsPossessed() then
      if self:HasNemesis() then return self:GetNemesis() end
      enemy = self:OnUpdateEnemy()
      if not IsValid(enemy) or
      self:GetRangeSquaredTo(enemy) > EnemyRadius:GetFloat()^2 then
        enemy = NULL
      end
    else enemy = NULL end
    self:SetEnemy(enemy)
    return enemy
  end
  function ENT:FetchEnemy()
    if self:IsPossessed() then return NULL end
    local enemies = self:GetEnemies(true)
    table.sort(enemies, function(ent1, ent2)
      return self:OnFetchEnemy(ent1, ent2)
    end)
    local enemy = enemies[1]
    if not IsValid(enemy) then return NULL
    else return enemy end
  end

  function ENT:ClearPatrolPos()
    self._DrGBasePatrolPos = {}
    self:BehaviourTreeEvent("PatrolPos", self:GetPatrolPos(1))
  end
  function ENT:ShufflePatrolPos()
    table.sort(self._DrGBasePatrolPos, function()
      return math.random(2) == 1
    end)
    self:BehaviourTreeEvent("PatrolPos", self:GetPatrolPos(1))
  end
  function ENT:SortPatrolPos()
    table.sort(self._DrGBasePatrolPos, function(pos1, pos2)
      return self:GroundDistance(pos1) < self:GroundDistance(pos2)
    end)
    self:BehaviourTreeEvent("PatrolPos", self:GetPatrolPos(1))
  end

  -- Hooks --

  function ENT:OnRangeAttack() end
  function ENT:OnMeleeAttack() end
  function ENT:OnChaseEnemy() end
  function ENT:OnAvoidEnemy() end

  function ENT:OnReachedPatrol() end
  function ENT:OnPatrolUnreachable() end
  function ENT:WhilePatrolling() end

  function ENT:OnIdle() end

  function ENT:OnUpdateEnemy()
    return self:FetchEnemy()
  end
  function ENT:OnFetchEnemy(ent1, ent2)
    local disp1, prio1 = self:GetRelationship(ent1)
    local disp2, prio2 = self:GetRelationship(ent2)
    if prio1 > prio2 then return true
    elseif prio2 > prio1 then return false
    else
      return self:GetRangeSquaredTo(ent1) < self:GetRangeSquaredTo(ent2)
    end
  end

  function ENT:ShouldRun()
    return self:HasEnemy()
  end

  -- Handlers --

  cvars.AddChangeCallback("ai_disabled", function(name, old, new)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if not tobool(new) then nextbot:UpdateAI() end
    end
  end, "DrGBaseDisableAIUpdateBT")

end
