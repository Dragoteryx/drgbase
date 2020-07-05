function ENT:HasEnemy()
  return IsValid(self:GetEnemy())
end

if SERVER then

  local function CompareEnemies(self, ent1, ent2)
    local res = self:OnCompareEnemies(ent1, ent2)
    if isbool(res) then return res end
    local _, prio1 = self:GetRelationship(ent1)
    local _, prio2 = self:GetRelationship(ent2)
    if prio1 == prio2 then
      return self:GetRangeSquaredTo(ent1) < self:GetRangeSquaredTo(ent2)
    else return self:GetRangeTo(ent1)/prio1 < self:GetRangeTo(ent2)/prio2 end
  end

  local function FetchEnemy(self)
    local current
    for enemy in self:HostileIterator(true) do
      if not IsValid(enemy) then continue end
      if not current or CompareEnemies(self, enemy, current) then
        current = enemy
      end
    end
    return current
  end

  -- Getters --

  function ENT:UpdateEnemy()
    local enemy
    if not self:IsPossessed() then
      enemy = self:OnUpdateEnemy() or FetchEnemy(self)


    else enemy = NULL end
    self:SetNW2Entity("DrGBaseEnemy", enemy)
    return enemy
  end

  function ENT:GetEnemy()
    local enemy = self:GetNW2Entity("DrGBaseEnemy")
    if IsValid(enemy) then return enemy end
    if not self._DrGBaseHadEnemy then return NULL end
    local newEnemy = self:UpdateEnemy()
    self._DrGBaseHadEnemy = IsValid(newEnemy)
    return newEnemy
  end

  -- Hooks --

  function ENT:OnUpdateEnemy() end
  function ENT:OnCompareEnemies() end

else

  -- Getters --

  function ENT:GetEnemy()
    return self:GetNW2Entity("DrGBaseEnemy")
  end

end