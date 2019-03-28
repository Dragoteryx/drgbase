-- Getters/setters --

function ENT:GetState()
  return self:GetNW2Int("DrGBaseState", DRGBASE_STATE_NONE)
end

function ENT:GetEnemy()
  return self:GetNW2Entity("DrGBaseEnemy")
end
function ENT:HasEnemy()
  return IsValid(self:GetEnemy())
end

function ENT:GetScaredOf()
  return nil
end

function ENT:GetDestination()
  local dest = self:GetNW2Vector("DrGBaseDestination", false)
  if not dest then return nil else return dest end
end

function ENT:IsHostile()
  return self:GetNW2Bool("DrGBaseHostile")
end

function ENT:IsAgressive()
  local state = self:GetState()
  return state == DRGBASE_STATE_AI_PURSUE or
  state == DRGBASE_STATE_AI_SEARCH or
  state == DRGBASE_STATE_POSSESSED
end

-- Functions --

-- Hooks --

function ENT:OnStateChange() end
function ENT:OnEnemyChange() end
function ENT:OnDestinationChange() end

-- Handlers --

function ENT:_InitAI()
  if SERVER then
    self:_SetState(DRGBASE_STATE_NONE)
    self:SetHostile(true)
    coroutine.DrG_Create(function()
      while IsValid(self) do
        self:_HandleAI()
        coroutine.yield()
      end
    end)
    -- init enemy search
    self:LoopTimer(0.5, function(self)
      self._DrGBaseAfraidOf = self:GetClosestAfraidOf()
      if not IsValid(self._DrGBasePrioritizedEnemy) or not self:IsEnemy(self._DrGBasePrioritizedEnemy) then
        if self:IsHostile() then
          local enemy = self:GetClosestEnemy(true)
          if not self:HasLostEntity(enemy) then
            self:_InitMemory(enemy)
            self._DrGBaseMemory[enemy:GetCreationID()].pos = enemy:GetPos()
          end
          self:SetEnemy(enemy)
        else self:SetEnemy(nil) end
      end
    end)
  end
  self:SetNWVarProxy("DrGBaseState", function(self, name, old, new)
    if old ~= new then self:OnStateChange(old or DRGBASE_STATE_NONE, new or DRGBASE_STATE_NONE) end
  end)
  self:SetNWVarProxy("DrGBaseEnemy", function(self, name, old, new)
    if old ~= new then self:OnEnemyChange(old, new) end
  end)
  self:SetNWVarProxy("DrGBaseDestination", function(self, name, old, new)
    if old ~= new then self:OnDestinationChange(old, new) end
  end)
end

if SERVER then

  -- Getters/setters --

  function ENT:_SetState(state)
    if state == self:GetState() then return end
    self:SetNW2Int("DrGBaseState", state)
  end

  function ENT:SetEnemy(ent)
    if ent == self:GetEnemy() then return end
    self:SetNW2Entity("DrGBaseEnemy", ent)
    self._DrGBasePrioritizedEnemy = nil
  end
  function ENT:PrioritizeEnemy(ent)
    if not self:IsEnemy(ent) then return end
    self:SetEnemy(ent)
    self._DrGBasePrioritizedEnemy = ent
  end

  function ENT:SetDestination(pos)
    if pos == self:GetDestination() then return end
    self:SetNW2Vector("DrGBaseDestination", pos)
  end

  function ENT:SetHostile(bool)
    if bool == self:IsHostile() then return end
    self:SetNW2Bool("DrGBaseHostile", bool)
  end

  -- Functions --

  -- Hooks --

  function ENT:OnAvoidAfraidOf() end

  function ENT:OnAvoidEnemy() end
  function ENT:OnPursueEnemy() end
  function ENT:OnSearchEnemy() end
  function ENT:EnemyInRange() end

  function ENT:FetchDestination() end
  function ENT:MovingToDestination() end
  function ENT:ReachedDestination() end

  function ENT:ShouldRun(state)
    return state == DRGBASE_STATE_AI_PURSUE or
    state == DRGBASE_STATE_AI_SEARCH or
    state == DRGBASE_STATE_AI_AVOID or
    self:IsOnFire()
  end

  -- Handlers --

  function ENT:_DefaultBehaviour()
    local afraidof = self._DrGBaseAfraidOf
    if IsValid(afraidof) and self:IsInRange(afraidof, self.AfraidAvoid) and self:Visible(afraidof) then
      self:_SetState(DRGBASE_STATE_AI_AVOID)
      if not self:OnAvoidAfraidOf(afraidof) then
        self:MoveAwayFromEntity(afraidof)
        self:InvalidatePath()
      end
      if self.AttackAfraid and IsValid(afraidof) and
      self:IsInRange(afraidof, self.EnemyReach) and self:Visible(afraidof) then
        self:EnemyInRange(afraidof, true)
      end
    elseif self:IsHostile() and self:HasEnemy() then
      self:SetDestination(nil)
      local enemy = self:GetEnemy()
      if not IsValid(enemy) then
        self:_SetState(DRGBASE_STATE_AI_SEARCH)
      else
        if not self:HasLostEntity(enemy) then
          self:_SetState(DRGBASE_STATE_AI_PURSUE)
        else self:_SetState(DRGBASE_STATE_AI_SEARCH) end
        local stop = self.EnemyStop or self.EnemyReach
        if self:IsInRange(enemy, self.EnemyAvoid) and self:Visible(enemy) then
          if not self:OnAvoidEnemy(enemy) then
            self:MoveAwayFromEntity(enemy, true)
          end
          if self:IsInRange(enemy, self.EnemyReach) and self:Visible(enemy) then
            self:EnemyInRange(enemy, false)
          end
        elseif not self:IsInRange(enemy, stop) or not self:Visible(enemy) then
          local hookres
          if self:HasLostEntity(enemy) then
            hookres = self:OnSearchEnemy(enemy)
          else hookres = self:OnPursueEnemy(enemy) end
          if not hookres then
            local res = self:FollowEntityMemory(enemy, {
              maxage = 0.5
            }, function()
              if self:IsPossessed() then return "possession" end
              if self:CoroutineCalls() then return "callbacks" end
              if self:IsInRange(enemy, stop) and self:Visible(enemy) then return "keepdistance" end
              if self:IsInRange(enemy, self.EnemyReach) and self:Visible(enemy) then
                self:EnemyInRange(enemy, false)
              end
            end)
            if res == "lost" then self:ForgetEntity(enemy) end
          end
        else self:EnemyInRange(enemy, false) end
      end
    else
      local destination = self:GetDestination() or self:FetchDestination()
      if destination ~= nil then
        self:_SetState(DRGBASE_STATE_AI_WANDER)
        if self:GetDestination() == nil then self:SetDestination(destination) end
        local reached = self:MovingToDestination(destination)
        if reached == nil then
          local res = self:MoveToPos(destination, {
            maxage = 0.5
          }, function()
            if self:IsPossessed() then return "possession" end
            if self:CoroutineCalls() then return "callbacks" end
            if self:GetDestination() == nil then return "no destination" end
            if self:IsHostile() and self:HasEnemy() then return "enemy" end
          end)
          reached = (res == "ok")
        end
        if reached then
          self:ReachedDestination(destination)
          self:SetDestination(nil)
        end
      else self:_SetState(DRGBASE_STATE_AI_STANDBY) end
    end
  end

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
