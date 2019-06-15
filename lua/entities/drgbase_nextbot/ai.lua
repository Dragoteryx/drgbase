
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
  if self:HasNemesis() then return self:GetEnemy()
  else return NULL end
end
function ENT:HasNemesis()
  return self:GetNW2Bool("DrGBaseNemesis") and self:HasEnemy()
end
function ENT:HaveNemesis()
  return self:HasNemesis()
end

function ENT:IsFollower()
  return IsValid(self:GetNW2Bool("DrGBaseFollowing"))
end
function ENT:GetFollowing()
  return self:GetNW2Entity("DrGBaseFollowing"), self:GetNW2Float("DrGBaseFollowDist")
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
    self:RefreshEnemy()
    self:LoopTimer(0.5, function()
      self:RefreshEnemy()
    end)
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
  util.AddNetworkString("DrGBaseStartFollowPlayer")
  util.AddNetworkString("DrGBaseStopFollowPlayer")

  -- Getters/setters --

  function ENT:SetAIDisabled(bool)
    self:SetNW2Bool("DrGBaseAIDisabled", bool)
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

  function ENT:FollowEntity(ent, dist, notify)
    local old = self:GetFollowing()
    if IsValid(ent) then
      if not self:IsAlly(ent) and not self:IsNeutral(ent) then return end
      if old ~= ent then
        self:SetNW2Entity("DrGBaseFollowing", ent)
        if notify then
          if old:IsPlayer() then
            net.Start("DrGBaseStopFollowPlayer")
            net.WriteEntity(self)
            net.Send(old)
          end
          if ent:IsPlayer() then
            net.Start("DrGBaseStartFollowPlayer")
            net.WriteEntity(self)
            net.Send(ent)
          end
        end
      end
      self:SetNW2Float("DrGBaseFollowDist", math.Clamp(dist, 0, math.huge))
    else
      self:SetNW2Entity("DrGBaseFollowing", nil)
      if notify and old:IsPlayer() then
        net.Start("DrGBaseStopFollowPlayer")
        net.WriteEntity(self)
        net.Send(old)
      end
    end
    self:BehaviourTreeEvent("FollowEntity", ent, dist)
  end

  function ENT:AddPatrolPos(pos, i)
    if not isvector(pos) then return end
    if isnumber(i) then
      table.insert(self._DrGBasePatrolPos, i, pos)
      self:BehaviourTreeEvent("AddedPatrolPos", pos, i)
    else
      table.insert(self._DrGBasePatrolPos, pos)
      self:BehaviourTreeEvent("AddedPatrolPos", pos, #self._DrGBasePatrolPos)
    end
  end
  function ENT:GetPatrolPos(i)
    return self._DrGBasePatrolPos[i]
  end
  function ENT:RemovePatrolPos(i)
    local pos = table.remove(self._DrGBasePatrolPos, i)
    self:BehaviourTreeEvent("RemovedPatrolPos", pos)
    return pos
  end
  function ENT:ClearPatrolPos()
    self._DrGBasePatrolPos = {}
    self:BehaviourTreeEvent("ClearedPatrolPos")
  end
  function ENT:ShufflePatrolPos()
    table.sort(self._DrGBasePatrolPos, function()
      return math.random(2) == 1
    end)
    self:BehaviourTreeEvent("ShuffledPatrolPos")
  end
  function ENT:SortPatrolPos()
    table.sort(self._DrGBasePatrolPos, function(pos1, pos2)
      return self:GroundDistance(pos1) < self:GroundDistance(pos2)
    end)
    self:BehaviourTreeEvent("SortedPatrolPos")
  end

  -- Functions --

  function ENT:FetchEnemy()
    if self:IsPossessed() then return NULL end
    local enemy = self:GetClosestEnemy(true)
    if IsValid(enemy) then return enemy
    else return NULL end
  end
  function ENT:RefreshEnemy()
    if self:HasNemesis() then return self:GetNemesis() end
    local enemy = self:FetchEnemy()
    self:SetEnemy(enemy)
    return enemy
  end

  -- Hooks --

  function ENT:OnRangeAttack() end
  function ENT:OnMeleeAttack() end
  function ENT:OnChaseEnemy() end
  function ENT:OnAvoidEnemy() end

  function ENT:OnReachedEntity(ent)
    self:FaceTowards(ent)
  end
  function ENT:OnFollowEntity() end

  function ENT:OnReachedPatrol() end
  function ENT:OnPatrolUnreachable() end
  function ENT:WhilePatrolling() end

  function ENT:OnIdle() end

  function ENT:ShouldRun()
    if self:HasEnemy() then return true end
    local ent, dist = self:GetFollowing()
    if IsValid(ent) then
      if not self:IsInRange(ent, dist*2) then return true end
      if self:GroundDistance(ent) > dist*2 then return true end
      return false
    else return false end
  end

  -- Handlers --

  cvars.AddChangeCallback("ai_disabled", function(name, old, new)
    if not tobool(new) then return end
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      nextbot:BehaviourTreeEvent("AIDisabled")
    end
  end, "DrGBaseDisableAIUpdateBT")

  function ENT:_HandleAI()
    local ent, dist = self:GetFollowing()
    if IsValid(ent) and not self:IsAlly(ent) and not self:IsNeutral(ent) then
      self:FollowEntity(nil, 0, true)
    end
  end

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

  net.Receive("DrGBaseStartFollowPlayer", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    notification.AddLegacy(ent.PrintName.." is now following you.", NOTIFY_HINT, 4)
    surface.PlaySound("buttons/lightswitch2.wav")
  end)
  net.Receive("DrGBaseStopFollowPlayer", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    notification.AddLegacy(ent.PrintName.." is no longer following you.", NOTIFY_HINT, 4)
    surface.PlaySound("buttons/lightswitch2.wav")
  end)

end
