
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
    if IsValid(scared) and self:GetRangeSquaredTo(scared) < math.pow(self.AvoidRadius, 2) then
      self:_SetState(DRGBASE_STATE_AI_AVOID)
      if self:OnAvoidEntity(scared) ~= false then
        if IsValid(self._DrGBasePath) then self._DrGBasePath:Invalidate() end
        self:StepAwayFromPos(scared:GetPos())
      end
    elseif self:HaveEnemy() then
      self:_SetState(DRGBASE_STATE_AI_FIGHT)
      self:SetDestination(nil)
      local enemy = self:GetEnemy()
      local insist = self:OnPursueEnemy(enemy)
      if self:GetRangeSquaredTo(enemy) < math.pow(self.KeepDistance, 2) then
        self:StepAwayFromPos(enemy:GetPos())
      elseif insist or not self:LineOfSight(enemy, 360, self.EnemyReach) then
        self:FollowEntity(enemy, {
          maxage = 0.5, draw = DrGBase.Nextbot.ConVars.Debug:GetBool()
        }, function()
          if self:IsPossessed() then return "possession" end
          if self:CoroutineCallbacks() then return "callbacks" end
          if insist or not self:LineOfSight(enemy) then return end
          if self:GetRangeSquaredTo(enemy) < math.pow(self.EnemyReach, 2) then return "ok" end
        end)
      end
      if IsValid(enemy) then
        if self:LineOfSight(enemy, 360, self.EnemyReach) then
          self:EnemyInRange(enemy)
        end
      end
    elseif destination ~= nil then
      self:_SetState(DRGBASE_STATE_AI_WANDER)
      if self:GetDestination() == nil then self:SetDestination(destination) end
      self:MovingToDestination(destination)
      local reached = self:MoveToPos(destination, {
        maxage = 0.5, draw = DrGBase.Nextbot.ConVars.Debug:GetBool()
      }, function()
        if self:IsPossessed() then return "possession" end
        if self:CoroutineCallbacks() then return "callbacks" end
      end)
      if reached == "ok" then
        self:ReachedDestination(destination)
        self:SetDestination(nil)
      end
    else self:_SetState(DRGBASE_STATE_AI_STANDBY) end
  end

  -- avoid
  function ENT:OnAvoidEntity() end

  -- enemy
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
      if self:GetRangeSquaredTo(ent) > math.pow(self.Radius, 2) then continue end
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
