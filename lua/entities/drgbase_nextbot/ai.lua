
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

function ENT:GetDestination()
  if self:IsPossessed() then return nil end
  return self:GetDrGVar("DrGBaseDestination")
end

function ENT:IsScared()
  if self:IsPossessed() then return false, nil end
  local ent = self:GetDrGVar("DrGBaseScaredOf")
  return IsValid(ent), ent
end

if SERVER then

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
    elseif self:GetEnemy() ~= nil then
      self:_SetState(DRGBASE_STATE_AI_FIGHT)
      self:SetDestination(nil)
      local enemy = self:GetEnemy()
      if IsValid(enemy) then
        local stop = self.EnemyStop or self.EnemyReach
        if self:InRange(enemy, self.EnemyAvoid) and self:Visible(enemy) then
          if not self:OnAvoidEnemy(enemy) then
            self:StepAwayFromPos(enemy:GetPos())
          end
          if IsValid(enemy) and self:InRange(enemy, self.EnemyReach) and self:Visible(enemy) then
            self:EnemyInRange(enemy, false)
          end
        elseif not self:InRange(enemy, stop) or not self:Visible(enemy) then
          if not self:OnPursueEnemy(enemy) then
            self:FollowEntity(enemy, {
              maxage = 0.5
            }, function()
              if self:IsPossessed() then return "possession" end
              if self:CoroutineCallbacks() then return "callbacks" end
              if self:InRange(enemy, stop) then return "keepdistance" end
              if IsValid(enemy) and self:InRange(enemy, self.EnemyReach) and self:Visible(enemy) then
                self:EnemyInRange(enemy, false)
              end
            end)
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
            if self:HaveEnemy() then return "enemy" end
          end)
          reached = res == "ok"
        end
        if reached then
          self:ReachedDestination(destination)
          self:SetDestination(nil)
        end
      else self:_SetState(DRGBASE_STATE_AI_STANDBY) end
    end
  end

  -- avoid
  function ENT:OnAvoidScaredOf() end

  -- enemy
  function ENT:OnAvoidEnemy() end
  function ENT:OnPursueEnemy() end
  function ENT:EnemyInRange() end

  -- destination
  function ENT:FetchDestination() end
  function ENT:MovingToDestination() end
  function ENT:ReachedDestination() end

  -- Enemy --

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
    self:SetEnemy(self:FindClosestEnemy(self.Radius, true), 0.5)
  end

  -- Destination --

  function ENT:SetDestination(pos)
    self:SetDrGVar("DrGBaseDestination", pos)
  end

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
    self:SetScaredOf(self:FindClosestScaredOf(self.Radius, true), 0.5)
  end

else


end
