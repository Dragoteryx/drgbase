-- Getters --

function ENT:HasEnemy()
  return IsValid(self:GetEnemy())
end

if SERVER then

  local function CompareEnemies(self, ent1, ent2)
    local res = self:CompareEnemies(ent1, ent2)
    if isbool(res) then return res end
    if self:IsAfraidOf(ent1)
    and not self:IsAfraidOf(ent2)
    and not self:IsInRange(ent1, self.AvoidAfraidOfRange) then return false end
    if self:IsAfraidOf(ent2)
    and not self:IsAfraidOf(ent1)
    and not self:IsInRange(ent2, self.AvoidAfraidOfRange) then return true end
    local state1 = self:GetDetectState(ent1)
    local state2 = self:GetDetectState(ent2)
    if state1 > state2 then return true end
    if state1 < state2 then return false end
    local _, prio1 = self:GetRelationship(ent1)
    local _, prio2 = self:GetRelationship(ent2)
    if state1 == DETECT_STATE_DETECTED then
      if prio1 == prio2 then
        return self:GetRangeSquaredTo(ent1) < self:GetRangeSquaredTo(ent2)
      else return self:GetRangeTo(ent1)/prio1 < self:GetRangeTo(ent1)/prio2 end
    elseif prio1 == prio2 then
      return self:GetPos():DistToSqr(self:LastKnownPos(ent1)) < self:GetPos():DistToSqr(self:LastKnownPos(ent2))
    else return self:GetPos():Distance(self:LastKnownPos(ent1))/prio1 < self:GetPos():Distance(self:LastKnownPos(ent2))/prio2 end
  end

  local function FetchEnemy(self)
    local enemy
    for hostile in self:HostileIterator(true) do
      if not enemy or CompareEnemies(self, hostile, enemy) then
        enemy = hostile
      end
    end
    return enemy
  end

  -- Getters/setters --

  function ENT:UpdateEnemy()
    if not self:IsPossessed() then
      local enemy = self.DrG_SetEnemy
      if not IsValid(enemy) then enemy = self:OnUpdateEnemy() end
      if not enemy then enemy = FetchEnemy(self) end
      if IsValid(enemy) then
        self:SetNW2Entity("DrG/Enemy", enemy)
        self.DrG_HadEnemy = true
        return enemy
      end
    end
    self:SetNW2Entity("DrG/Enemy", NULL)
    self.DrG_HadEnemy = false
    return NULL
  end

  function ENT:GetEnemy()
    local enemy = self:GetNW2Entity("DrG/Enemy")
    if IsValid(enemy) then return enemy end
    if not self.DrG_HadEnemy then return NULL
    else return self:UpdateEnemy() end
  end
  function ENT:SetEnemy(enemy)
    self.DrG_SetEnemy = enemy
    self:UpdateEnemy()
  end

  function ENT:GetEnemyDetectState()
    return self:GetDetectState(self:GetEnemy())
  end
  function ENT:SetEnemyDetectState(state)
    return self:SetDetectState(self:GetEnemy(), state)
  end

  -- Coroutine --

  function ENT:DoHandleEnemy(enemy, state)
    if self:IsEnemy(enemy) then
      if state == DETECT_STATE_DETECTED then
        local visible = self:Visible(enemy)
        if not self:IsInRange(enemy, self.ReachEnemyRange) or not visible then
          if self:DoApproachEnemy(enemy) == false then self:DoEnemyUnreachable(enemy) end
        elseif self:IsInRange(enemy, self.AvoidEnemyRange) and visible then
          self:DoMoveAwayFromEnemy(enemy)
        else self:DoObserveEnemy(enemy) end
        if IsValid(enemy) then self:DoAttack(enemy) end
      elseif state == DETECT_STATE_SEARCHING then
        local res = self:DoSearchEnemy(enemy)
        if res == false then self:DoEnemyNotFound(enemy) end
        if res == true then self:DoFoundEnemy(enemy) end
      end
    elseif self:IsAfraidOf(enemy) then
      if state == DETECT_STATE_DETECTED then
        local visible = self:Visible(enemy)
        if self:IsInRange(enemy, self.AvoidAfraidOfRange) and visible then
          self:DoMoveAwayFromEnemy(enemy)
          if IsValid(enemy) then self:DoAttack(enemy) end
        else self:DoPassive() end
      else self:DoPassive() end
    else self:DoPassive() end
  end
  function ENT:DoAttack(enemy)
    local weapon = self:GetWeapon()
    if self:IsInRange(enemy, self.MeleeAttackRange) and
    self:DoMeleeAttack(enemy, weapon) ~= false then
      -- do nothing
    elseif self:IsInRange(enemy, self.RangeAttackRange) then
      self:DoRangeAttack(enemy, weapon)
    end
  end

  local OnChaseEnemyDeprecation = DrGBase.Deprecation("ENT:OnChaseEnemy(enemy)", "ENT:DoApproachEnemy(enemy)")
  local OnAvoidEnemyDeprecation = DrGBase.Deprecation("ENT:OnAvoidEnemy(enemy)", "ENT:DoMoveAwayFromEnemy(enemy)")
  local OnIdleEnemyDeprecation = DrGBase.Deprecation("ENT:OnIdleEnemy(enemy)", "ENT:DoObserveEnemy(enemy)")
  local OnEnemyUnreachableDeprecation = DrGBase.Deprecation("ENT:OnEnemyUnreachable(enemy)", "ENT:DoEnemyUnreachable(enemy)")
  local OnMeleeAttackDeprecation = DrGBase.Deprecation("ENT:OnMeleeAttack(enemy, weapon)", "ENT:DoMeleeAttack(enemy, weapon)")
  local OnRangeAttackDeprecation = DrGBase.Deprecation("ENT:OnRangeAttack(enemy, weapon)", "ENT:DoRangeAttack(enemy, weapon)")
  function ENT:DoApproachEnemy(enemy)
    if isfunction(self.OnChaseEnemy) then
      OnChaseEnemyDeprecation()
      local res = self:OnChaseEnemy(enemy)
      if res ~= true and self:FollowPath(enemy) == "unreachable" then return false end
    elseif self:FollowPath(enemy) == "unreachable" then return false end
  end
  function ENT:DoMoveAwayFromEnemy(enemy)
    if isfunction(self.OnAvoidEnemy) then
      OnAvoidEnemyDeprecation()
      if self:OnAvoidEnemy(enemy) ~= true then
        self:FaceTowards(enemy) self:FaceTowards(enemy)
        self:FollowPath(self:GetPos():DrG_Away(enemy:GetPos()))
      end
    else
      self:FaceTowards(enemy) self:FaceTowards(enemy)
      self:FollowPath(self:GetPos():DrG_Away(enemy:GetPos()))
    end
  end
  function ENT:DoObserveEnemy(enemy)
    if isfunction(self.OnIdleEnemy) then
      OnIdleEnemyDeprecation()
      if self:OnIdleEnemy(enemy) ~= true then
        self:FaceEnemy()
      end
    else self:FaceEnemy() end
  end
  function ENT:DoEnemyUnreachable(enemy)
    if isfunction(self.OnEnemyUnreachable) then
      OnEnemyUnreachableDeprecation()
      self:OnEnemyUnreachable(enemy)
    end
  end
  function ENT:DoMeleeAttack(enemy, weapon)
    if isfunction(self.OnMeleeAttack) then
      OnMeleeAttackDeprecation()
      self:OnMeleeAttack(enemy, weapon)
    end
  end
  function ENT:DoRangeAttack(enemy, weapon)
    if isfunction(self.OnRangeAttack) then
      OnRangeAttackDeprecation()
      self:OnRangeAttack(enemy, weapon)
    end
  end

  function ENT:DoSearchEnemy(enemy)
    local lastKnowPos = self:LastKnownPos(enemy)
    if not lastKnowPos then return false end
    if self:FollowPath(lastKnowPos) == "reached" then
      return false
    end
  end
  function ENT:DoFoundEnemy(enemy)
    self:DetectEntity(enemy)
  end
  function ENT:DoEnemyNotFound(_enemy)
    for hostile in self:HostileIterator(true) do
      self:ForgetEntity(hostile)
    end
    self:Idle(math.random(3, 7))
  end

  -- Hooks --

  function ENT:OnUpdateEnemy() end
  function ENT:CompareEnemies(_enemy1, _enemy2) end

else

  -- Getters --

  function ENT:GetEnemy()
    return self:GetNW2Entity("DrG/Enemy")
  end

end