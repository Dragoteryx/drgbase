function ENT:IsAIDisabled()
  return self:GetNW2Bool("DrGBaseAIDisabled") or GetConVar("ai_disabled"):GetBool()
end

if SERVER then

  -- Helpers --

  local function UpdateAI(self)
    
  end

  function ENT:SetAIDisabled(disabled)
    self:SetNW2Bool("DrGBaseAIDisabled", tobool(disabled))
  end

  -- Hooks --

  function ENT:OnSpawn() end
  function ENT:OnIdle() end
  function ENT:OnNoEnemy()
    if false then
      self:Patrol()
    else self:OnIdle() end
  end

  -- Internal --

  function ENT:_DrGBaseAIBehaviour()
    if self:HasEnemy() then
      self:OnEnemy(self:GetEnemy())
    else self:OnNoEnemy() end
  end

end