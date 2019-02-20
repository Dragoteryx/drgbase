
function ENT:GetEnemy()
  return self:GetDrGVar("DrGBaseEnemy")
end
function ENT:HaveEnemy()
  return IsValid(self:GetEnemy())
end
function ENT:HasEnemy()
  return self:HaveEnemy()
end

function ENT:GetDestination()
  return self:GetDrGVar("DrGBaseDestination")
end

if SERVER then

  function ENT:_DefaultBehaviour()
    local scared = self:FindClosestScaredOf()
    local destination = self:GetDestination() or self:FetchDestination()
    if IsValid(scared) and self:InRange(scared, self.ScaredAvoid) and
    self:LineOfSight(scared, 360, math.huge) then
      self:_SetState(DRGBASE_STATE_AI_AVOID)
      if not self:OnAvoidScaredOf(scared) then
        self:InvalidatePath()
        self:StepAwayFromPos(scared:GetPos())
      end
      if self.AttackScared and IsValid(scared) and self:InRange(scared, self.EnemyReach) and
      self:LineOfSight(scared, 360, math.huge) then
        self:EnemyInRange(scared, true)
      end
    elseif self:HaveEnemy() then
      self:_SetState(DRGBASE_STATE_AI_FIGHT)
      self:SetDestination(nil)
      local enemy = self:GetEnemy()
      local stop = self.EnemyStop or self.EnemyReach
      if self:InRange(enemy, self.EnemyAvoid) and self:LineOfSight(enemy, 360, math.huge) then
        if not self:OnAvoidEnemy(enemy) then
          self:StepAwayFromPos(enemy:GetPos())
        end
        if IsValid(enemy) and self:InRange(enemy, self.EnemyReach) and
        self:LineOfSight(enemy, 360, math.huge) then
          self:EnemyInRange(enemy, false)
        end
      elseif not self:InRange(enemy, stop) or
      not self:LineOfSight(enemy, 360, math.huge) then
        if not self:OnPursueEnemy(enemy) then
          self:FollowEntity(enemy, {
            maxage = 0.5, draw = GetConVar("developer"):GetBool()
          }, function()
            if self:IsPossessed() then return "possession" end
            if self:CoroutineCallbacks() then return "callbacks" end
            if self:InRange(enemy, stop) then return "keepdistance" end
            if IsValid(enemy) and self:InRange(enemy, self.EnemyReach) and
            self:LineOfSight(enemy, 360, math.huge) then
              self:EnemyInRange(enemy, false)
            end
          end)
        end
      elseif IsValid(enemy) and self:InRange(enemy, self.EnemyReach) and
      self:LineOfSight(enemy, 360, math.huge) then
        self:EnemyInRange(enemy, false)
      end
    elseif destination ~= nil then
      self:_SetState(DRGBASE_STATE_AI_WANDER)
      if self:GetDestination() == nil then self:SetDestination(destination) end
      local reached = self:MovingToDestination(destination)
      if reached == nil then
        local res = self:MoveToPos(destination, {
          maxage = 0.5, draw = GetConVar("developer"):GetBool()
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
    local enemy = self:GetEnemy()
    if IsValid(enemy) and self:InRange(enemy, self.EnemyReach) and
    self:LineOfSight(enemy, 360, math.huge) then
      self:EnemyInRangeThink(enemy)
    end
    if CurTime() < self._DrGBaseHandleEnemy then return end
    self:SetEnemy(self:FindClosestEnemy(self.Radius, true), 0.5)
  end
  function ENT:EnemyInRangeThink() end

  -- Destination --

  function ENT:SetDestination(pos)
    self:SetDrGVar("DrGBaseDestination", pos)
  end

else


end
