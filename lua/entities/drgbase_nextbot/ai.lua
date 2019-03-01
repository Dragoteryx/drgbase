
-- Scared of --

function ENT:IsScared()
  if self:IsPossessed() then return false, nil end
  local ent = self:GetDrGVar("DrGBaseScaredOf")
  return IsValid(ent), ent
end

-- Enemy --

function ENT:GetHostile()
  return self:GetDrGVar("DrGBaseHostile")
end

function ENT:GetEnemy()
  if self:IsPossessed() then return nil end
  return self:GetDrGVar("DrGBaseEnemy")
end
function ENT:HaveEnemy()
  if self:IsPossessed() then return false end
  return IsValid(self:GetEnemy())
end
function ENT:HasEnemy()
  return self:HaveEnemy()
end

-- Destination --

function ENT:GetDestination()
  if self:IsPossessed() then return nil end
  return self:GetDrGVar("DrGBaseDestination")
end

-- Helpers --

function ENT:IsAgressive()
  local state = self:GetState()
  return state == DRGBASE_STATE_AI_PURSUE or
  state == DRGBASE_STATE_AI_SEARCH or
  state == DRGBASE_STATE_POSSESSED
end

if SERVER then

  -- Scared of --

  function ENT:SetScaredOf(ent, delay)
    if self:IsPossessed() then return end
    if delay ~= nil and delay >= 0 then
      self._DrGBaseHandleScaredOf = CurTime() + delay
    end
    self:SetDrGVar("DrGBaseScaredOf", ent)
  end
  function ENT:_HandleScaredOf()
    if self:IsPossessed() then return end
    if CurTime() < self._DrGBaseHandleScaredOf then return end
    self:SetScaredOf(self:GetClosestScaredOf(true), 0.5)
  end

  function ENT:OnAvoidScaredOf() end

  -- Enemy --

  function ENT:SetHostile(bool)
    if bool then self:SetDrGVar("DrGBaseHostile", true)
    else self:SetDrGVar("DrGBaseHostile", false) end
  end

  function ENT:SetEnemy(ent, delay)
    if self:IsPossessed() then return end
    if delay ~= nil and delay >= 0 then
      self._DrGBaseHandleEnemy = CurTime() + delay
    end
    self:SetDrGVar("DrGBaseEnemy", ent)
  end
  function ENT:_HandleEnemy()
    if self:IsPossessed() then return end
    if CurTime() < self._DrGBaseHandleEnemy then return end
    local enemy = self:GetClosestEnemy(true)
    self:SetEnemy(enemy, 0.5)
    if not self:HasLostEntity(enemy) then
      self._DrGBaseMemory[enemy:GetCreationID()].pos = enemy:GetPos()
    end
  end

  function ENT:OnAvoidEnemy() end
  function ENT:OnPatrolEnemy() end
  function ENT:OnSearchEnemy() end
  function ENT:OnPursueEnemy() end
  function ENT:EnemyInRange() end

  -- Destination --

  function ENT:SetDestination(pos)
    self:SetDrGVar("DrGBaseDestination", pos)
  end

  function ENT:FetchDestination() end
  function ENT:MovingToDestination() end
  function ENT:ReachedDestination() end

  -- Hooks --

  function ENT:ShouldRun(state)
    return state == DRGBASE_STATE_AI_PURSUE or
    state == DRGBASE_STATE_AI_SEARCH or
    state == DRGBASE_STATE_AI_AVOID
  end

  -- Handlers --

  function ENT:_DefaultBehaviour()
    local scared, scaredOf = self:IsScared()
    if scared and self:InRange(scaredOf, self.ScaredAvoid) and
    self:LineOfSight(scaredOf, 360, math.huge) then
      self:_SetState(DRGBASE_STATE_AI_AVOID)
      if not self:OnAvoidScaredOf(scaredOf) then
        self:InvalidatePath()
        self:StepAwayFromPos(scaredOf:GetPos())
      end
      if self.AttackScared and IsValid(scaredOf) and
      self:InRange(scaredOf, self.EnemyReach) and self:Visible(scaredOf) then
        self:EnemyInRange(scaredOf, true)
      end
    elseif self:GetHostile() and self:GetEnemy() ~= nil then
      self:SetDestination(nil)
      local enemy = self:GetEnemy()
      if IsValid(enemy) and not self:HasLostEntity(enemy) then
        self:_SetState(DRGBASE_STATE_AI_PURSUE)
      else self:_SetState(DRGBASE_STATE_AI_SEARCH) end
      if IsValid(enemy) then
        local stop = self.EnemyStop or self.EnemyReach
        if self:InRange(enemy, self.EnemyAvoid) and self:Visible(enemy) then
          if not self:OnAvoidEnemy(enemy) then
            self:StepAwayFromPos(enemy:GetPos())
          end
          if self:InRange(enemy, self.EnemyReach) and self:Visible(enemy) then
            self:EnemyInRange(enemy, false)
          end
        elseif not self:InRange(enemy, stop) or not self:Visible(enemy) then
          local hookres
          if self:HasLostEntity(enemy) then
            hookres = self:OnSearchEnemy(enemy)
          else hookres = self:OnPursueEnemy(enemy) end
          if not hookres then
            local res = self:FollowEntityMemory(enemy, {
              maxage = 0.5
            }, function()
              if self:IsPossessed() then return "possession" end
              if self:CoroutineCallbacks() then return "callbacks" end
              if self:InRange(enemy, stop) then return "keepdistance" end
              if self:InRange(enemy, self.EnemyReach) and self:Visible(enemy) then
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
            if self:CoroutineCallbacks() then return "callbacks" end
            if self:GetHostile() and self:HaveEnemy() then return "enemy" end
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


end
