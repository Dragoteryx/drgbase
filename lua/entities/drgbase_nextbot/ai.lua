
function ENT:GetEnemy()
  return self:GetDrGVar("DrGBaseEnemy")
end
function ENT:HaveEnemy()
  return IsValid(self:GetEnemy())
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
          self:EnemyInRange(enemy)
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
          end)
        end
      elseif IsValid(enemy) and self:InRange(enemy, self.EnemyReach) and
      self:LineOfSight(enemy, 360, math.huge) then
        self:EnemyInRange(enemy)
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

  -- Helpers --

  function ENT:FindEntities(range, relationship)
    range = range or self.Radius
    if range < 0 then return {} end
    if range > self.Radius then range = self.Radius end
    local entities = {}
    for i, ent in ipairs(self:GetTargettableEntities()) do
      if not IsValid(ent) then continue end
      if self:EntIndex() == ent:EntIndex() then continue end
      if not self:HasSpottedEntity(ent) then continue end
      if self:GetRangeSquaredTo(ent) > math.pow(range, 2) then continue end
      if relationship and self:GetRelationship(ent) ~= relationship then continue end
      table.insert(entities, ent)
    end
    table.sort(entities, function(ent1, ent2)
      return self:GetRangeSquaredTo(ent1) < self:GetRangeSquaredTo(ent2)
    end)
    return entities
  end

  function ENT:FindClosestEntity(range, relationship)
    local entities = self:FindEntities(range, relationship)
    if #entities > 0 then return entities[1]
    else return nil end
  end

  function ENT:FindClosestAlly(range)
    return self:FindClosestEntity(range, D_LI)
  end
  function ENT:FindClosestEnemy(range)
    return self:FindClosestEntity(range, D_HT)
  end
  function ENT:FindClosestScaredOf(range)
    return self:FindClosestEntity(range, D_FR)
  end

  function ENT:IsAlly(ent)
    return self:GetRelationship(ent) == D_LI
  end
  function ENT:IsEnemy(ent)
    return self:GetRelationship(ent) == D_HT
  end
  function ENT:IsScaredOf(ent)
    return self:GetRelationship(ent) == D_FR
  end
  function ENT:IsNeutral(ent)
    return self:GetRelationship(ent) == D_NU
  end

  function ENT:GetAllies()
    return self:FindEntities(self.Radius, D_LI)
  end
  function ENT:GetEnemies()
    return self:FindEntities(self.Radius, D_HT)
  end
  function ENT:GetScaredOf()
    return self:FindEntities(self.Radius, D_FR)
  end
  function ENT:GetNeutrals()
    return self:FindEntities(self.Radius, D_NU)
  end

  -- Enemy --

  function ENT:SetEnemy(ent, delay)
    if delay ~= nil and delay >= 0 then
      self._DrGBaseHandleEnemy = CurTime() + delay
    end
    self:SetDrGVar("DrGBaseEnemy", ent)
  end

  function ENT:_HandleEnemy()
    if self:IsPossessed() then return end
    if CurTime() < self._DrGBaseHandleEnemy then return end
    self:SetEnemy(self:FindClosestEnemy(), 0.5)
  end

  -- Destination --

  function ENT:SetDestination(pos)
    self:SetDrGVar("DrGBaseDestination", pos)
  end

else


end
