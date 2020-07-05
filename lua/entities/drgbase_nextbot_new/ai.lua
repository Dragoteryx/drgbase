function ENT:IsAIDisabled()
  return GetConVar("ai_disabled"):GetBool() or self:GetNW2Bool("DrGBaseAIDisabled")
end

if SERVER then

  function ENT:SetAIDisabled(disabled)
    self:SetNW2Bool("DrGBaseAIDisabled", tobool(disabled))
  end
  function ENT:DisableAI()
    self:SetAIDisabled(true)
  end
  function ENT:EnableAI()
    self:SetAIDisabled(false)
  end

  -- Hooks --

  function ENT:OnSpawn() end
  function ENT:OnIdle() end

  function ENT:OnEnemy(enemy)

  end
  function ENT:OnNoEnemy()
    if false then
      self:Patrol()
    else self:OnIdle() end
  end

  function ENT:ShouldRun()
    return self:HasEnemy()
  end

  -- Internal --

  function ENT:AIBehaviour()
    if self:HasEnemy() then
      self:OnEnemy(self:GetEnemy())
    else self:OnNoEnemy() end
  end

end