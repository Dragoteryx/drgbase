local META = FindMetaTable("DrG/NextBot")

-- Getters --

function META:HasEnemy()
  return IsValid(self:GetEnemy())
end

if SERVER then

  local function CompareEnemies(self, ent1, ent2)
    local res = self:CompareEnemies(ent1, ent2)
    if isbool(res) then return res end
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

  function META:UpdateEnemy()
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

  function META:GetEnemy()
    local enemy = self:GetNW2Entity("DrG/Enemy")
    if IsValid(enemy) then return enemy end
    if not self.DrG_HadEnemy then return NULL
    else return self:UpdateEnemy() end
  end
  function META:SetEnemy(enemy)
    self.DrG_SetEnemy = enemy
    self:UpdateEnemy()
  end

  function META:GetEnemyDetectState()
    return self:GetDetectState(self:GetEnemy())
  end
  function META:SetEnemyDetectState(state)
    return self:SetDetectState(self:GetEnemy(), state)
  end

  -- Coroutine --

  function META:DoHandleEnemy(enemy, state)
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
        if res == true then self:DetectEntity(enemy) end
      end
    elseif self:IsAfraidOf(enemy) then
      -- todo
    else self:DoPassive() end
  end
  function META:DoAttack(enemy)
    local weapon = self:GetWeapon()
    if self:IsInRange(enemy, self.MeleeAttackRange) and
    self:DoMeleeAttack(enemy, weapon) ~= false then
      -- do nothing
    elseif self:IsInRange(enemy, self.RangeAttackRange) then
      self:DoRangeAttack(enemy, weapon)
    end
  end

  local OnChaseEnemyDeprecation = DrGBase.Deprecation("META:OnChaseEnemy(enemy)", "META:DoApproachEnemy(enemy)")
  local OnAvoidEnemyDeprecation = DrGBase.Deprecation("META:OnAvoidEnemy(enemy)", "META:DoMoveAwayFromEnemy(enemy)")
  local OnIdleEnemyDeprecation = DrGBase.Deprecation("META:OnIdleEnemy(enemy)", "META:DoObserveEnemy(enemy)")
  local OnEnemyUnreachableDeprecation = DrGBase.Deprecation("META:OnEnemyUnreachable(enemy)", "META:DoEnemyUnreachable(enemy)")
  local OnMeleeAttackDeprecation = DrGBase.Deprecation("META:OnMeleeAttack(enemy, weapon)", "META:DoMeleeAttack(enemy, weapon)")
  local OnRangeAttackDeprecation = DrGBase.Deprecation("META:OnRangeAttack(enemy, weapon)", "META:DoRangeAttack(enemy, weapon)")
  function META:DoApproachEnemy(enemy)
    if isfunction(self.OnChaseEnemy) then
      OnChaseEnemyDeprecation()
      return self:OnChaseEnemy(enemy)
    else
      local res = self:FollowPath(enemy)
      if res == "unreachable" then return false end
    end
  end
  function META:DoMoveAwayFromEnemy(enemy)
    if isfunction(self.OnAvoidEnemy) then
      OnAvoidEnemyDeprecation()
      return self:OnAvoidEnemy(enemy)
    else self:FollowPath(self:GetPos():DrG_Away(enemy:GetPos())) end
  end
  function META:DoObserveEnemy(enemy)
    if isfunction(self.OnIdleEnemy) then
      OnIdleEnemyDeprecation()
      return self:OnIdleEnemy(enemy)
    else self:FaceTowards(enemy) end
  end
  function META:DoEnemyUnreachable(enemy)
    if isfunction(self.OnEnemyUnreachable) then
      OnEnemyUnreachableDeprecation()
      return self:OnEnemyUnreachable(enemy)
    end
  end
  function META:DoMeleeAttack(enemy, weapon)
    if isfunction(self.OnMeleeAttack) then
      OnMeleeAttackDeprecation()
      return self:OnMeleeAttack(enemy, weapon)
    end
  end
  function META:DoRangeAttack(enemy, weapon)
    if isfunction(self.OnRangeAttack) then
      OnRangeAttackDeprecation()
      return self:OnRangeAttack(enemy, weapon)
    end
  end

  function META:DoSearchEnemy(enemy)
    local lastKnowPos = self:LastKnownPos(enemy)
    if not lastKnowPos then return false end
    if self:FollowPath(lastKnowPos) == "reached" then
      return false
    end
  end
  function META:DoEnemyNotFound(_enemy)
    for hostile in self:HostileIterator(true) do
      self:ForgetEntity(hostile)
    end
    self:Idle(math.random(3, 7))
  end

  -- Hooks --

  function META:OnUpdateEnemy() end
  function META:CompareEnemies(_enemy1, _enemy2) end

else

  -- Getters --

  function META:GetEnemy()
    return self:GetNW2Entity("DrG/Enemy")
  end

end