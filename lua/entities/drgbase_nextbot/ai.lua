-- Getters --

function ENT:IsAIDisabled()
  return GetConVar("ai_disabled"):GetBool() or DrGBase.AIDisabled:GetBool() or self:GetNW2Bool("DrG/AIDisabled")
end

if SERVER then

  function ENT:SetAIDisabled(disabled)
    self:SetNW2Bool("DrG/AIDisabled", tobool(disabled))
  end
  function ENT:DisableAI()
    self:SetAIDisabled(true)
  end
  function ENT:EnableAI()
    self:SetAIDisabled(false)
  end

  -- Hooks --

  function ENT:AIBehaviour()
    if self:HasEnemy() then
      self:DoHandleEnemy(self:GetEnemy(), self:GetEnemyDetectState())
    else self:DoPassive() end
  end

  local OnIdleDeprecation = DrGBase.Deprecation("ENT:OnIdle()", "ENT:DoPassive()")
  function ENT:DoPassive()
    if isfunction(self.OnIdle) then
      OnIdleDeprecation()
      self:OnIdle()
    else self:RoamAtRandom() end
  end

  -- Roam

  function ENT:RoamTo(...)
    local args, n = table.DrG_Pack(...)
    if n == 0 then return false end
    for i = 1, n do
      local pos = args[i]
      local res
      while true do
        if not DrGBase.AIRoam:GetBool() then return false end
        if self:IsAIDisabled() then return false end
        if self:IsPossessed() then return false end
        if self:HasEnemy() then return false end
        res = self:DoRoam(pos)
        if isbool(res) then break end
        self:YieldCoroutine(true)
      end
      if res then self:DoRoamReached(pos)
      else self:DoRoamUnreachable(pos) end
    end
    return true
  end
  function ENT:RoamAtRandom(min, max)
    if not DrGBase.AIRoam:GetBool() then return false end
    if not isnumber(min) then min, max = 1500, nil end
    return self:RoamTo(self:RandomPos(min, max))
  end

  local OnPatrollingDeprecation = DrGBase.Deprecation("ENT:OnPatrolling()", "ENT:DoRoam()")
  function ENT:DoRoam(pos)
    if isfunction(self.OnPatrolling) then
      OnPatrollingDeprecation()
      return self:OnPatrolling(pos)
    else
      local res = self:FollowPath(pos)
      if res == "reached" then return true
      elseif res == "unreachable" then return false end
    end
  end

  local OnReachedPatrolDeprecation = DrGBase.Deprecation("ENT:OnReachedPatrol(pos)", "ENT:DoRoamReached(pos)")
  function ENT:DoRoamReached(pos)
    if isfunction(self.OnReachedPatrol) then
      OnReachedPatrolDeprecation()
      self:OnReachedPatrol(pos)
    else self:Idle(math.random(3, 7)) end
  end

  local OnPatrolUnreachableDeprecation = DrGBase.Deprecation("ENT:OnPatrolUnreachable(pos)", "ENT:DoRoamUnreachable(pos)")
  function ENT:DoRoamUnreachable(pos)
    if isfunction(self.OnPatrolUnreachable) then
      OnPatrolUnreachableDeprecation()
      self:OnPatrolUnreachable(pos)
    else self:Idle(3, 7) end
  end

  -- Misc

  function ENT:ShouldRun()
    return self:GetEnemyDetectState() == DETECT_STATE_DETECTED
  end
  function ENT:ShouldCrouch()
    return false
  end

  function ENT:ShouldDropWeapon()
    return self.DropWeaponOnDeath
  end

end