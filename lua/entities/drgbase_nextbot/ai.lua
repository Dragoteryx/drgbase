-- ConVars --

local EnablePatrol = DrGBase.ConVar("drgbase_ai_patrol", "1")

-- Getters --

function ENT:IsAIDisabled()
  return GetConVar("ai_disabled"):GetBool() or self:GetNW2Bool("DrG/AIDisabled") or (SERVER and not self:IsInWorld())
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

  function ENT:DoIdle(...) return self:OnIdle(...) end
  function ENT:OnIdle() end

  function ENT:DoNoEnemy()
    if false then
      self:DoPatrol()
    else self:DoIdle() end
  end

  function ENT:ShouldRun()
    return self:HasEnemy() and self:HasDetectedRecently(self:GetEnemy())
  end

  -- Internal --

  function ENT:AIBehaviour()
    if self:HasEnemy() then
      self:DoHandleEnemy(self:GetEnemy())
    else self:DoNoEnemy() end
  end
end