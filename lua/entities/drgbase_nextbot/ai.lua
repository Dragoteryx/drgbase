
-- Getters/setters --

function ENT:IsAIDisabled()
  return self:GetNW2Bool("DrGBaseAIDisabled") or GetConVar("ai_disabled"):GetBool()
end

function ENT:GetEnemy()
  if self:IsPossessed() then return NULL end
  return self:GetNW2Entity("DrGBaseEnemy")
end
function ENT:HasEnemy()
  return IsValid(self:GetEnemy())
end
function ENT:HaveEnemy()
  return self:HasEnemy()
end

-- Functions --

-- Hooks --

function ENT:OnNewEnemy() end
function ENT:OnEnemyChange() end
function ENT:OnLastEnemy() end

-- Handlers --

function ENT:_InitAI()
  if CLIENT then return end
  self._DrGBasePatrolPos = {}
  self._DrGBaseAllyDamageTolerance = {}
  self:RefreshEnemy()
  self:LoopTimer(0.5, function()
    self:RefreshEnemy()
  end)
  self:SetNWVarProxy("DrGBaseEnemy", function(self, name, old, new)
    if not self._DrGBaseHasEnemy and IsValid(new) then
      self._DrGBaseHasEnemy = true
      self:OnNewEnemy(new)
    elseif self._DrGBaseHasEnemy and not IsValid(new) then
      self._DrGBaseHasEnemy = false
      self:OnLastEnemy(old)
    else self:OnEnemyChange(old, new) end
    self:UpdateBehaviourTree()
  end)
  self:SetNWVarProxy("DrGBaseAIDisabled", function(self, name)
    self:UpdateBehaviourTree()
  end)
end

if SERVER then

  -- Getters/setters --

  function ENT:SetAIDisabled(bool)
    self:SetNW2Bool("DrGBaseAIDisabled", bool)
    self:UpdateBehaviourTree()
  end
  function ENT:DisableAI()
    self:SetAIDisabled(true)
  end
  function ENT:EnableAI()
    self:SetAIDisabled(false)
  end

  function ENT:SetEnemy(enemy)
    self:SetNW2Entity("DrGBaseEnemy", enemy)
  end

  function ENT:AddPatrolPos(pos, i)
    if not isvector(pos) then return end
    if isnumber(i) then
      table.insert(self._DrGBasePatrolPos, i, pos)
    else
      table.insert(self._DrGBasePatrolPos, pos)
    end
    self:UpdateBehaviourTree()
  end
  function ENT:GetPatrolPos(i)
    return self._DrGBasePatrolPos[i]
  end
  function ENT:RemovePatrolPos(i)
    local pos = table.remove(self._DrGBasePatrolPos, i)
    self:UpdateBehaviourTree()
    return pos
  end
  function ENT:ClearPatrolPos()
    self._DrGBasePatrolPos = {}
    self:UpdateBehaviourTree()
  end
  function ENT:ShufflePatrolPos()
    table.sort(self._DrGBasePatrolPos, function()
      return math.random(2) == 1
    end)
    self:UpdateBehaviourTree()
  end

  -- Functions --

  function ENT:RefreshEnemy()
    local enemy = self:GetClosestEnemy(true)
    self:SetEnemy(enemy)
    return enemy
  end

  -- Hooks --

  function ENT:OnAttack() end
  function ENT:OnChaseEnemy() end
  function ENT:OnAvoidEnemy() end

  function ENT:OnReachedPatrol() end
  function ENT:OnPatrolUnreachable() end
  function ENT:WhilePatrolling() end

  function ENT:OnIdle() end

  function ENT:ShouldRun()
    return self:HasEnemy()
  end

  -- Handlers --

  cvars.AddChangeCallback("ai_disabled", function(name, old, new)
    if not tobool(new) then return end
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      nextbot:UpdateBehaviourTree()
    end
  end, "DrGBaseDisableAIUpdateBT")

  cvars.AddChangeCallback("ai_ignoreplayers", function(name, old, new)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      nextbot:RefreshEnemy()
      if tobool(new) then
        nextbot:UpdateBehaviourTree()
        for h, ply in ipairs(player.GetAll()) do
          nextbot:LoseEntity(ply)
        end
      end
    end
  end, "DrGBaseIgnorePlayersUpdateBT")

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
