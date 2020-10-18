function ENT:HasEnemy()
  return IsValid(self:GetEnemy())
end

if SERVER then

  local function CompareEnemies(self, ent1, ent2)
    local res = self:OnCompareEnemies(ent1, ent2)
    if isbool(res) then return res end
    local recently1 = self:HasDetectedRecently(ent1)
    local recently2 = self:HasDetectedRecently(ent2)
    if recently1 == recently2 then
      local _, prio1 = self:GetRelationship(ent1)
      local _, prio2 = self:GetRelationship(ent2)
      if recently1 then
        if prio1 == prio2 then
          return self:GetRangeSquaredTo(ent1) < self:GetRangeSquaredTo(ent2)
        else return self:GetRangeTo(ent1)/prio1 < self:GetRangeTo(ent1)/prio2 end
      elseif prio1 == prio2 then
        return self:GetPos():DistToSqr(self:LastKnownPosition(ent1)) < self:GetPos():DistToSqr(self:LastKnownPosition(ent2))
      else return self:GetPos():Distance(self:LastKnownPosition(ent1))/prio1 < self:GetPos():Distance(self:LastKnownPosition(ent2))/prio2 end
    elseif recently1 and not recently2 then return true
    else return false end
  end

  local function FetchEnemy(self)
    local enemy
    for hostile in self:HostileIterator(true) do
      if not IsValid(hostile) then continue end
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
      if not IsValid(enemy) then enemy = FetchEnemy(self) end
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

  -- Thread --

  function ENT:DoHandleEnemy(enemy)
    if self:HasDetectedRecently(enemy) then
      local visible = self:Visible(enemy)
      local disp = self:GetRelationship(enemy)
      if disp == D_HT then
        if not self:IsInRange(enemy, self.ReachEnemyRange) or not visible then
          if self:DoApproachEnemy(enemy) ~= true and self:FollowPath(enemy) == "unreachable" then
            self:DoEnemyUnreachable(enemy)
          end
        elseif self:IsInRange(enemy, self.AvoidEnemyRange) and visible then
          if self:DoMoveAwayFromEnemy(enemy) ~= true then
            self:FollowPath(self:GetPos():DrG_Away(enemy:GetPos()))
          end
        elseif self:DoObserveEnemy(enemy) ~= true then self:FaceTowards(enemy) end
        if IsValid(enemy) then self:DoAttack(enemy) end
      elseif disp == D_FR then

      else self:DoNoEnemy() end
    elseif self:FollowPath(self:LastKnownPosition(enemy)) == "reached" then
      self:ForgetAllEntities()
    end
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
  local OnMeleeAttackDeprecation = DrGBase.Deprecation("ENT:OnMeleeAttack(enemy, weapon)", "ENT:DoMeleeAttack(enemy, weapon)")
  local OnRangeAttackDeprecation = DrGBase.Deprecation("ENT:OnRangeAttack(enemy, weapon)", "ENT:DoRangeAttack(enemy, weapon)")
  function ENT:DoApproachEnemy(enemy) if isfunction(self.OnChaseEnemy) then
    OnChaseEnemyDeprecation()
    return self:OnChaseEnemy(enemy)
  end end
  function ENT:DoMoveAwayFromEnemy(enemy) if isfunction(self.OnAvoidEnemy) then
    OnAvoidEnemyDeprecation()
    return self:OnAvoidEnemy(enemy)
  end end
  function ENT:DoObserveEnemy(enemy) if isfunction(self.OnIdleEnemy) then
    OnIdleEnemyDeprecation()
    return self:OnIdleEnemy(enemy)
  end end
  function ENT:DoMeleeAttack(enemy, weapon) if isfunction(self.OnMeleeAttack) then
    OnMeleeAttackDeprecation()
    return self:OnMeleeAttack(enemy, weapon)
  end end
  function ENT:DoRangeAttack(enemy, weapon) if isfunction(self.OnRangeAttack) then
    OnRangeAttackDeprecation()
    return self:OnRangeAttack(enemy, weapon)
  end end

  -- Hooks --

  function ENT:OnUpdateEnemy() end
  function ENT:OnCompareEnemies() end

else

  -- Getters --

  function ENT:GetEnemy()
    return self:GetNW2Entity("DrG/Enemy")
  end

end